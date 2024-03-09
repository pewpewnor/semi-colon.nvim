-- =====================
-- Global variables
-- =====================
local Setter = {}

-- ==============
-- Functions
-- ==============
--
-- What does it do?
--	This function adds the given character to the end of the line.
--
-- Parameters:
--	@bufnr: The buffer number where to change it (0 for current)
--	@line_num: The line number where the character should be added to
--	@character: The character which should be added to the line (if it's not
--	there yet)
--
function Setter.set_character(bufnr, line_num, end_column, character)
    -- since we're changing the previous line (after hitting enter) vim
    -- will move the indentation of the current line as well. This
    -- variable stores the indent of the previous line which will be
    -- added after adding the given line with the semicolon/comma/double
    -- point.
    -- We are doing `line_num + 1` because remember: Lua indexes start with 1!
    -- So if `line_num` is 1, we are referring to the first line!
    local indent_fix = (' '):rep(vim.fn.indent(line_num + 1))

    -- We have an exception if the character is ':', because suppose you write
    -- something like this ("|" represents the cursor):
    --
    --      case 5:|
    --
    -- If you hit enter now, than your cursor should land like this:
    --
    --      case 5:
    --          |
    --
    -- and not this:
    --
    --      case 5:
    --      |
    --
    -- so we have to add the indent given by the `shiftwidth` option
    -- as well!
    if character == ':' then
        indent_fix = indent_fix .. (' '):rep(vim.o.shiftwidth)
    end

    -- get the last character to know if there's already the needed
    -- character or not
    local line = vim.api.nvim_buf_get_lines(0, line_num, line_num + 1, false)[1]

    -- make sure that no character is added after the semicolon
    if line:sub(-1) == ';' then
        return -- Do nothing
    end

    -- Insert a semicolon after calling a custom function
    -- Example: func(args). It checks for a closing parenthesis.
    local trimmed_line = line:sub(1, end_column):gsub('^%s+', '') -- Trim leading spaces
    -- If the character to be added is a semicolon and the line is not empty,
    -- and the line ends with a closing parenthesis, insert a semicolon.
    if character == ';' and trimmed_line ~= '' and trimmed_line:sub(-1) == ')' then
        vim.api.nvim_buf_set_lines(0, line_num, line_num + 2, false,
            { line .. character, indent_fix })
        return
    end
end

return Setter
