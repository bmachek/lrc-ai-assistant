

local function encodePhotoToBase64(filePath)
    local file = io.open(filePath, "rb")
    if not file then
        return nil
    end

    local data = file:read("*all")
    file:close()

    local base64 = LrStringUtils.encodeBase64(data)
    return base64
end



GeminiAPI = {}
GeminiAPI.__index = GeminiAPI

function GeminiAPI:new()
    local o = setmetatable({}, GeminiAPI)
    self.apiKey = prefs.apiKey
    self.generateLanguage = prefs.generateLanguage
    self.url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=' .. self.apiKey
    log:trace(self.url)
    return o
end

function GeminiAPI:imageTask(task, filePath)
    local body = {
        contents = {
            parts = {
                { text = task .. " in " .. self.generateLanguage},
                {
                    inline_data = {
                        data = encodePhotoToBase64(filePath),
                        mime_type = 'image/jpeg'
                    },
                }
            },
        },
    }

    local response, headers = LrHttp.post(self.url, JSON:encode(body), {{ field = 'Content-Type', value = 'application/json' },})

    if headers.status == 201 or headers.status == 200 then
        if response ~= nil then
            log:trace(response)
            local decoded = JSON:decode(response)
            if decoded ~= nil then
                if decoded.promptFeedback ~=  nil then
                    log:error('Request blocked: ' .. decoded.promptFeedback.blockReason)
                    return false, decoded.promptFeedback.blockReason
                else
                    if decoded.candidates[1].finishReason == 'STOP' then
                        local text = decoded.candidates[1].content.parts[1].text
                        log:trace(text)
                        return true, text
                    else
                        log:error('Blocked: ' .. decoded.candidates[1].finishReason .. util.dumpTable(decoded.candidates[1].safetyRatings))
                        return false,  decoded.candidates[1].finishReason
                    end
                end
            end
        else
            log:error('Got empty response from Google')
        end
    else
        log:error('GeminiAPI POST request failed. ' .. self.url)
        log:error(util.dumpTable(headers))
        log:error(response)
        return nil
    end
end
