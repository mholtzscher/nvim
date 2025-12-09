-- AI Sidekick configuration
-- Replaces lazyvim.plugins.extras.ai.sidekick

local Utils = require("utils")

return {
  ---------------------------------------------------------------------------
  -- Sidekick.nvim - AI assistant with Copilot
  ---------------------------------------------------------------------------
  {
    "folke/sidekick.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "<leader>as", function() require("sidekick").toggle() end, desc = "Toggle Sidekick" },
      { "<leader>ac", function() require("sidekick").chat() end, desc = "Sidekick Chat" },
    },
    config = function(_, opts)
      require("sidekick").setup(opts)
      
      -- Register AI actions for completion
      Utils.cmp.actions.ai_nes = function()
        local ok, sidekick = pcall(require, "sidekick")
        if ok and sidekick.nes then
          return sidekick.nes()
        end
      end
    end,
  },

  ---------------------------------------------------------------------------
  -- Copilot.vim - GitHub Copilot
  ---------------------------------------------------------------------------
  {
    "github/copilot.vim",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      -- Disable default Tab mapping (we handle it in blink.cmp)
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true

      -- Setup accept keymap
      vim.keymap.set("i", "<C-g>", 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
      })

      -- Register Copilot accept action for blink
      Utils.cmp.actions.ai_accept = function()
        if vim.fn["copilot#GetDisplayedSuggestion"]().text ~= "" then
          vim.api.nvim_feedkeys(
            vim.fn["copilot#Accept"](vim.api.nvim_replace_termcodes("<Tab>", true, true, true)),
            "n",
            true
          )
          return true
        end
      end
    end,
  },

  -- Add Copilot icon to completion menu
  {
    "saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      opts.appearance = opts.appearance or {}
      opts.appearance.kind_icons = opts.appearance.kind_icons or {}
      opts.appearance.kind_icons.Copilot = Utils.icons.kinds.Copilot
    end,
  },

  -- Lualine integration
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      local function sidekick_status()
        local ok, sidekick = pcall(require, "sidekick")
        if ok and sidekick.is_active then
          return sidekick.is_active() and "" or ""
        end
        return ""
      end

      -- Add to lualine_x
      table.insert(opts.sections.lualine_x, 1, {
        sidekick_status,
        cond = function()
          local ok = pcall(require, "sidekick")
          return ok
        end,
        color = function()
          return { fg = Snacks.util.color("Special") }
        end,
      })
    end,
  },
}
