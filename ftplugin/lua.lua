local auto_pair = require("AutoPair")

local function LuaExpandReturn()
    local curs = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local start_to_curs = string.sub(line, 1, curs)
    local match_opener = start_to_curs:match("%s*function%s*[%w_.:]*%(.*%)%s*$")
        or (start_to_curs:match("if%s+.*%s+then%s*$") and not start_to_curs:match(".*elseif.*"))
        or start_to_curs:match("do%s*$")
    local match_repeat = start_to_curs:match("repeat%s*$")

    if match_opener then
        return "<CR>end<Esc>O"
    elseif match_repeat then
        return "<CR>until "
    end
    return auto_pair.ExpandReturn()
end


vim.keymap.set("i", "<CR>", LuaExpandReturn, { desc = "AutoPair: Expand Return in Lua files.", expr = true, silent = true, buffer = true })
