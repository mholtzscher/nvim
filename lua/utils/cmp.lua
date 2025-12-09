-- Completion utilities
-- Replaces LazyVim.cmp functionality (primarily for Blink.cmp)

local M = {}

-- Actions for various completion operations
M.actions = {
  -- Expand snippet (used by blink)
  snippet_forward = function()
    if vim.snippet and vim.snippet.active({ direction = 1 }) then
      vim.snippet.jump(1)
      return true
    end
  end,
  
  snippet_stop = function()
    if vim.snippet then
      vim.snippet.stop()
    end
  end,
  
  -- AI suggestion accept (set by AI plugins like Copilot, Supermaven)
  ai_accept = nil,
  
  -- AI next edit suggestion (Sidekick NES)
  ai_nes = nil,
}

-- Snippet expansion with placeholder handling
---@param snippet string
function M.expand(snippet)
  -- Try to expand with blink
  local ok, _ = pcall(function()
    -- Native vim.snippet (Neovim 0.10+)
    local session = vim.snippet.active() and vim.snippet._session or nil
    
    local ok_expand, err = pcall(vim.snippet.expand, snippet)
    if not ok_expand then
      -- Handle nested placeholders by removing nested ${} 
      local fixed = snippet:gsub("%$%b{}", function(m)
        -- Extract the placeholder content
        local inner = m:sub(3, -2)
        -- If it contains another ${, simplify it
        if inner:find("%$%{") then
          inner = inner:gsub("%$%{[^}]+%}", "")
        end
        return "${" .. inner .. "}"
      end)
      
      if fixed ~= snippet then
        vim.snippet.expand(fixed)
      else
        -- Fallback: insert as plain text
        local pos = vim.api.nvim_win_get_cursor(0)
        vim.api.nvim_buf_set_text(0, pos[1] - 1, pos[2], pos[1] - 1, pos[2], { snippet })
      end
    end
  end)
  
  if not ok then
    -- Final fallback
    local pos = vim.api.nvim_win_get_cursor(0)
    local text = snippet:gsub("%$%b{}", ""):gsub("%$%d+", "")
    vim.api.nvim_buf_set_text(0, pos[1] - 1, pos[2], pos[1] - 1, pos[2], { text })
  end
end

-- Create action sequence for keymaps
-- Tries each action in order until one returns true
---@param actions string[]
---@return function
function M.map(actions)
  return function()
    for _, action in ipairs(actions) do
      local fn = M.actions[action]
      if fn and fn() then
        return true
      end
    end
  end
end

-- Check if completion is visible (blink.cmp)
---@return boolean
function M.visible()
  local ok, blink = pcall(require, "blink.cmp")
  if ok and blink.is_visible then
    return blink.is_visible()
  end
  return false
end

-- Confirm selection
function M.confirm()
  local ok, blink = pcall(require, "blink.cmp")
  if ok and blink.accept then
    return blink.accept()
  end
end

-- Select and confirm
function M.select_and_accept()
  local ok, blink = pcall(require, "blink.cmp")
  if ok and blink.select_and_accept then
    return blink.select_and_accept()
  end
end

-- Select next item
function M.select_next()
  local ok, blink = pcall(require, "blink.cmp")
  if ok and blink.select_next then
    return blink.select_next()
  end
end

-- Select previous item
function M.select_prev()
  local ok, blink = pcall(require, "blink.cmp")
  if ok and blink.select_prev then
    return blink.select_prev()
  end
end

-- Scroll documentation
---@param delta number
function M.scroll_docs(delta)
  local ok, blink = pcall(require, "blink.cmp")
  if ok and blink.scroll_documentation then
    return blink.scroll_documentation(delta)
  end
end

return M
