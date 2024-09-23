

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
GeminiAPI.defaultCaptionTask = 'Give detailed keywords for image content description'
GeminiAPI.defaultTitleTask = 'Generate image title'
GeminiAPI.defaultKeywordsTask = 'Give keywords for detailed image content description seperated by comma'
GeminiAPI.baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key='
GeminiAPI.__index = GeminiAPI

function GeminiAPI:new()
    local o = setmetatable({}, GeminiAPI)
    self.rateLimitHit = 0

    if util.nilOrEmpty(prefs.apiKey) then
        util.handleError('API key not configured.', 'Please configure API key in Module Manager!')
        return nil
    else
        self.apiKey = prefs.apiKey
    end

    self.url = GeminiAPI.baseUrl .. self.apiKey
    self.generateLanguage = prefs.generateLanguage
    if util.nilOrEmpty(self.generateLanguage) then
        self.generateLanguage = 'English'
    end

    return o
end

function GeminiAPI:imageTask(task, filePath)
    local body = {
        contents = {
            parts = {
                { text = task .. ' in ' .. self.generateLanguage },
                {
                    inline_data = {
                        data = encodePhotoToBase64(filePath),
                        mime_type = 'image/jpeg'
                    },
                }
            },
        },
        safety_settings = {
            {
                category = "HARM_CATEGORY_SEXUALLY_EXPLICIT",
                threshold = "BLOCK_ONLY_HIGH"
            },
            {
                category = "HARM_CATEGORY_HATE_SPEECH",
                threshold = "BLOCK_ONLY_HIGH"
            },
            {
                category = "HARM_CATEGORY_HARASSMENT",
                threshold = "BLOCK_ONLY_HIGH"
            },
            {
                category = "HARM_CATEGORY_DANGEROUS_CONTENT",
                threshold = "BLOCK_ONLY_HIGH"
            },
        },
    }

    local response, headers = LrHttp.post(self.url, JSON:encode(body), {{ field = 'Content-Type', value = 'application/json' },})

    if headers.status == 200 then
        self.rateLimitHit = 0
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
    elseif headers.status == 429 then
        log:error('Rate limit exceeded for ' .. tostring(self.rateLimitHit) .. ' times')
        LrTasks.sleep(5)
        self.rateLimitHit = self.rateLimitHit + 1
        if self.rateLimitHit >= 10 then
            log:error('Rate Limit hit 10 times, giving up')
            return false, 'RATE_LIMIT_EXHAUSTED'
        end
        self:imageTask(task, filePath)
    else
        log:error('GeminiAPI POST request failed. ' .. self.url)
        log:error(util.dumpTable(headers))
        log:error(response)
        return false, nil
    end
end


function GeminiAPI:keywordsTask(filePath)
    local success, keywordsString = self:imageTask(GeminiAPI.defaultKeywordsTask, filePath)
    if success then
        return success, util.string_split(keywordsString, ', ')
    end
    return false, nil
end
