-- Core LSP Configuration
-- Replaces LazyVim lsp/init.lua

local Utils = require("utils")

return {
  ---------------------------------------------------------------------------
  -- nvim-lspconfig - LSP configuration
  ---------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    dependencies = {
      "mason.nvim",
      { "mason-org/mason-lspconfig.nvim", config = function() end },
    },
    opts = function()
      ---@class LspOptions
      local ret = {
        -- Options for vim.diagnostic.config()
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = "if_many",
            prefix = "●",
          },
          severity_sort = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = Utils.icons.diagnostics.Error,
              [vim.diagnostic.severity.WARN] = Utils.icons.diagnostics.Warn,
              [vim.diagnostic.severity.HINT] = Utils.icons.diagnostics.Hint,
              [vim.diagnostic.severity.INFO] = Utils.icons.diagnostics.Info,
            },
          },
        },
        -- Enable inlay hints
        inlay_hints = {
          enabled = true,
          exclude = { "vue" },
        },
        -- Enable codelens
        codelens = {
          enabled = false,
        },
        -- Options for vim.lsp.buf.format
        format = {
          formatting_options = nil,
          timeout_ms = nil,
        },
        -- LSP Server Settings
        servers = {
          lua_ls = {
            settings = {
              Lua = {
                workspace = {
                  checkThirdParty = false,
                },
                codeLens = {
                  enable = true,
                },
                completion = {
                  callSnippet = "Replace",
                },
                doc = {
                  privateName = { "^_" },
                },
                hint = {
                  enable = true,
                  setType = false,
                  paramType = true,
                  paramName = "Disable",
                  semicolon = "Disable",
                  arrayIndex = "Disable",
                },
              },
            },
          },
        },
        -- Setup functions for servers
        setup = {
          -- Example of custom setup
          -- ["server_name"] = function(server, opts)
          --   -- custom setup code
          --   return true -- return true if you don't want the default setup
          -- end,
        },
      }
      return ret
    end,
    config = function(_, opts)
      -- Setup diagnostics
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- Setup keymaps on LSP attach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buffer = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end

          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
          end

          -- LSP keymaps
          map("n", "<leader>cl", "<cmd>LspInfo<cr>", "Lsp Info")
          map("n", "gd", function() Snacks.picker.lsp_definitions() end, "Goto Definition")
          map("n", "gr", function() Snacks.picker.lsp_references() end, "References")
          map("n", "gI", function() Snacks.picker.lsp_implementations() end, "Goto Implementation")
          map("n", "gy", function() Snacks.picker.lsp_type_definitions() end, "Goto Type Definition")
          map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
          map("n", "K", vim.lsp.buf.hover, "Hover")
          map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
          map("i", "<c-k>", vim.lsp.buf.signature_help, "Signature Help")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("n", "<leader>cc", vim.lsp.codelens.run, "Run Codelens")
          map("n", "<leader>cC", vim.lsp.codelens.refresh, "Refresh & Display Codelens")
          map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")

          -- Source action
          map("n", "<leader>cA", function()
            vim.lsp.buf.code_action({
              context = {
                only = { "source" },
                diagnostics = {},
              },
            })
          end, "Source Action")

          -- Document highlight
          if client.supports_method("textDocument/documentHighlight") then
            local highlight_augroup = vim.api.nvim_create_augroup("lsp_highlight_" .. buffer, { clear = true })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              group = highlight_augroup,
              buffer = buffer,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              group = highlight_augroup,
              buffer = buffer,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd("LspDetach", {
              group = highlight_augroup,
              buffer = buffer,
              callback = function()
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = highlight_augroup, buffer = buffer })
              end,
            })

            -- Word navigation
            map("n", "]]", function() Snacks.words.jump(vim.v.count1) end, "Next Reference")
            map("n", "[[", function() Snacks.words.jump(-vim.v.count1) end, "Prev Reference")
            map("n", "<a-n>", function() Snacks.words.jump(vim.v.count1, true) end, "Next Reference")
            map("n", "<a-p>", function() Snacks.words.jump(-vim.v.count1, true) end, "Prev Reference")
          end

          -- Inlay hints
          if opts.inlay_hints.enabled and client.supports_method("textDocument/inlayHint") then
            if vim.api.nvim_buf_is_valid(buffer) and vim.bo[buffer].buftype == "" then
              if not vim.tbl_contains(opts.inlay_hints.exclude or {}, vim.bo[buffer].filetype) then
                vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
              end
            end
          end

          -- Codelens
          if opts.codelens.enabled and client.supports_method("textDocument/codeLens") then
            vim.lsp.codelens.refresh()
            vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
              buffer = buffer,
              callback = vim.lsp.codelens.refresh,
            })
          end
        end,
      })

      -- Setup servers
      local servers = opts.servers
      local has_blink, blink = pcall(require, "blink.cmp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_blink and blink.get_lsp_capabilities() or {}
      )

      local function setup_server(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})

        -- Check for custom setup
        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then
            return
          end
        elseif opts.setup["*"] then
          if opts.setup["*"](server, server_opts) then
            return
          end
        end

        require("lspconfig")[server].setup(server_opts)
      end

      -- Get all the servers that are available through mason-lspconfig
      local have_mason, mlsp = pcall(require, "mason-lspconfig")
      local all_mslp_servers = {}
      if have_mason then
        all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
      end

      local ensure_installed = {} ---@type string[]
      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          if server_opts.enabled ~= false then
            -- Run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
            if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
              setup_server(server)
            else
              ensure_installed[#ensure_installed + 1] = server
            end
          end
        end
      end

      if have_mason then
        mlsp.setup({
          ensure_installed = vim.tbl_deep_extend("force", ensure_installed, {}),
          handlers = { setup_server },
        })
      end
    end,
  },

  ---------------------------------------------------------------------------
  -- mason.nvim - Package manager for LSP servers, DAP, linters, formatters
  ---------------------------------------------------------------------------
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          -- Trigger FileType event to possibly load this newly installed LSP server
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)

      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },
}
