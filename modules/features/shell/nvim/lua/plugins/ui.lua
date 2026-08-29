local logo_path = vim.fn.stdpath("config") .. "/assets/logo.txt"
local logo = vim.fn.filereadable(logo_path) == 1 and vim.fn.readfile(logo_path) or {}

return {
    -- Catppuccin Colorscheme (Mocha)
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        opts = {
            flavour = "mocha",
            transparent_background = true,
            integrations = {
                blink_cmp = true,
                gitsigns = true,
                lualine = true,
                snacks = true,
                treesitter = true,
            },
            custom_highlights = function(colors)
                return {
                    SnacksGhNormalFloat = { fg = colors.text },
                }
            end,
        },
        init = function()
            vim.cmd.colorscheme("catppuccin-mocha")
        end,
        config = function(_, opts)
            require("catppuccin").setup(opts)
            vim.cmd.colorscheme("catppuccin-mocha")
        end,
    },

    -- Snacks.nvim: Dashboard, Pickers, Notifier, Explorer
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            bigfile = { enabled = true },
            dashboard = {
                enabled = true,
                preset = {
                    header = table.concat(logo, "\n"),
                },
            },
            explorer = { enabled = true },
            image = { enabled = false },
            indent = { enabled = true },
            input = { enabled = true },
            lazygit = { enabled = true },
            notifier = {
                enabled = true,
                filter = function(notif)
                    if notif.msg and notif.msg:find("nvim%-lspconfig support for Nvim 0%.10") then
                        return false
                    end
                    return true
                end,
            },
            quickfile = { enabled = true },
            scope = { enabled = true },
            scroll = { enabled = true },
            statuscolumn = { enabled = true },
            styles = {
                snacks_image = {
                    relative = "editor",
                    col = -1,
                },
            },
            words = { enabled = true },
        },
        keys = {
            {
                "<leader><Space>",
                function()
                    Snacks.picker.files({})
                end,
                desc = "Find files (Snacks)",
            },
            {
                "<leader>gl",
                function()
                    Snacks.picker.git_log({})
                end,
                desc = "Git Log",
            },
            {
                "<leader>kb",
                function()
                    Snacks.picker.keymaps({})
                end,
                desc = "Keymaps",
            },
            {
                "<leader>lg",
                function()
                    Snacks.lazygit()
                end,
                desc = "Open lazygit",
            },
            {
                "<leader>tt",
                function()
                    Snacks.picker.grep({
                        prompt = " ",
                        search = [[(?i)(^|\s+)TODO:?\s]],
                        regex = true,
                        live = false,
                        dirs = { vim.fn.getcwd() },
                        args = { "--no-ignore" },
                        on_show = function()
                            vim.cmd.stopinsert()
                        end,
                        finder = "grep",
                        format = "file",
                        show_empty = true,
                        supports_live = false,
                    })
                end,
                desc = "Find to-do tasks",
            },
        },
    },

    -- Lualine Statusline
    {
        "nvim-lualine/lualine.nvim",
        lazy = false,
        priority = 900,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                theme = "auto",
                icons_enabled = true,
                component_separators = { left = "│", right = "│" },
                section_separators = { left = "", right = "" },
            },
        },
    },
}
