-- Helper functions

util = {}

-- Utility function to check if table contains a value
function util.table_contains(tbl, x)
    found = false
    for _, v in pairs(tbl) do
        if v == x then
            found = true
        end
    end
    return found
end

-- Utility function to dump tables as JSON scrambling the API key.
function util.dumpTable(t)
    local s = inspect(t)
    return s
    -- local pattern = '(field = "x%-api%-key",%s+value = ")(%w%w%w%w%w%w%w%w%w%w%w)(%w+)(")'
    -- return s:gsub(pattern, '%1%2...%4')
end

-- Utility function to log errors and throw user errors
function util.handleError(logMsg, userErrorMsg)
    log:error(logMsg)
    LrDialogs.showError(userErrorMsg)
end

-- Check if val is empty or nil
-- Taken from https://github.com/midzelis/mi.Immich.Publisher/blob/main/utils.lua
local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

-- Taken from https://github.com/midzelis/mi.Immich.Publisher/blob/main/utils.lua
function util.nilOrEmpty(val)
    if type(val) == 'string' then
        return val == nil or trim(val) == ''
    else
        return val == nil
    end
end

function util.string_split(s, delimiter)
    local t = {}
    for str in string.gmatch(s, "([^" .. delimiter .. "]+)") do
        table.insert(t, trim(str))
    end
    return t
end


function util.encodePhotoToBase64(filePath)
    local file = io.open(filePath, "rb")
    if not file then
        return nil
    end

    local data = file:read("*all")
    file:close()

    local base64 = LrStringUtils.encodeBase64(data)
    return base64
end