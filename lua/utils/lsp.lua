-- LSP utilities
-- Replaces LazyVim.lsp functionality

local M = {}

---@alias LspWord {from: {[1]: number, [2]: number}, to: {[1]: number, [2]: number}}

-- Track document highlight words
M.words = {}
M.words.enabled = false
M.words.ns = vim.api.nvim_create_namespace("vim_lsp_references")

-- Get LSP clients for buffer
---@param buf? number
---@return vim.lsp.Client[]
function M.get_clients(buf)
  return vim.lsp.get_clients({ bufnr = buf or 0 })
end

-- Check if any client supports a method
---@param method string
---@param buf? number
---@return boolean
function M.has_method(method, buf)
  buf = buf or 0
  for _, client in ipairs(M.get_clients(buf)) do
    if client.supports_method(method) then
      return true
    end
  end
  return false
end

-- Execute action on all clients that support a method
---@param method string
---@param fn fun(client: vim.lsp.Client, buf: number)
---@param buf? number
function M.on_supports_method(method, fn, buf)
  buf = buf or 0
  for _, client in ipairs(M.get_clients(buf)) do
    if client.supports_method(method) then
      fn(client, buf)
    end
  end
end

-- Get LSP server capabilities
---@param client vim.lsp.Client
---@return table
function M.get_capabilities(client)
  return client.server_capabilities or {}
end

-- Document highlight support
function M.words.setup()
  local handler = vim.lsp.handlers["textDocument/documentHighlight"]
  vim.lsp.handlers["textDocument/documentHighlight"] = function(err, result, ctx, config)
    if not vim.api.nvim_buf_is_loaded(ctx.bufnr) then
      return
    end
    vim.lsp.buf.clear_references()
    return handler(err, result, ctx, config)
  end
end

---@param buf? number
function M.words.get(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current = cursor[1] - 1

  local ret = {} ---@type LspWord[]
  for _, extmark in ipairs(vim.api.nvim_buf_get_extmarks(buf, M.words.ns, 0, -1, { details = true })) do
    local start_row = extmark[2]
    local end_row = extmark[4].end_row or start_row
    if current >= start_row and current <= end_row then
      ret[#ret + 1] = {
        from = { extmark[2] + 1, extmark[3] },
        to = { end_row + 1, extmark[4].end_col },
      }
    end
  end
  return ret
end

---@param count number
---@param cycle? boolean
function M.words.jump(count, cycle)
  local words = M.words.get()
  if not words or #words == 0 then
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local current = { cursor[1], cursor[2] }

  local target_idx = nil
  for i, word in ipairs(words) do
    if current[1] >= word.from[1] and current[1] <= word.to[1] then
      if current[2] >= word.from[2] and current[2] < word.to[2] then
        target_idx = i
        break
      end
    end
  end

  if not target_idx then
    target_idx = 1
  end

  target_idx = target_idx + count

  if cycle then
    target_idx = ((target_idx - 1) % #words) + 1
  else
    target_idx = math.max(1, math.min(#words, target_idx))
  end

  local target = words[target_idx]
  if target then
    vim.api.nvim_win_set_cursor(0, { target.from[1], target.from[2] })
  end
end

-- Rename functionality
---@param from string
---@param to string
---@param on_rename? fun()
function M.rename_file(from, to, on_rename)
  local changes = {
    files = {
      {
        oldUri = vim.uri_from_fname(from),
        newUri = vim.uri_from_fname(to),
      },
    },
  }

  local clients = M.get_clients()
  for _, client in ipairs(clients) do
    if client.supports_method("workspace/willRenameFiles") then
      local resp = client.request_sync("workspace/willRenameFiles", changes, 1000)
      if resp and resp.result ~= nil then
        vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
      end
    end
  end

  if on_rename then
    on_rename()
  end

  for _, client in ipairs(clients) do
    if client.supports_method("workspace/didRenameFiles") then
      client.notify("workspace/didRenameFiles", changes)
    end
  end
end

-- Action helper
---@param action string
function M.action(action)
  return function()
    vim.lsp.buf.code_action({
      apply = true,
      context = {
        only = { action },
        diagnostics = {},
      },
    })
  end
end

-- Execute code action
---@param action string
---@param filter? fun(action: lsp.CodeAction|lsp.Command): boolean
function M.execute_action(action, filter)
  vim.lsp.buf.code_action({
    filter = function(a)
      if filter and not filter(a) then
        return false
      end
      return a.kind and vim.startswith(a.kind, action)
    end,
    apply = true,
  })
end

-- Formatter for LSP
M.formatter = {
  name = "LSP",
  primary = true,
  priority = 1,
  format = function(buf)
    M.format(buf)
  end,
}

---@param buf? number
function M.format(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  vim.lsp.buf.format({
    bufnr = buf,
    timeout_ms = 3000,
  })
end

return M
