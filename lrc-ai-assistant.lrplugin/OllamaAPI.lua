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

                        -- local modelInfo = OllamaAPI.getModelInfo(name)
                        -- if modelInfo ~= nil and type(modelInfo) == "table" then
                        --    if Util.table_contains(modelInfo.capabilities, "vision") then
                        --         log:trace(name .. " has capability vision! Adding it to the list of available models.")
                                 table.insert(ollamaModels, { title = "Ollama " .. name , value = 'ollama-' .. name })
                        --    else
                        --         log:trace(name .. " does not have capability vision! Not Adding it to the list of available models.")
                        --    end
                        -- end
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

    local keywords = Defaults.defaultKeywordCategories
    if prefs.keywordCategories ~= nil then
        if type(prefs.keywordCategories) == "table" then
            keywords = prefs.keywordCategories
        end
    end

    local systemInstruction = prefs.systemInstruction
    if #keywords >= 1 then
        systemInstruction = systemInstruction .. "\nPut the keywords in the following categories:"
        for _, keyword in ipairs(keywords) do
            systemInstruction = systemInstruction .. "\n * " .. keyword
        end
    end

    local success, result, inputTokenCount, outputTokenCount = self:doRequest(filePath, task, systemInstruction, ResponseStructure:new():generateResponseStructure())
    if success then
        return success, result, inputTokenCount, outputTokenCount
    end
    return false, "", inputTokenCount, outputTokenCount
end
