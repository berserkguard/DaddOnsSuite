-- Utility functions for strings

Strings = {}

-- Returns true if given string starts with start, else false
function Strings:StartsWith(str, start)
    return str:sub(1, #start) == start
end
