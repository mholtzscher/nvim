-- Root directory detection utilities
-- Replaces LazyVim.root functionality

local M = {}

---@class RootSpec
---@field patterns string[]
---@field fallback boolean

-- Root detection cache
M.cache = {}

-- Default root patterns
M.spec = { "lsp", { ".git", "lua" }, "cwd" }

-- Detectors
M.detectors = {}

---@param buf number
---@return string?
function M.detectors.cwd(buf)
  return vim.uv.cwd()
end

---@param buf number
---@return string?
function M.detectors.lsp(buf)
  local bufpath = M.bufpath(buf)
  if not bufpath then
    return nil
  end
  
  local roots = {} ---@type string[]
  local clients = vim.lsp.get_clients({ bufnr = buf })
  
  for _, client in pairs(clients) do
    -- Skip certain LSPs that don't provide good roots
    if client.name ~= "copilot" and client.name ~= "null-ls" then
      local workspace = client.config.workspace_folders
      for _, ws in pairs(workspace or {}) do
        roots[#roots + 1] = vim.uri_to_fname(ws.uri)
      end
      if client.root_dir then
        roots[#roots + 1] = client.root_dir
      end
    end
  end
  
  return vim.tbl_isempty(roots) and nil or roots[1]
end

---@param patterns string[]
---@return fun(buf: number): string?
function M.detectors.pattern(patterns)
  return function(buf)
    local bufpath = M.bufpath(buf)
    if not bufpath then
      return nil
    end
    
    local path = vim.fs.find(patterns, {
      path = bufpath,
      upward = true,
      type = "directory",
    })[1] or vim.fs.find(patterns, {
      path = bufpath,
      upward = true,
      type = "file",
    })[1]
    
    return path and vim.fs.dirname(path) or nil
  end
end

---@param buf number
---@return string?
function M.bufpath(buf)
  return M.realpath(vim.api.nvim_buf_get_name(buf))
end

---@param path string?
---@return string?
function M.realpath(path)
  if not path or path == "" then
    return nil
  end
  return vim.uv.fs_realpath(path) or path
end

---@param buf? number
---@return string
function M.get(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local key = buf
  
  if M.cache[key] then
    return M.cache[key]
  end
  
  local root = M.detect(buf)
  M.cache[key] = root
  
  return root
end

---@param buf number
---@return string
function M.detect(buf)
  local spec = M.spec
  
  for _, s in ipairs(spec) do
    local root
    if s == "cwd" then
      root = M.detectors.cwd(buf)
    elseif s == "lsp" then
      root = M.detectors.lsp(buf)
    elseif type(s) == "table" then
      root = M.detectors.pattern(s)(buf)
    elseif type(s) == "function" then
      root = s(buf)
    end
    
    if root then
      return root
    end
  end
  
  return vim.uv.cwd() or "."
end

-- Get git root
---@return string?
function M.git()
  local root = M.get()
  local git_root = vim.fs.find(".git", { path = root, upward = true })[1]
  return git_root and vim.fs.dirname(git_root) or nil
end

-- Clear cache
function M.clear_cache()
  M.cache = {}
end

-- Setup autocmd to clear cache on directory change
vim.api.nvim_create_autocmd({ "DirChanged", "BufEnter" }, {
  callback = function()
    M.clear_cache()
  end,
})

-- Convenience function (callable as module)
setmetatable(M, {
  __call = function(_, ...)
    return M.get(...)
  end,
})

return M
