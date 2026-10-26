local M = {}

-- Default Config
M.config = {}

function M.setup(opts)
    if type(opts) ~= "table" then return end
    -- TODO: Is config appliccable to this plugin?
    M.config = vim.tbl_deep_extend("force", M.config, opts)
end

---@param str string parent string
---@param char string character so search for
---@desc parent string, child string (target)
local function s_has(str, char)
    for c in str:gmatch(".") do
        if c == char then
            return true
        end
    end
    return false
end

local function any(tbl)
    for _, value in pairs(tbl) do
        if value == true then return true end
    end
    return false
end

local function count(tbl)
    local total = 0
    for _, value in pairs(tbl) do
        if value == true then
            total = total + 1
        end
    end
    return total
end

function M.InQuotePair()
    local quotes = { ["'"] = true, ['"'] = true, ["`"] = true }
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local char_next = line:sub(col+1, col+1)
    local left_side = line:sub(1, col)
    local active = { ["'"] = false, ['"'] = false, ["`"] = false }

    for i = 1, #left_side do
        local char = left_side:sub(i, i)
        if quotes[char] then
            if count(active) == 0 or (count(active) == 1 and active[char]) and left_side:sub(i-1, i-1) ~= "\\" then
                active[char] = not active[char]
            end
        end
    end

    return any(active) and (char_next == '"' or char_next == "`" or char_next == "'")
end

function M.InBracketPair()
    local openers = { ['('] = true, ['['] = true, ['{'] = true }
    local closers = { [')'] = '(', [']'] = '[', ['}'] = '{' }

    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local left_side = line:sub(1, col)
    local right_side = line:sub(col + 1)
    local balances = { ['('] = 0, ['['] = 0, ['{'] = 0 }

    for i = 1, #left_side do
        local char = left_side:sub(i, i)
        if openers[char] then
            balances[char] = balances[char] + 1
        elseif closers[char] then
            local matching_opener = closers[char]
            if balances[matching_opener] > 0 then
                balances[matching_opener] = balances[matching_opener] - 1
            end
        end
    end

    for i = 1, #right_side do
        local char = right_side:sub(i, i)
        if openers[char] then
            balances[char] = balances[char] - 1
        elseif closers[char] then
            local matching_opener = closers[char]
            balances[matching_opener] = balances[matching_opener] - 1
            if balances[matching_opener] == 0 then
                return true
            end
        end
    end
    return false
end


function M.QuoteDelete()
    -- Detects quotation marks before and after cursor;
    -- deletes if true
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_prev = string.sub(line, col, col)
    local char_next = string.sub(line, col + 1, col + 1)
    local quotes = "\"'`"

    if s_has(quotes, char_prev) and char_prev == char_next then
        return "<BS><Del>"
    end
    return "<BS>"
end

function M.AutoBracket(bracket)
    -- Detects if next character is empty or space or a closing bracket;
    -- inserts respective closing bracket ahead of cursor if true
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_next = string.sub(line, col + 1, col + 1)
    local start_brackets = "([{"
    local end_brackets = ")]}"
    local index = string.find(start_brackets, bracket, 1, true)

    -- if next char is blank or a closing bracket or a closing quote
    if index and (char_next == "" or char_next == " " or s_has(end_brackets, char_next) or (M.InQuotePair() and (char_next == "'" or char_next == "`" or char_next == '"'))) then
        return bracket .. string.sub(end_brackets, index, index) .. "<left>"
    end
    return bracket
end


function M.TypeOver(closing_char)
    -- Detects if character under cursor is equal to character typed;
    -- skips insertion if true
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_under_cursor = string.sub(line, col + 1, col + 1)

    if char_under_cursor == closing_char then
        return '<Right>'
    end
    return closing_char
end


function M.AutoQuote(quote_char)
    -- Detects if character under cursor is quote;
    -- skips insertion if true
    -- places respective closing quote under cursor if false
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_under_cursor = string.sub(line, col + 1, col + 1)

    if char_under_cursor == quote_char then
        return '<Right>'
    end
    return quote_char .. quote_char .. '<Left>'
end


function M.BracketDelete()
    -- Checks if in bracket pair and next char is closing bracket;
    -- deletes both brackets if true
    -- deletes previous bracket if false
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_next_next = string.sub(line, col + 2, col + 2)
    local char_next = string.sub(line, col + 1, col + 1)
    local char_prev = string.sub(line, col, col)
    local start_brackets = "([{"
    local end_brackets = ")]}"
    local index = string.find(start_brackets, char_prev, 1, true)

    if (index and M.InBracketPair() and char_next == string.sub(end_brackets, index, index)) then
        return "<BS><DEL>"
    end
    return "<BS>"
end


function M.SpacePaddingDelete()
    -- Checks if surrounding characters are space, and surrounding those are brackets
    -- deletes both spaces if true
    -- normal delete if false
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_next_next = string.sub(line, col + 2, col + 2)
    local char_next = string.sub(line, col + 1, col + 1)
    local char_prev = string.sub(line, col, col)
    local char_prev_prev = string.sub(line, math.max(col - 1, 0), math.max(col - 1, 0))
    local start_brackets = "([{"
    local end_brackets = ")]}"

    -- Define index (which bracket pair to work with)
    if (M.InBracketPair() and s_has(start_bracket, char_prev_prev)) then
        index = string.find(start_bracket, char_prev_prev, 1, true)
        if (char_prev == " " and char_next == " " and char_next_next == string.sub(end_brackets, index, index)) then
            return "<BS><DEL>"
        end
        return "<BS>"
    end
    return "<BS>"
end


function M.ReturnPaddingDelete()
    -- Checks if line is only \n
    -- checks if previous line last character is bracket
    -- checks if next line first (non-whitespace) character is matching bracket
    -- deletes to collapse returns
    -- TODO: only detect non-whitespace characters for end of previousline
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local curr_line = vim.api.nvim_get_current_line()

    -- last character of previous line
    local prev_line = vim.api.nvim_buf_get_text(0, row-2, -2, row-2, -1)

    -- first character of next line
    local next_l = vim.api.nvim_buf_get_lines(0, row, row+1, true)[1]
    local next_line = string.sub(next_l, string.find(next_l, "%S"))

    local start_brackets = "([{"
    local end_brackets = ")]}"

    local index = string.find(start_brackets, prev_line, 1, true)

    if (index and curr_line == "" and next_line == string.sub(end_brackets, index, index)) then
        return "<BS><ESC>Ji<DEL>"  -- Collapse return padding
    end
    return "<BS>"

end


function M.AutoDelete()
    -- if previous character is a quote, goto QuoteDelete
    -- elseif previous character is a bracket, goto BracketDelete
    -- elseif previous character is a space, goto SpacePaddingDelete
    -- elseif previous character is a return, goto ReturnPaddingDelete
    -- else backspace
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_prev = string.sub(line, col, col)

    local quotes = "\"'`"
    local start_brackets = "([{"

    if s_has(quotes, char_prev) then
        return M.QuoteDelete()
    elseif s_has(start_brackets, char_prev) then
        return M.BracketDelete()
    elseif prev_char == " " then
        return M.SpacePaddingDelete()
    elseif prev_char == "\n" then
        return M.ReturnPaddingDelete()
    end
    return "<BS>"
end


function M.ExpandReturn()
    -- if characters either side of cursor are brackets, double return
    -- else normal return
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_next = string.sub(line, col + 1, col + 1)
    local char_prev = string.sub(line, col, col)
    local start_brackets = "([{"
    local end_brackets = ")]}"
    local index = string.find(start_brackets, char_prev, 1, true)

    if index and string.sub(end_brackets, index, index) == char_next then
        return "<CR><Esc>O"
    end
    return "<CR>"
end


function M.ExpandBracketSpace()
    -- if cursor between brackets, double space
    -- else normal space
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_next = string.sub(line, col + 1, col + 1)
    local char_prev = string.sub(line, col, col)
    local start_brackets = "([{"
    local end_brackets = ")]}"
    local index = string.find(start_brackets, char_prev, 1, true)

    if index and char_next == string.sub(end_brackets, index, index) then
        return " <left> "
    end
    return " "
end


function M.SurroundVisual(open_char, close_char)
    -- grab selection box
    -- insert open_char before selection box
    -- insert close_char after selection box
    -- re-select selection box (not including inserted characters)
    local mode = vim.fn.mode()

    local pos_v = vim.fn.getpos("v")
    local pos_dot = vim.fn.getpos(".")

    local start_line, end_line
    local start_col, end_col

    if pos_v[2] < pos_dot[2] or (pos_v[2] == pos_dot[2] and pos_v[3] <= pos_dot[3]) then
        start_line = pos_v[2] - 1
        end_line = pos_dot[2] - 1
        start_col = pos_v[3] - 1
        end_col = pos_dot[3]
    else
        start_line = pos_dot[2] - 1
        end_line = pos_v[2] - 1
        start_col = pos_dot[3] - 1
        end_col = pos_v[3]
    end

    if mode == "V" then
        start_col = 0
        local target_line_text = vim.api.nvim_buf_get_lines(0, end_line, end_line + 1, false)[1] or ""
        end_col = #target_line_text
    end

    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", true)

    vim.api.nvim_buf_set_text(0, end_line, end_col, end_line, end_col, { close_char })
    vim.api.nvim_buf_set_text(0, start_line, start_col, start_line, start_col, { open_char })

    local new_start_col = start_col + #open_char
    local new_end_col = end_col
    if start_line == end_line then
        new_end_col = end_col + #open_char
    end

    vim.fn.setpos("'<", { pos_v[1], start_line + 1, new_start_col + 1, 0 })
    vim.fn.setpos("'>", { pos_dot[1], end_line + 1, new_end_col, 0 })

    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("gv", true, false, true), "n", true)
end

return M
