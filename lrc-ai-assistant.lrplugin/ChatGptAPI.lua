ChatGptAPI = {}
ChatGptAPI.__index = ChatGptAPI

function ChatGptAPI:new()
    local o = setmetatable({}, ChatGptAPI)

    if Util.nilOrEmpty(prefs.chatgptApiKey) then
        Util.handleError('ChatGPT API key not configured.', LOC "$$$/lrc-ai-assistant/ChatGptAPI/NoAPIkey=No ChatGPT API key configured in Add-Ons manager.")
        return nil
    else
        self.apiKey = prefs.chatgptApiKey
    end

    self.model = prefs.ai

    self.url = Defaults.baseUrls[self.model]

    return o
end

function ChatGptAPI:doRequest(filePath, task, systemInstruction, generationConfig)
    local body = {
        model = self.model,
        response_format = generationConfig,
        messages = {
            {
                role = "system",
                content = systemInstruction,
            },
            {
                role = "user",
                content = task,
            },
            {
                role = "user",
                content = {
                    {
                        type = "image_url",
                        image_url = {
                            url = "data:image/jpeg;base64," .. Util.encodePhotoToBase64(filePath)
                        }
                    }
                }
            }
        },
        temperature = prefs.temperature,
    }

    log:trace(Util.dumpTable(body))

    local response, headers = LrHttp.post(self.url, JSON:encode(body), {{ field = 'Content-Type', value = 'application/json' },  { field = 'Authorization', value = 'Bearer ' .. self.apiKey }})

    if headers.status == 200 then
        if response ~= nil then
            log:trace(response)
            local decoded = JSON:decode(response)
            if decoded ~= nil then
                    if decoded.choices ~= nil then
                        if decoded.choices[1].finish_reason == 'stop' then
                            local text = decoded.choices[1].message.content
                            local inputTokenCount = decoded.usage.prompt_tokens
                            local outputTokenCount = decoded.usage.completion_tokens
                            log:trace(text)
                            return true, text, inputTokenCount, outputTokenCount
                        end
                    else
                        log:error('Blocked: ' .. decoded.choices[1].finish_reason .. Util.dumpTable(decoded.choices[1]))
                        local inputTokenCount = decoded.usage.prompt_tokens
                        local outputTokenCount = decoded.usage.completion_tokens
                        return false,  decoded.choices[1].finish_reason, inputTokenCount, outputTokenCount
                    end
            end
        else
            log:error('Got empty response from ChatGPT')
        end
    else
        log:error('ChatGptAPI POST request failed. ' .. self.url)
        log:error(Util.dumpTable(headers))
        log:error(response)
        return false, 'ChatGptAPI POST request failed. ' .. self.url, 0, 0 
    end
end


function ChatGptAPI:analyzeImage(filePath, metadata)
    local task = AiModelAPI.generatePromptFromConfiguration()
    if metadata ~= nil then
        if prefs.submitGPS and metadata.gps ~= nil then
            task = task .. " " .. "\nThis photo was taken at the following coordinates:" .. metadata.gps.latitude .. ", " .. metadata.gps.longitude
        end
        if prefs.submitKeywords and metadata.keywords ~= nil then
            task = task .. " " .. "\nSome keywords are:" .. metadata.keywords
        end
        if metadata.context ~= nil and metadata.context ~= "" then
            log:trace("Preflight context given")
            task = task .. "\nSome context for this photo: " .. metadata.context
        end
    end

    local systemInstruction = AiModelAPI.addKeywordHierarchyToSystemInstruction()

    local success, result, inputTokenCount, outputTokenCount = self:doRequest(filePath, task, systemInstruction, ResponseStructure:new():generateResponseStructure())
    if success then
        return success, JSON:decode(result), inputTokenCount, outputTokenCount
    end
    return false, "", inputTokenCount, outputTokenCount
end
