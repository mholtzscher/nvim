-- Utils module - replaces LazyVim utility functions
-- This provides the core utilities needed by plugins

local M = {}

-- Cache for loaded modules
M._cache = {}

-- Icons (from LazyVim)
M.icons = {
  misc = {
    dots = "",
  },
  ft = {
    octo = "",
  },
  dap = {
    Stopped = { " ", "DiagnosticWarn", "DapStoppedLine" },
    Breakpoint = " ",
    BreakpointCondition = " ",
    BreakpointRejected = { " ", "DiagnosticError" },
    LogPoint = ".>",
  },
  diagnostics = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Info = " ",
  },
  git = {
    added = " ",
    modified = " ",
    removed = " ",
  },
  kinds = {
    Array = " ",
    Boolean = "󰨙 ",
    Class = " ",
    Codeium = "󰘦 ",
    Color = " ",
    Control = " ",
    Collapsed = " ",
    Constant = "󰏿 ",
    Constructor = " ",
    Copilot = " ",
    Enum = " ",
    EnumMember = " ",
    Event = " ",
    Field = " ",
    File = " ",
    Folder = " ",
    Function = "󰊕 ",
    Interface = " ",
    Key = " ",
    Keyword = " ",
    Method = "󰊕 ",
    Module = " ",
    Namespace = "󰦮 ",
    Null = " ",
    Number = "󰎠 ",
    Object = " ",
    Operator = " ",
    Package = " ",
    Property = " ",
    Reference = " ",
    Snippet = "󱄽 ",
    String = " ",
    Struct = "󰆼 ",
    Supermaven = " ",
    TabNine = "󰏚 ",
    Text = " ",
    TypeParameter = " ",
    Unit = " ",
    Value = " ",
    Variable = "󰀫 ",
  },
}

-- Check if a plugin is available
---@param plugin string
---@return boolean
function M.has(plugin)
  local ok = pcall(require, plugin)
  return ok
end

-- Safe require with fallback
---@param module string
---@return any
function M.safe_require(module)
  local ok, result = pcall(require, module)
  if ok then
    return result
  end
  return nil
end

-- Merge tables (deep extend)
---@param ... table
---@return table
function M.merge(...)
  return vim.tbl_deep_extend("force", ...)
end

-- Check if running in VSCode
---@return boolean
function M.is_vscode()
  return vim.g.vscode ~= nil
end

-- Get plugin opts from lazy.nvim
---@param name string
---@return table
function M.get_plugin_opts(name)
  local plugin = require("lazy.core.config").spec.plugins[name]
  if not plugin then
    return {}
  end
  local Plugin = require("lazy.core.plugin")
  return Plugin.values(plugin, "opts", false)
end

-- Notify with level
---@param msg string
---@param level? number
function M.notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Config" })
end

-- Warn notification
---@param msg string
function M.warn(msg)
  M.notify(msg, vim.log.levels.WARN)
end

-- Error notification
---@param msg string
function M.error(msg)
  M.notify(msg, vim.log.levels.ERROR)
end

-- Info notification
---@param msg string
function M.info(msg)
  M.notify(msg, vim.log.levels.INFO)
end

-- Deprecation warning
---@param old string
---@param new string
function M.deprecate(old, new)
  M.warn(string.format("`%s` is deprecated. Please use `%s` instead.", old, new))
end

-- On attach callback for LSP
---@param on_attach fun(client: vim.lsp.Client, buffer: number)
---@param name? string
function M.on_attach(on_attach, name)
  return vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buffer = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and (not name or client.name == name) then
        return on_attach(client, buffer)
      end
    end,
  })
end

-- Delay notifications at startup
function M.lazy_notify()
  local notifs = {}
  local function temp(...)
    table.insert(notifs, vim.F.pack_len(...))
  end

  local orig = vim.notify
  vim.notify = temp

  local timer = vim.uv.new_timer()
  local check = assert(vim.uv.new_check())

  local replay = function()
    timer:stop()
    check:stop()
    if vim.notify == temp then
      vim.notify = orig
    end
    vim.schedule(function()
      for _, notif in ipairs(notifs) do
        vim.notify(vim.F.unpack_len(notif))
      end
    end)
  end

  check:start(function()
    if vim.notify ~= temp then
      replay()
    end
  end)

  timer:start(500, 0, replay)
end

-- Execute callback on very lazy event
---@param fn fun()
function M.on_very_lazy(fn)
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      fn()
    end,
  })
end

-- Toggle option
---@param option string
---@param silent? boolean
---@param values? {[1]:any, [2]:any}
function M.toggle_option(option, silent, values)
  if values then
    if vim.opt_local[option]:get() == values[1] then
      vim.opt_local[option] = values[2]
    else
      vim.opt_local[option] = values[1]
    end
    return M.info("Set " .. option .. " to " .. vim.opt_local[option]:get())
  end
  vim.opt_local[option] = not vim.opt_local[option]:get()
  if not silent then
    if vim.opt_local[option]:get() then
      M.info("Enabled " .. option)
    else
      M.warn("Disabled " .. option)
    end
  end
end

-- Toggle diagnostics
local diagnostics_enabled = true
function M.toggle_diagnostics()
  diagnostics_enabled = not diagnostics_enabled
  if diagnostics_enabled then
    vim.diagnostic.enable()
    M.info("Enabled diagnostics")
  else
    vim.diagnostic.enable(false)
    M.warn("Disabled diagnostics")
  end
end

-- Float terminal
---@param cmd? string | string[]
---@param opts? table
function M.float_term(cmd, opts)
  opts = vim.tbl_deep_extend("force", {
    size = { width = 0.9, height = 0.9 },
  }, opts or {})
  
  if M.has("snacks.nvim") then
    require("snacks").terminal(cmd, opts)
  else
    -- Fallback to basic terminal
    vim.cmd("terminal " .. (type(cmd) == "table" and table.concat(cmd, " ") or cmd or ""))
  end
end

-- Keymap helper
---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts? table
function M.map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Safe keymap (like LazyVim.safe_keymap_set)
-- Doesn't error if mapping fails
function M.safe_keymap_set(mode, lhs, rhs, opts)
  local ok = pcall(vim.keymap.set, mode, lhs, rhs, opts)
  if not ok then
    -- Silently ignore mapping failures
  end
end

-- Lazy-load submodules
M.root = setmetatable({}, {
  __index = function(_, k)
    return require("utils.root")[k]
  end,
  __call = function(_, ...)
    return require("utils.root").get(...)
  end,
})

M.format = setmetatable({}, {
  __index = function(_, k)
    return require("utils.format")[k]
  end,
  __call = function(_, ...)
    return require("utils.format").format(...)
  end,
})

M.lsp = setmetatable({}, {
  __index = function(_, k)
    return require("utils.lsp")[k]
  end,
})

M.cmp = setmetatable({}, {
  __index = function(_, k)
    return require("utils.cmp")[k]
  end,
})

return M
