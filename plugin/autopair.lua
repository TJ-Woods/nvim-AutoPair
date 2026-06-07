local auto_pair = require("AutoPair")
-- Keymaps for bracket autopair

vim.keymap.set("i", "(", function() return auto_pair.auto_bracket("(") end, { desc = "Close Bracket", expr = true, silent = true })
vim.keymap.set("i", "[", function() return auto_pair.auto_bracket("[") end, { desc = "Close Square Bracket", expr = true, silent = true })
vim.keymap.set("i", "{", function() return auto_pair.auto_bracket("{") end, { desc = "Close Curly Bracket", expr = true, silent = true })
vim.keymap.set("i", "<", function() return auto_pair.auto_bracket("<") end, { desc = "Close Angle Bracket", expr = true, silent = true })


-- Keymaps for bracket type-over
vim.keymap.set("i", ")", function() return auto_pair.type_over(")") end, { desc = "Allow Bracket Type-over", expr = true, silent = true })
vim.keymap.set("i", "]", function() return auto_pair.type_over("]") end, { desc = "Allow Square Bracket Type-over", expr = true, silent = true })
vim.keymap.set("i", "}", function() return auto_pair.type_over("}") end, { desc = "Allow Curly Bracket Type-over", expr = true, silent = true })
vim.keymap.set("i", ">", function() return auto_pair.type_over(">") end, { desc = "Allow Angle Bracket Type-over", expr = true, silent = true })


-- Keymaps for Quotation marks

vim.keymap.set("i", "'", function() return auto_pair.auto_quote("'") end, { desc = "Close Single Quotes", expr = true, silent = true })
vim.keymap.set("i", '"', function() return auto_pair.auto_quote('"') end, { desc = "Close Double Quotes", expr = true, silent = true })
vim.keymap.set("i", "`", function() return auto_pair.auto_quote("`") end, { desc = "Close Backtick Quotes", expr = true, silent = true })


-- Keymaps for expanding
vim.keymap.set("i", "<CR>", auto_pair.expand_enter, { desc = "Expand <CR> inside brackets", expr = true, silent = true })
vim.keymap.set("i", "<BS>", auto_pair.auto_delete, { desc = "Smart delete respectful to paired brackets and quotes", expr = true, silent = true })
vim.keymap.set("i", " ", auto_pair.expand_bracket_space, { desc = "Expand the space to both sides of an internally spaced bracket", expr = true, silent = true })
