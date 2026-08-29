local map = vim.keymap.set

-- Disable Ex mode
map("n", "Q", "<nop>", { desc = "Disable Ex mode" })

-- Clear search highlights on ESC
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search on ESC" })

-- System clipboard yanking & pasting
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map({ "n", "v" }, "<leader>Y", '"+Y', { desc = "Yank to EOL (system clipboard)" })
map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete (no yank)" })
map("x", "<leader>p", '"_dP', { desc = "Paste (no yank)" })

-- Move visual blocks up/down
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move visual block up" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move visual block down" })

-- Global search and replace word under cursor
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Global replace word under cursor" })

-- Oil.nvim floating file manager
map("n", "<leader>oi", "<cmd>Oil --float<CR>", { desc = "Edit filesystem (Oil)" })

-- LSP Keybinds
map("n", "<leader>gf", function() vim.lsp.buf.format({ async = false, timeout_ms = 5000 }) end, { desc = "Format file" })
map("n", "<leader>gd", function() vim.lsp.buf.definition() end, { desc = "Go to definition" })
map("n", "<leader>gr", function() vim.lsp.buf.references() end, { desc = "Find references" })
map("n", "<leader>ca", function() vim.lsp.buf.code_action() end, { desc = "Code action" })
map("n", "K", function() vim.lsp.buf.hover() end, { desc = "Inspect symbol under cursor" })
