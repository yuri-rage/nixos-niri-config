-- Basic editor options
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.showmode = false
vim.opt.termguicolors = true
vim.opt.scrolloff = 8

-- Search, undo, and performance
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true
vim.opt.updatetime = 200
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Turn off legacy remote plugin providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- Spell checking with custom dictionary for docs & git commits
local dict_file = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
if vim.fn.filereadable(dict_file) == 1 then
    vim.opt.spellfile = dict_file
end
vim.opt.spelllang = { "en_us" }

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "gitcommit", "markdown", "rst" },
    callback = function()
        vim.opt_local.spell = true
    end,
})

-- Silence upstream deprecation notices on older Neovim versions
local orig_deprecate = vim.deprecate
vim.deprecate = function(name, ...)
    if name and (name:find("nvim%-lspconfig") or tostring(name):find("0%.10")) then
        return
    end
    if orig_deprecate then
        return orig_deprecate(name, ...)
    end
end

-- Load plugin manager & keymaps
require("config.lazy")
require("config.keymaps")

-- Inline diagnostic (linter/LSP) formatting & icons
vim.diagnostic.config({
    virtual_text = {
        spacing = 4,
        prefix = "◆",
    },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN]  = "",
            [vim.diagnostic.severity.HINT]  = "󰌵",
            [vim.diagnostic.severity.INFO]  = "",
        },
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

-- Transparent background & accent colors
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = "#46b6d2" })
