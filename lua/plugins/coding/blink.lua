-- Blink.cmp completion configuration
-- Replaces lazyvim.plugins.extras.coding.blink

local Utils = require("utils")

return {
  ---------------------------------------------------------------------------
  -- blink.cmp - Fast completion engine
  ---------------------------------------------------------------------------
  {
    "saghen/blink.cmp",
    version = "*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "rafamadriz/friendly-snippets",
      -- Compatibility layer for nvim-cmp sources
      {
        "saghen/blink.compat",
        optional = true,
        opts = {},
        version = "*",
      },
    },
    opts_extend = {
      "sources.default",
      "sources.compat",
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      snippets = {
        preset = "default",
        expand = function(snippet)
          Utils.cmp.expand(snippet)
        end,
      },
      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
        kind_icons = Utils.icons.kinds,
      },
      completion = {
        accept = {
          auto_brackets = {
            enabled = true,
          },
        },
        menu = {
          draw = {
            treesitter = { "lsp" },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        ghost_text = {
          enabled = vim.g.ai_cmp,
        },
      },
      sources = {
        -- Compat sources (nvim-cmp sources via blink.compat)
        compat = {},
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          lua = { "lazydev", "lsp", "path", "snippets", "buffer" },
        },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100, -- Show at higher priority than LSP
          },
        },
      },
      cmdline = {
        enabled = true,
        keymap = {
          preset = "cmdline",
          ["<Right>"] = {},
          ["<Left>"] = {},
        },
        completion = {
          list = { selection = { preselect = false } },
          menu = {
            auto_show = function(ctx)
              return vim.fn.getcmdtype() == ":"
            end,
          },
          ghost_text = { enabled = true },
        },
      },
      keymap = {
        preset = "enter",
        ["<C-y>"] = { "select_and_accept" },
        ["<Tab>"] = {
          function(cmp)
            -- Try snippet forward first
            if vim.snippet and vim.snippet.active({ direction = 1 }) then
              vim.snippet.jump(1)
              return true
            end
            -- Try AI actions
            if Utils.cmp.actions.ai_nes and Utils.cmp.actions.ai_nes() then
              return true
            end
            if Utils.cmp.actions.ai_accept and Utils.cmp.actions.ai_accept() then
              return true
            end
          end,
          "fallback",
        },
        ["<S-Tab>"] = {
          function()
            if vim.snippet and vim.snippet.active({ direction = -1 }) then
              vim.snippet.jump(-1)
              return true
            end
          end,
          "fallback",
        },
      },
    },
    config = function(_, opts)
      -- Setup compat sources
      local enabled = opts.sources.default
      for _, source in ipairs(opts.sources.compat or {}) do
        opts.sources.providers[source] = vim.tbl_deep_extend(
          "force",
          { name = source, module = "blink.compat.source" },
          opts.sources.providers[source] or {}
        )
        if type(enabled) == "table" and not vim.tbl_contains(enabled, source) then
          table.insert(enabled, source)
        end
      end

      -- Up-to-date kind icons from utils
      for kind, icon in pairs(Utils.icons.kinds) do
        opts.appearance.kind_icons[kind] = icon
      end

      require("blink.cmp").setup(opts)
    end,
  },

  -- Add lazydev to blink sources
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        per_filetype = {
          lua = { "lazydev", "lsp", "path", "snippets", "buffer" },
        },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },
    },
  },

  -- Catppuccin integration
  {
    "catppuccin",
    optional = true,
    opts = {
      integrations = { blink_cmp = true },
    },
  },
}
