-- Options configuration
-- Standalone replacement for LazyVim options

-- Leader keys (must be set before lazy)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Auto format on save
vim.g.autoformat = true

-- Snacks animations
vim.g.snacks_animate = true

-- AI completion (use AI source in completion instead of inline suggestions when available)
vim.g.ai_cmp = true

-- Root dir detection patterns
vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

-- LSPs to ignore for root detection
vim.g.root_lsp_ignore = { "copilot" }

-- Hide deprecation warnings
vim.g.deprecation_warnings = false

-- Show document symbols from Trouble in lualine
vim.g.trouble_lualine = true

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

-- Your custom options
vim.lsp.enable("kotlin_lsp")

---------------------------------------------------------------------------
-- Vim Options
---------------------------------------------------------------------------

local opt = vim.opt

-- General
opt.autowrite = true                             -- Enable auto write
opt.confirm = true                               -- Confirm to save changes before exiting modified buffer
opt.mouse = "a"                                  -- Enable mouse mode
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.updatetime = 200                             -- Save swap file and trigger CursorHold

-- Clipboard (only set if not in ssh to allow OSC 52)
opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"

-- UI
opt.conceallevel = 2                             -- Hide * markup for bold and italic, but not markers with substitutions
opt.cursorline = true                            -- Enable highlighting of the current line
opt.laststatus = 3                               -- Global statusline
opt.number = true                                -- Print line number
opt.pumblend = 10                                -- Popup blend
opt.pumheight = 10                               -- Maximum number of entries in a popup
opt.relativenumber = true                        -- Relative line numbers
opt.ruler = false                                -- Disable the default ruler
opt.showmode = false                             -- Don't show mode since we have a statusline
opt.signcolumn = "yes"                           -- Always show the signcolumn
opt.termguicolors = true                         -- True color support
opt.winminwidth = 5                              -- Minimum window width

-- Fill characters
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

-- Indentation
opt.expandtab = true                             -- Use spaces instead of tabs
opt.shiftround = true                            -- Round indent
opt.shiftwidth = 2                               -- Size of an indent
opt.smartindent = true                           -- Insert indents automatically
opt.tabstop = 2                                  -- Number of spaces tabs count for

-- Search
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true                            -- Ignore case
opt.inccommand = "nosplit"                       -- Preview incremental substitute
opt.smartcase = true                             -- Don't ignore case with capitals

-- Wrapping & scrolling
opt.linebreak = true                             -- Wrap lines at convenient points
opt.scrolloff = 4                                -- Lines of context
opt.sidescrolloff = 8                            -- Columns of context
opt.smoothscroll = true
opt.wrap = false                                 -- Disable line wrap

-- Splits
opt.splitbelow = true                            -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true                            -- Put new windows right of current

-- Completion
opt.completeopt = "menu,menuone,noselect"
opt.wildmode = "longest:full,full"               -- Command-line completion mode

-- Formatting
opt.formatexpr = "v:lua.require'utils.format'.formatexpr()"
opt.formatoptions = "jcroqlnt"

-- Folding
opt.foldlevel = 99
opt.foldmethod = "indent"
opt.foldtext = ""

-- Undo
opt.undofile = true
opt.undolevels = 10000

-- Misc
opt.jumpoptions = "view"
opt.list = true                                  -- Show some invisible characters
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.spelllang = { "en" }
opt.timeoutlen = vim.g.vscode and 1000 or 300    -- Lower than default to quickly trigger which-key
opt.virtualedit = "block"                        -- Allow cursor to move where there is no text in visual block mode
