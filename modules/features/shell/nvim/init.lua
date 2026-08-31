-- ==============================================================================
-- Neovim 0.12 Native Configuration
-- ==============================================================================

-- ==============================================================================
-- 1. Core Editor Options
-- ==============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes:1"
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.showmode = false
vim.opt.termguicolors = true
vim.opt.scrolloff = 8

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true
vim.opt.updatetime = 400
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.o.winborder = "rounded"

-- Treesitter Code Folding
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevelstart = 99

-- Native popup completion options
vim.opt.completeopt = { "menu", "menuone", "noselect", "popup", "fuzzy" }

-- Disable legacy remote plugin providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- Spell options
vim.opt.spelllang = { "en_us" }

-- ==============================================================================
-- 2. Native Package Management (vim.pack)
-- ==============================================================================
vim.pack.add({
    -- Aesthetics & Theme
    { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
    { src = "https://github.com/nvim-lualine/lualine.nvim", name = "lualine" },
    { src = "https://github.com/nvim-tree/nvim-web-devicons", name = "nvim-web-devicons" },

    -- Modals & Pickers
    { src = "https://github.com/folke/snacks.nvim", name = "snacks" },
    { src = "https://github.com/folke/which-key.nvim", name = "which-key" },

    -- File Management & Editing
    { src = "https://github.com/stevearc/oil.nvim", name = "oil" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", name = "nvim-treesitter" },
    { src = "https://github.com/lewis6991/gitsigns.nvim", name = "gitsigns" },
    { src = "https://github.com/windwp/nvim-autopairs", name = "nvim-autopairs" },
    { src = "https://github.com/brenoprata10/nvim-highlight-colors", name = "nvim-highlight-colors" },
    { src = "https://github.com/folke/todo-comments.nvim", name = "todo-comments" },
    { src = "https://github.com/nvim-lua/plenary.nvim", name = "plenary" },

    -- Server Definitions Catalog for Native vim.lsp
    { src = "https://github.com/neovim/nvim-lspconfig", name = "nvim-lspconfig" },
}, { confirm = false })

-- ==============================================================================
-- 3. UI & Plugin Setup
-- ==============================================================================
local function warn(name, err)
    vim.schedule(function()
        vim.notify(name .. " failed to load: " .. tostring(err), vim.log.levels.WARN)
    end)
end

local function setup(name, opts)
    local ok, mod = pcall(require, name)
    if not ok then
        warn(name, mod)
        return nil
    end
    if opts ~= nil then
        mod.setup(opts)
    end
    return mod
end

-- 3.1 Gutter & Statuscolumn (3-Part: [Git Change Bar] [Diagnostic Sign] [Line Number])
_G.StatusColumn = function()
    if vim.bo.buftype ~= "" or vim.bo.filetype == "oil" or vim.bo.filetype == "help" then
        return "%s%l "
    end
    local lnum = vim.v.lnum
    local bufnr = vim.api.nvim_get_current_buf()

    -- 1. Dedicated Git Sign (far left, rendered by gitsigns %s)
    local git = "%s"

    -- 2. Dedicated Diagnostic Column (middle, fixed width, highest severity wins)
    local diag = "  "
    local diags = vim.diagnostic.get(bufnr, { lnum = lnum - 1 })
    if #diags > 0 then
        local best = diags[1].severity
        for _, d in ipairs(diags) do
            if d.severity < best then
                best = d.severity
            end
        end

        if best == vim.diagnostic.severity.ERROR then
            diag = "%#DiagnosticSignError# %*"
        elseif best == vim.diagnostic.severity.WARN then
            diag = "%#DiagnosticSignWarn# %*"
        elseif best == vim.diagnostic.severity.HINT then
            diag = "%#DiagnosticSignHint#󰌵 %*"
        elseif best == vim.diagnostic.severity.INFO then
            diag = "%#DiagnosticSignInfo# %*"
        end
    end

    -- 3. Line Number (right-aligned, next to code)
    local num = vim.v.relnum == 0 and lnum or vim.v.relnum
    local num_str = string.format("%%=%2d ", num)

    return git .. diag .. num_str
end
vim.o.statuscolumn = "%!v:lua.StatusColumn()"

-- 3.2 Colorscheme (Catppuccin Mocha)
if setup("catppuccin", {
    flavour = "mocha",
    transparent_background = true,
    integrations = {
        gitsigns = true,
        lualine = {},
        snacks = true,
        treesitter = true,
    },
    custom_highlights = function(colors)
        return {
            SnacksGhNormalFloat = { fg = colors.text },
        }
    end,
}) then
    vim.cmd.colorscheme("catppuccin-mocha")
end

-- 3.3 Statusline (Lualine)
setup("lualine", {
    options = {
        theme = "auto",
        icons_enabled = true,
        component_separators = { left = "│", right = "│" },
        section_separators = { left = "", right = "" },
    },
})

-- 3.4 File Browser (Oil.nvim)
setup("oil", {
    default_file_explorer = true,
    view_options = { show_hidden = true },
    float = {
        padding = 2,
        max_width = 90,
        max_height = 35,
        border = "rounded",
    },
})

-- 3.5 Syntax & Treesitter
local ts = setup("nvim-treesitter", {})
if ts then
    pcall(ts.install, {
        "bash", "c", "cpp", "html", "json", "lua",
        "markdown", "markdown_inline", "nix", "python",
        "regex", "toml", "vim", "vimdoc", "yaml",
    })

    vim.api.nvim_create_autocmd("FileType", {
        pattern = {
            "bash", "c", "cpp", "help", "html", "json", "lua",
            "markdown", "nix", "python", "toml", "vim", "yaml",
        },
        callback = function()
            if pcall(vim.treesitter.start) then
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
        end,
    })
end

-- 3.6 Git Integration (Gitsigns)
setup("gitsigns", {
    current_line_blame = true,
    current_line_blame_opts = {
        delay = 400,
        virt_text_pos = "right_align",
    },
})

-- 3.7 Editing Helpers & Spell Checking
setup("nvim-autopairs", {})

setup("nvim-highlight-colors", {
    render = "background",
    enable_named_colors = true,
    enable_tailwind = true,
})

setup("todo-comments", {
    keywords = {
        TODO = { icon = " ", color = "todo" },
        todo = { icon = " ", color = "todo" },
        Todo = { icon = " ", color = "todo" },
    },
    colors = { todo = { "#fd9353" } },
})

local spell_file = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
if vim.fn.filereadable(spell_file) == 1 then
    vim.opt.spellfile = spell_file
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "gitcommit", "markdown", "rst" },
    callback = function()
        vim.opt_local.spell = true
    end,
})

-- 3.8 Modals & Pickers (Snacks)
local logo_path = vim.fn.stdpath("config") .. "/assets/logo.txt"
local logo = vim.fn.filereadable(logo_path) == 1 and vim.fn.readfile(logo_path) or {}

local sqlite_path = (function()
    local candidates = {
        vim.fn.expand("~/.nix-profile/lib/libsqlite3.so"),
        "/run/current-system/sw/lib/libsqlite3.so",
    }
    for _, p in ipairs(candidates) do
        if vim.fn.filereadable(p) == 1 then
            return p
        end
    end
    return nil
end)()

setup("snacks", {
    bigfile = { enabled = true },
    dashboard = {
        enabled = true,
        sections = {
            { section = "header" },
            { section = "keys", gap = 1, padding = 1 },
            { section = "recent_files", icon = " ", title = "Recent Files", indent = 2, padding = 1 },
        },
        preset = {
            header = table.concat(logo, "\n"),
        },
    },
    explorer = { enabled = false },
    image = { enabled = false },
    indent = { enabled = true },
    input = { enabled = true },
    lazygit = { enabled = true },
    notifier = {
        enabled = true,
        filter = function(notif)
            if notif.msg and notif.msg:find("No information available") then
                return false
            end
            return true
        end,
    },
    picker = {
        enabled = true,
        db = {
            sqlite3_path = sqlite_path,
        },
    },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = false },
    words = { enabled = true },
})

setup("which-key", {
    preset = "helix",
})

-- 3.9 Highlight Accents & Transparency
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = "#46b6d2" })

-- ==============================================================================
-- 4. Native LSP (Neovim 0.12)
-- ==============================================================================

-- 4.1 Diagnostics Configuration
vim.diagnostic.config({
    virtual_text = {
        current_line = true,
        spacing = 4,
        prefix = "◆",
    },
    signs = false,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

-- 4.2 Server Specific Settings
vim.lsp.config("harper_ls", {
    settings = {
        ["harper-ls"] = {
            userDictPath = vim.fn.stdpath("config") .. "/spell/en.utf-8.add",
            linters = { ToDoHyphen = false },
        },
    },
})

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            hint = {
                enable = true,
                setType = true,
                paramType = true,
                paramName = "All",
            },
            diagnostics = {
                globals = { "vim", "Snacks" },
            },
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                    "${3rd}/luv/library",
                },
            },
        },
    },
})

vim.lsp.config("basedpyright", {
    settings = {
        basedpyright = {
            analysis = {
                inlayHints = {
                    variableTypes = true,
                    callArgumentNames = true,
                    functionReturnTypes = true,
                    genericTypes = true,
                },
            },
        },
    },
})

vim.lsp.config("clangd", {
    cmd = { "clangd", "--inlay-hints" },
})

-- 4.3 Enable Language Servers
vim.lsp.enable({
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
    "harper_ls",
})

-- 4.4 LSP Attach Handlers (Completion & Inlay Hints)
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end

        -- Enable native auto-trigger completion
        vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })

        -- Enable inlay hints if supported
        if client:supports_method("textDocument/inlayHint", bufnr) then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
    end,
})

-- 4.5 Buffer Lifecycle Autocmds (Format on Save & Diagnostic Float)
vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function(args)
        vim.lsp.buf.format({ bufnr = args.buf, async = false, timeout_ms = 3000 })
    end,
})

vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        vim.diagnostic.open_float(nil, { focusable = false, scope = "cursor" })
    end,
})

-- ==============================================================================
-- 5. Keymaps & Ergonomics
-- ==============================================================================
local map = vim.keymap.set

-- General & Search
map("n", "Q", "<nop>", { desc = "Disable Ex mode" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search on ESC" })
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Write buffer" })
map("n", "<leader>q", "<cmd>confirm q<CR>", { desc = "Quit buffer / window" })
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Global replace word under cursor" })

-- System Clipboard & Register Preservation
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map({ "n", "v" }, "<leader>Y", '"+Y', { desc = "Yank to EOL (system clipboard)" })
map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete (no yank)" })
map("x", "<leader>p", '"_dP', { desc = "Paste (no yank)" })

-- Visual Block Movement
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move visual block up" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move visual block down" })

-- File Management & Packages
map("n", "<leader>oi", "<cmd>Oil --float<CR>", { desc = "Edit filesystem (Oil)" })
map("n", "<leader>pu", vim.pack.update, { desc = "Update plugins (vim.pack)" })

-- Snacks Pickers & Modals
map("n", "<leader><Space>", function() Snacks.picker.files({}) end, { desc = "Find files" })
map("n", "<leader>gl", function() Snacks.picker.git_log({}) end, { desc = "Git Log" })
map("n", "<leader>kb", function() Snacks.picker.keymaps({}) end, { desc = "Keymaps" })
map("n", "<leader>lg", function() Snacks.lazygit() end, { desc = "Open lazygit" })
map("n", "<leader>st", function()
    Snacks.picker.grep({
        prompt = " ",
        search = [[(?i)(^|\s+)TODO:?\s]],
        regex = true,
        live = false,
        dirs = { vim.fn.getcwd() },
        args = { "--no-ignore" },
        on_show = function() vim.cmd.stopinsert() end,
        finder = "grep",
        format = "file",
        show_empty = true,
        supports_live = false,
    })
end, { desc = "Search to-do tasks" })

-- Toggles & UI Switches (Snacks.toggle + Which-Key)
Snacks.toggle.inlay_hints():map("<leader>th")
Snacks.toggle.diagnostics():map("<leader>td")
Snacks.toggle.treesitter():map("<leader>tT")
Snacks.toggle.option("wrap", { name = "Word Wrap" }):map("<leader>tw")
Snacks.toggle.option("spell", { name = "Spell Check" }):map("<leader>ts")
Snacks.toggle.option("relativenumber", { name = "Relative Numbers" }):map("<leader>tr")
Snacks.toggle.new({
    name = "Git Blame Line",
    get = function()
        local ok, gs = pcall(require, "gitsigns.config")
        return ok and gs.config.current_line_blame or false
    end,
    set = function(state)
        local ok, gs = pcall(require, "gitsigns")
        if ok then gs.toggle_current_line_blame(state) end
    end,
}):map("<leader>tb")

-- LSP Navigation & Actions
map("n", "<leader>gf", function() vim.lsp.buf.format({ async = false, timeout_ms = 5000 }) end, { desc = "Format file" })
map("n", "<leader>gd", function() vim.lsp.buf.definition() end, { desc = "Go to definition" })
map("n", "<leader>gr", function() vim.lsp.buf.references() end, { desc = "Find references" })
map("n", "<leader>ca", function() vim.lsp.buf.code_action() end, { desc = "Code action" })
map("n", "K", vim.lsp.buf.hover, { desc = "Inspect symbol under cursor" })
map("n", "<leader>k", vim.lsp.buf.hover, { desc = "Inspect symbol (no Shift)" })
map({ "n", "i" }, "<C-k>", vim.lsp.buf.signature_help, { desc = "Function signature help" })
map("i", "<C-Space>", "<C-x><C-o>", { desc = "Trigger LSP completion" })
