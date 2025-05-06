OllamaAPI = {}
OllamaAPI.__index = OllamaAPI

function OllamaAPI.getModelInfo(model)
    local body = { model = model }

    local response, headers = LrHttp.post(Defaults.ollamaModelInfoUrl, JSON:encode(body))

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
        log:error('OllamaAPI POST request failed. ' .. Defaults.ollamaModelInfoUrl)
        log:error(Util.dumpTable(headers))
        log:error(response)
        return nil
    end
    return nil
end


function OllamaAPI.getLocalVisionModels()
    local response, headers = LrHttp.get(Defaults.ollamaListModelUrl)

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
        log:error('OllamaAPI GET request failed. ' .. Defaults.ollamaListModelUrl)
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
    self.url = Defaults.baseUrls.ollama

    return o
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
    local task = prefs.task
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
        return success, result, inputTokenCount, outputTokenCount
    end
    return false, "", inputTokenCount, outputTokenCount
end
