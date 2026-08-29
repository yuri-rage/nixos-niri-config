return {
    -- Oil.nvim floating file manager
    {
        "stevearc/oil.nvim",
        lazy = false,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            default_file_explorer = true,
            view_options = {
                show_hidden = true,
            },
            float = {
                padding = 2,
                max_width = 90,
                max_height = 35,
                border = "rounded",
            },
        },
    },

    -- Treesitter for syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            local ok, configs = pcall(require, "nvim-treesitter.configs")
            if not ok then
                configs = require("nvim-treesitter.config")
            end
            configs.setup({
                ensure_installed = {
                    "bash",
                    "c",
                    "cpp",
                    "html",
                    "json",
                    "lua",
                    "markdown",
                    "markdown_inline",
                    "nix",
                    "python",
                    "toml",
                    "vim",
                    "vimdoc",
                    "yaml",
                },
                auto_install = false,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },

    -- Git signs in gutter & blame
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            current_line_blame = true,
            current_line_blame_opts = {
                delay = 500,
            },
        },
    },

    -- Git fugitive
    {
        "tpope/vim-fugitive",
        cmd = { "Git", "G", "Gdiffsplit" },
    },

    -- Custom Highlighted TODO comments
    {
        "folke/todo-comments.nvim",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            keywords = {
                TODO = { icon = " ", color = "todo" },
                todo = { icon = " ", color = "todo" },
                Todo = { icon = " ", color = "todo" },
            },
            colors = {
                todo = { "#fd9353" },
            },
        },
    },

    -- Autopairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {},
    },

    -- Hex and RGB color highlighter
    {
        "brenoprata10/nvim-highlight-colors",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            render = "background",
            enable_named_colors = true,
            enable_tailwind = true,
        },
    },
}
