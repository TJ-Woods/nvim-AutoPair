local M = {}

-- Default Config
M.config = {}

function M.setup(opts)
    if type(opts) ~= "table" then return end
    -- TODO: Is config appliccable to this plugin?
    M.config = vim.tbl_deep_extend("force", M.config, opts)
end

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
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_under_cursor = string.sub(line, col + 1, col + 1)

    if char_under_cursor == closing_char then
        return '<Right>'
    end
    return closing_char
end


function M.AutoQuote(quote_char)
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_under_cursor = string.sub(line, col + 1, col + 1)

    if char_under_cursor == quote_char then
        return '<Right>'
    end
    return quote_char .. quote_char .. '<Left>'
end


function M.BracketDelete()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_next_next = string.sub(line, col + 2, col + 2)
    local char_next = string.sub(line, col + 1, col + 1)
    local char_prev = string.sub(line, col, col)
    local start_brackets = "([{"
    local end_brackets = ")]}"
    local index = string.find(start_brackets, char_prev, 1, true)

    if M.InBracketPair() then
        if index and (char_next == string.sub(end_brackets, index, index)) then
            return "<BS><DEL>"
        elseif index and (char_next == " " and char_next_next == string.sub(end_brackets, index, index)) then
            return "<BS><DEL><DEL>"
        end
    end
    return "<BS>"
end


function M.AutoDelete()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_prev = string.sub(line, col, col)

    local quotes = "\"'`"
    local start_brackets = "([{"

    if s_has(quotes, char_prev) then
        return M.QuoteDelete()
    elseif s_has(start_brackets, char_prev) then
        return M.BracketDelete()
    end
    return "<BS>"
end


function M.ExpandReturn()
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
    -- beginning and end of selection (could be backwards)
    local pos_v = vim.fn.getpos("v")
    local pos_dot = vim.fn.getpos(".")

    -- Determine linear start and end (left-to-right)
    local start_pos
    local end_pos
    if pos_v[2] < pos_dot[2] or (pos_v[2] == pos_dot[2] and pos_v[3] <= pos_dot[3]) then
        start_pos = pos_v
        end_pos = pos_dot
    else
        start_pos = pos_dot
        end_pos = pos_v
    end

    -- Exit visual mode temporarily to set the '< and '> marks firmly
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", true)

    -- 0-indexing for API calls
    local start_line, start_col = start_pos[2] - 1, start_pos[3] - 1
    local end_line, end_col = end_pos[2] - 1, end_pos[3]

    -- Closing character first (doesn't shift the selection)
    vim.api.nvim_buf_set_text(0, end_line, end_col, end_line, end_col, { close_char })
    vim.api.nvim_buf_set_text(0, start_line, start_col, start_line, start_col, { open_char })

    local new_start_col = start_col + #open_char
    local new_end_col = end_col
    if start_line == end_line then
        new_end_col = end_col + #open_char
    end

    -- Set the visual marks to include the newly added wrappers
    vim.fn.setpos("'<", { start_pos[1], start_line + 1, new_start_col + 1, 0 })
    vim.fn.setpos("'>", { end_pos[1], end_line + 1, new_end_col, 0 })

    -- 5. Re-enter visual mode using the updated marks
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("gv", true, false, true), "n", true)
end

return M
