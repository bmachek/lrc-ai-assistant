GeminiAPI = {}


GeminiAPI.__index = GeminiAPI

function GeminiAPI:new()
    local o = setmetatable({}, GeminiAPI)
    self.rateLimitHit = 0

    if Util.nilOrEmpty(prefs.geminiApiKey) then
        Util.handleError('Gemini API key not configured.', LOC "$$$/lrc-ai-assistant/GeminiAPI/NoAPIkey=No Gemini API key configured in add-ons manager.")
        return nil
    else
        self.apiKey = prefs.geminiApiKey
    end

    self.url = Defaults.baseUrls[prefs.ai] .. self.apiKey
    self.model = prefs.ai

    return o
end

function GeminiAPI:doRequest(filePath, task, systemInstruction, generationConfig)
    if systemInstruction == nil then
        systemInstruction = Defaults.defaultSystemInstruction
    end

    local body = {
        system_instruction = {
            parts = {
                { text = systemInstruction },
            },
        },
        contents = {
            parts = {
                { text = task },
                {
                    inline_data = {
                        data = Util.encodePhotoToBase64(filePath),
                        mime_type = 'image/jpeg'
                    },
                }
            },
        },
        safety_settings = {
            {
                category = "HARM_CATEGORY_SEXUALLY_EXPLICIT",
                threshold = "BLOCK_NONE"
            },
            {
                category = "HARM_CATEGORY_HATE_SPEECH",
                threshold = "BLOCK_NONE"
            },
            {
                category = "HARM_CATEGORY_HARASSMENT",
                threshold = "BLOCK_NONE"
            },
            {
                category = "HARM_CATEGORY_DANGEROUS_CONTENT",
                threshold = "BLOCK_NONE"
            },
        },
    }

    if generationConfig ~= nil then
        body.generationConfig = generationConfig
    end

    log:trace(Util.dumpTable(body))

    local response, headers = LrHttp.post(self.url, JSON:encode(body), {{ field = 'Content-Type', value = 'application/json' },})

    if headers.status == 200 then
        self.rateLimitHit = 0
        if response ~= nil then
            log:trace(response)
            local decoded = JSON:decode(response)
            if decoded ~= nil then
                if decoded.promptFeedback ~=  nil then
                    log:error('Request blocked: ' .. decoded.promptFeedback.blockReason)
                    return false, decoded.promptFeedback.blockReason, decoded.usageMetadata.promptTokenCount, decoded.usageMetadata.candidatesTokenCount
                else
                    if decoded.candidates[1].finishReason == 'STOP' then
                        local text = decoded.candidates[1].content.parts[1].text
                        log:trace(text)
                        log:trace(decoded.usageMetadata.promptTokenCount)
                        log:trace(decoded.usageMetadata.candidatesTokenCount)
                        return true, text, decoded.usageMetadata.promptTokenCount, decoded.usageMetadata.candidatesTokenCount
                    else
                        log:error('Blocked: ' .. decoded.candidates[1].finishReason .. Util.dumpTable(decoded.candidates[1].safetyRatings))
                        return false, decoded.candidates[1].finishReason, decoded.usageMetadata.promptTokenCount, decoded.usageMetadata.candidatesTokenCount
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
            return false, 'RATE_LIMIT_EXHAUSTED', 0, 0
        end
        self:doRequest(filePath, task, systemInstruction, generationConfig)
    else
        log:error('GeminiAPI POST request failed.')
        log:error(Util.dumpTable(headers))
        log:error(response)
        return false, 'GeminiAPI POST request failed. ' .. self.url, 0, 0
    end
end


function GeminiAPI:analyzeImage(filePath, metadata)
    local task = Defaults.defaultTask
    if metadata ~= nil then
        if metadata.gps ~= nil then
            task = task .. " " .. LOC "$$$/lrc-ai-assistant/GeminiAPI/gpsAddon=This photo was taken at the following coordinates:" .. metadata.gps.latitude .. ", " .. metadata.gps.longitude
        end
        if metadata.keywords ~= nil then
            task = task .. " " .. LOC "$$$/lrc-ai-assistant/GeminiAPI/keywordAddon=Some keywords are:" .. metadata.keywords
        end
    end

    local success, result, inputTokenCount, outputTokenCount = GeminiAPI:doRequest(filePath, task, Defaults.defaultSystemInstruction, ResponseStructure:new():generateResponseStructure())
    if success and result ~= nil then
        result = string.gsub(result, Defaults.geminiKeywordsGarbageAtStart, '')
        result = string.gsub(result, Defaults.geminiKeywordsGarbageAtEnd, '')
        return success, JSON:decode(result), inputTokenCount, outputTokenCount
    end
    return false, result, inputTokenCount, outputTokenCount
end
