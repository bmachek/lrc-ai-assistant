OllamaAPI = {}
OllamaAPI.__index = OllamaAPI

function OllamaAPI.getModelInfo(model)
    local body = { model = model }

    local response, headers = LrHttp.post(prefs.ollamaBaseUrl .. Defaults.ollamaModelInfoUrl, JSON:encode(body))

    if headers.status == 200 then
        if response ~= nil then
            -- log:trace(response) -- This bloats the log file.
            local decoded = JSON:decode(response)
            if decoded ~= nil then
                return decoded
            end
        else
            log:error('Got empty response from Ollama')
        end
    else
        log:error('OllamaAPI POST request failed. ' .. prefs.ollamaBaseUrl .. Defaults.ollamaModelInfoUrl)
        log:error(Util.dumpTable(headers))
        log:error(response)
        return nil
    end
    return nil
end


function OllamaAPI.getLocalVisionModels()
    local response, headers = LrHttp.get(prefs.ollamaBaseUrl .. Defaults.ollamaListModelUrl)

    if headers.status == 200 then
        if response ~= nil then
            log:trace(response)
            local decoded = JSON:decode(response)
            if decoded ~= nil then
                local ollamaModels = {}
                if decoded.models ~= nil and type(decoded.models) == "table" then
                    for _, model in ipairs(decoded.models) do
                        local name = model.name
                        log:trace("Found local installed Ollama model: " .. name)

                        local modelInfo = OllamaAPI.getModelInfo(name)
                        if modelInfo ~= nil and type(modelInfo) == "table" then
                           if Util.table_contains(modelInfo.capabilities, "vision") then
                                log:trace(name .. " has capability vision! Adding it to the list of available models.")
                                 table.insert(ollamaModels, { title = "Ollama " .. name , value = 'ollama-' .. name })
                           else
                                log:trace(name .. " does not have capability vision! Not Adding it to the list of available models.")
                           end
                        end
                    end
                end
                return ollamaModels
            end
        else
            log:error('Got empty response from Ollama')
        end
    else
        log:error('OllamaAPI GET request failed. ' .. prefs.ollamaBaseUrl .. Defaults.ollamaListModelUrl)
        log:error(Util.dumpTable(headers))
        log:error(response)
        return nil
    end
    return nil
end

function OllamaAPI:new()
    local o = setmetatable({}, OllamaAPI)
    self.model = prefs.ai
    self.ollamaModel = string.sub(prefs.ai, 8, -1)
    self.url = prefs.ollamaBaseUrl .. Defaults.ollamaGenerateUrl
    self.chatUrl = prefs.ollamaBaseUrl .. Defaults.ollamaChatUrl

    return o
end

function OllamaAPI:doRequestViaChat(filePath, task, systemInstruction, generationConfig)
    local body = {
        model = self.ollamaModel,
        format = generationConfig,
        messages = {
            {
                role = "system",
                content = systemInstruction,
            },
            {
                role = "user",
                content = task,
                images = { Util.encodePhotoToBase64(filePath) }
            },
        },
        options = {
            temperature = prefs.temperature,
            num_keep = -1,
        },
        stream = false,

    }

    -- log:trace(Util.dumpTable(body))

    local response, headers = LrHttp.post(self.chatUrl, JSON:encode(body), {{ field = 'Content-Type', value = 'application/json' }})

    if headers.status == 200 then
        if response ~= nil then
            log:trace(response)
            local decoded = JSON:decode(response)
            if decoded ~= nil then
                if decoded.done_reason == 'stop' then
                    local text = JSON:decode(decoded.message.content)
                    log:trace(Util.dumpTable(text))
                    return true, text, 0, 0
                else
                    if decoded.done_reason ~= nil then
                        log:error('Unsuccessful: ' .. decoded.done_reason .. Util.dumpTable(decoded.response))
                        return false, decoded.done_reason, 0, 0
                    else
                        return false, "done_reason is nil", 0, 0
                    end
                end
            end
        else
            log:error('Got empty response from Ollama')
        end
    else
        log:error('OllamaAPI POST request failed. ' .. self.url)
        log:error(Util.dumpTable(headers))
        log:error(response)
        return false, nil, 0, 0
    end
end

function OllamaAPI:doRequest(filePath, task, systemInstruction, generationConfig)
    local body = {
        model = self.ollamaModel,
        format = generationConfig,
        stream = false,
        options = { temperature = prefs.temperature, },
        prompt = task .. "\n" .. systemInstruction,
        images = { },
    }

    log:trace(Util.dumpTable(body))

    body.images = { Util.encodePhotoToBase64(filePath) }

    local response, headers = LrHttp.post(self.url, JSON:encode(body), {{ field = 'Content-Type', value = 'application/json' }})

    if headers.status == 200 then
        if response ~= nil then
            log:trace(response)
            local decoded = JSON:decode(response)
            if decoded ~= nil then
                if decoded.done_reason == 'stop' then
                    local text = JSON:decode(decoded.response)
                    log:trace(Util.dumpTable(text))
                    log:trace(text)
                    return true, text, 0, 0
                else
                    log:error('Blocked: ' .. decoded.done_reason .. Util.dumpTable(decoded.response))
                    return false,  decoded.done_reason, 0, 0
                end
            end
        else
            log:error('Got empty response from Ollama')
        end
    else
        log:error('OllamaAPI POST request failed. ' .. self.url)
        log:error(Util.dumpTable(headers))
        log:error(response)
        return false, nil, 0, 0
    end
end


function OllamaAPI:analyzeImage(filePath, metadata)
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

    local success, result, inputTokenCount, outputTokenCount = self:doRequestViaChat(filePath, task, systemInstruction, ResponseStructure:new():generateResponseStructure())
    if success then
        return success, result, inputTokenCount, outputTokenCount
    end
    return false, "", inputTokenCount, outputTokenCount
end
