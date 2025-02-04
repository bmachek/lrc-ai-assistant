-- Helper functions

Util = {}

-- Utility function to check if table contains a value
function Util.table_contains(tbl, x)
    found = false
    for _, v in pairs(tbl) do
        if v == x then
            found = true
        end
    end
    return found
end

-- Utility function to dump tables as JSON scrambling the API key.
function Util.dumpTable(t)
    local s = inspect(t)
    local pattern = '(data = )"([A-Za-z0-9+/=]+)"'
    local result, count = s:gsub(pattern, '%1 base64 removed')
    pattern = 'data:image/jpeg;base64,"([A-Za-z0-9+/=]+)"'
    result, count = s:gsub(pattern, '%1 base64 removed')
    return result
end

-- Utility function to log errors and throw user errors
function Util.handleError(logMsg, userErrorMsg)
    log:error(logMsg)
    LrDialogs.showError(userErrorMsg)
end

-- Check if val is empty or nil
-- Taken from https://github.com/midzelis/mi.Immich.Publisher/blob/main/Utils.lua
local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

-- Taken from https://github.com/midzelis/mi.Immich.Publisher/blob/main/Utils.lua
function Util.nilOrEmpty(val)
    if type(val) == 'string' then
        return val == nil or trim(val) == ''
    else
        return val == nil
    end
end

function Util.string_split(s, delimiter)
    local t = {}
    for str in string.gmatch(s, "([^" .. delimiter .. "]+)") do
        table.insert(t, trim(str))
    end
    return t
end


function Util.encodePhotoToBase64(filePath)
    local file = io.open(filePath, "rb")
    if not file then
        return nil
    end

    local data = file:read("*all")
    file:close()

    local base64 = LrStringUtils.encodeBase64(data)
    return base64
end