-- Formatting utilities
-- Replaces LazyVim.format functionality

local M = {}

-- Registered formatters
---@type table<string, {name: string, primary?: boolean, priority: number, format: fun(bufnr: number)}>
M.formatters = {}

-- Format state
M.autoformat = true

-- Register a formatter
---@param formatter {name: string, primary?: boolean, priority?: number, format: fun(bufnr: number)}
function M.register(formatter)
  M.formatters[formatter.name] = vim.tbl_extend("force", {
    priority = 0,
  }, formatter)
end

-- Get active formatters for buffer
---@param buf number
---@return table[]
function M.get_formatters(buf)
  local ft = vim.bo[buf].filetype
  local ret = {} ---@type table[]
  
  for _, formatter in pairs(M.formatters) do
    ret[#ret + 1] = formatter
  end
  
  -- Sort by priority (higher first)
  table.sort(ret, function(a, b)
    return (a.priority or 0) > (b.priority or 0)
  end)
  
  return ret
end

-- Format buffer
---@param opts? {force?: boolean, buf?: number}
function M.format(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  
  -- Check if formatting is enabled
  if not opts.force then
    if not M.autoformat then
      return
    end
    -- Check buffer-local autoformat
    if vim.b[buf].autoformat == false then
      return
    end
    -- Check global autoformat with buffer override
    if vim.g.autoformat == false and vim.b[buf].autoformat ~= true then
      return
    end
  end
  
  local formatters = M.get_formatters(buf)
  
  -- Try conform first if available
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format({
      bufnr = buf,
      timeout_ms = 3000,
      async = false,
      quiet = false,
      lsp_format = "fallback",
    })
    return
  end
  
  -- Fallback to LSP formatting
  vim.lsp.buf.format({
    bufnr = buf,
    timeout_ms = 3000,
  })
end

-- Toggle autoformat
---@param buf? boolean|number If true/false, set global. If number, set for buffer.
function M.toggle(buf)
  if buf == true or buf == false or buf == nil then
    -- Global toggle
    M.autoformat = not M.autoformat
    vim.g.autoformat = M.autoformat
    if M.autoformat then
      require("utils").info("Enabled format on save")
    else
      require("utils").warn("Disabled format on save")
    end
  else
    -- Buffer toggle
    local bufnr = buf
    vim.b[bufnr].autoformat = not vim.b[bufnr].autoformat
    if vim.b[bufnr].autoformat then
      require("utils").info("Enabled format on save (buffer)")
    else
      require("utils").warn("Disabled format on save (buffer)")
    end
  end
end

-- Snacks toggle for format (for compatibility with LazyVim keymaps)
function M.snacks_toggle(buf)
  local Snacks = require("snacks")
  if buf then
    return Snacks.toggle({
      name = "Auto Format (Buffer)",
      get = function()
        return vim.b.autoformat ~= false
      end,
      set = function(state)
        vim.b.autoformat = state
      end,
    })
  else
    return Snacks.toggle({
      name = "Auto Format (Global)",
      get = function()
        return vim.g.autoformat ~= false
      end,
      set = function(state)
        vim.g.autoformat = state
        M.autoformat = state
      end,
    })
  end
end

-- Format expression for formatexpr
function M.formatexpr()
  if require("utils").has("conform.nvim") then
    return require("conform").formatexpr()
  end
  return vim.lsp.formatexpr({ timeout_ms = 3000 })
end

-- Setup autoformat on save
function M.setup()
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("Format", { clear = true }),
    callback = function(event)
      M.format({ buf = event.buf })
    end,
  })
end

return M
