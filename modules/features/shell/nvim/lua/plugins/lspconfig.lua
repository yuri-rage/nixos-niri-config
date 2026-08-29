return {
    -- Blink.cmp: Blazing fast completion engine
    {
        "saghen/blink.cmp",
        dependencies = { "rafamadriz/friendly-snippets" },
        version = "1.*",
        opts = {
            keymap = { preset = "default" },
            appearance = {
                nerd_font_variant = "normal",
            },
            fuzzy = { implementation = "prefer_rust_with_warning" },
        },
    },

    -- Native LSP Configuration (Zero-Mason, attaches to Nix/Direnv binaries)
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        dependencies = {
            "saghen/blink.cmp",
        },
        config = function()
            local capabilities = require("blink.cmp").get_lsp_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport = true
            capabilities.textDocument.completion.completionItem.resolveSupport = {
                properties = { "documentation", "detail", "additionalTextEdits" },
            }

            -- Format on save
            vim.api.nvim_create_autocmd("BufWritePre", {
                callback = function(args)
                    local bufnr = args.buf
                    local clients = vim.lsp.get_clients({ bufnr = bufnr })
                    local has_formatter = false
                    for _, client in ipairs(clients) do
                        if client:supports_method("textDocument/formatting", { bufnr = bufnr }) then
                            has_formatter = true
                            break
                        end
                    end
                    if has_formatter then
                        vim.lsp.buf.format({ async = false, timeout_ms = 5000 })
                    end
                end,
            })

            -- Inlay hints on attach
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local bufnr = args.buf
                    if vim.b[bufnr].lsp_attached then return end
                    vim.b[bufnr].lsp_attached = true

                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client and client:supports_method("textDocument/inlayHint", { bufnr = bufnr }) then
                        if vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable then
                            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                        end
                    end
                end,
            })

            -- List of supported language servers to enable
            local servers = {
                "clangd",
                "basedpyright",
                "ruff",
                "nil_ls",
                "nixd",
                "lua_ls",
                "ts_ls",
                "html",
                "dockerls",
                "eslint",
                "esbonio",
                "harper_ls",
            }

            local dict_path = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"

            if vim.fn.has("nvim-0.11") == 1 then
                -- Native Neovim 0.11+ API
                vim.lsp.config("*", {
                    capabilities = capabilities,
                })

                vim.lsp.config("harper_ls", {
                    settings = {
                        ["harper-ls"] = {
                            userDictPath = dict_path,
                            linters = { ToDoHyphen = false },
                        },
                    },
                })

                for _, server in ipairs(servers) do
                    vim.lsp.enable(server)
                end
            else
                -- Fallback for Neovim 0.10.x (suppress upstream deprecation notice)
                local orig_notify = vim.notify
                vim.notify = function(msg, level, opts)
                    if type(msg) == "string" and msg:find("nvim%-lspconfig support for Nvim 0%.10") then
                        return
                    end
                    return orig_notify(msg, level, opts)
                end

                local lspconfig = require("lspconfig")
                vim.notify = orig_notify

                for _, server in ipairs(servers) do
                    local server_opts = { capabilities = capabilities }
                    if server == "harper_ls" then
                        server_opts.settings = {
                            ["harper-ls"] = {
                                userDictPath = dict_path,
                                linters = { ToDoHyphen = false },
                            },
                        }
                    end
                    if lspconfig[server] then
                        lspconfig[server].setup(server_opts)
                    end
                end
            end
        end,
    },
}
