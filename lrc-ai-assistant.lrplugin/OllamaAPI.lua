OllamaAPI = {}
OllamaAPI.__index = OllamaAPI

function OllamaAPI:new()
    local o = setmetatable({}, OllamaAPI)
    self.model = prefs.ai
    self.ollamaModel = string.sub(prefs.ai, 8, -1)
    self.url = Defaults.baseUrls.ollama

    return o
end

function OllamaAPI:doRequest(filePath, task, systemInstruction, generationConfig)
    local body = {
        model = self.ollamaModel,
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
        }
    }

    log:trace(Util.dumpTable(body))

    local response, headers = LrHttp.post(self.url, JSON:encode(body), {{ field = 'Content-Type', value = 'application/json' }})

    if headers.status == 200 then
        if response ~= nil then
            log:trace(response)
            local decoded = JSON:decode(response)
            if decoded ~= nil then
                if decoded.choices[1].finish_reason == 'stop' then
                    local text = JSON:decode(decoded.choices[1].message.content)
                    log:trace(Util.dumpTable(text))
                    log:trace(text)
                    return true, text, 0, 0
                else
                    log:error('Blocked: ' .. decoded.choices[1].finish_reason .. Util.dumpTable(decoded.choices[1]))
                    return false,  decoded.choices[1].finish_reason, 0, 0
                end
            end
        else
            log:error('Got empty response from ChatGPT')
        end
    else
        log:error('OllamaAPI POST request failed. ' .. self.url)
        log:error(Util.dumpTable(headers))
        log:error(response)
        return false, nil, 0, 0
    end
end


function OllamaAPI:analyzeImage(filePath, metadata)
    local task = Defaults.defaultTask
    if metadata ~= nil then
        if metadata.gps ~= nil then
            task = task .. " " .. LOC "$$$/lrc-ai-assistant/ChatGptAPI/gpsAddon=This photo was taken at the following coordinates:" .. metadata.gps.latitude .. ", " .. metadata.gps.longitude
        end
        if metadata.keywords ~= nil then
            task = task .. " " .. LOC "$$$/lrc-ai-assistant/ChatGptAPI/keywordAddon=Some keywords are:" .. metadata.keywords
        end
        if metadata.context ~= nil and metadata.context ~= "" then
            log:trace("Preflight context given")
            task = task .. " " .. metadata.context
        end
    end

    local success, result, inputTokenCount, outputTokenCount = self:doRequest(filePath, task, Defaults.defaultSystemInstruction, ResponseStructure:new():generateResponseStructure())
    if success then
        return success, result, inputTokenCount, outputTokenCount
    end
    return false, "", inputTokenCount, outputTokenCount
end
