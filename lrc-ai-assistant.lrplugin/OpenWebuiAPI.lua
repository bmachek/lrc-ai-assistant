OpenWebuiAPI = {}

OpenWebuiAPI.keywordTask = LOC "$$$/lrc-ai-assistant/OpenWebuiAPI/keywordTask=Generate keywords for the image contents, separated by comma."
OpenWebuiAPI.titleTask = LOC "$$$/lrc-ai-assistant/OpenWebuiAPI/titleTask=Generate an image title."
OpenWebuiAPI.captionTask = LOC "$$$/lrc-ai-assistant/OpenWebuiAPI/captionTask=Generate an image caption."
OpenWebuiAPI.altTextTask = LOC "$$$/lrc-ai-assistant/OpenWebuiAPI/altTextTask=Generate an image alt text."
OpenWebuiAPI.__index = OpenWebuiAPI

function OpenWebuiAPI:new()
    local o = setmetatable({}, OpenWebuiAPI)
    self.url = Defaults.baseUrls[prefs.ai]
    self.model = string.sub(prefs.ai, 12, -1) .. ":latest"

    if Util.nilOrEmpty(prefs.openwebuiApiKey) then
        Util.handleError('Open webui API key not configured.', LOC "$$$/lrc-ai-assistant/OpenWebuiAPI/NoAPIkey=No Open webui API key configured in add-ons manager.")
        return nil
    else
        self.apiKey = prefs.openwebuiApiKey
    end

    self.uploadHeaders = {
        { field = 'Authorization', value = 'Bearer ' .. self.apiKey },
        { field = 'Accept', value = 'application/json' },
    }

    self.queryHeaders = {
        { field = 'Authorization', value = 'Bearer ' .. self.apiKey },
        { field = 'Content-Type', value = 'application/json' },
        { field = 'Accept', value = 'application/json' },
    }

    return o
end

function OpenWebuiAPI:uploadFile(filePath)

    local encodedImage = Util.encodePhotoToBase64(filePath)

    local mimeChunks = {
        { name = 'file', fileName = LrPathUtils.leafName(filePath), contentType = 'application/octet-stream', value = encodedImage },
    }

    local response, headers = LrHttp.postMultipart(self.url .. "/v1/files/", mimeChunks, self.uploadHeaders)

    if headers.status == 200 then
        if response ~= nil then
            -- log:trace(response)
            local decoded = JSON:decode(response)
            if decoded ~= nil then
                if decoded.id ~= nil then
                    return true, decoded.id
                else
                    log:warn("OpenWebuiAPI: file id is nil")
                end
            else
                log:error('OpenWebuiAPI decoded response is nil')
            end
        else
            log:error('Got empty response from Open webui')
        end
    else
        log:error('OpenWebuiAPI POST request failed. ' .. self.url .. "/v1/files/")
        log:error(Util.dumpTable(headers))
        log:error(response)
        return false, nil
    end
end

function OpenWebuiAPI:doRequest(fileId, task)
    local body = {
        model = self.model,
        files = {
            {
                type = "file",
                id = fileId,
            }
        },
        messages = {
            {
                role = "user",
                content = task,
            }
        }
    }

    log:trace(Util.dumpTable(self.queryHeaders))
    log:trace(JSON:encode(body))

    local response, headers = LrHttp.post(self.url .. "/chat/completions", JSON:encode(body), self.queryHeaders)

    if headers.status == 200 then
        if response ~= nil then
            -- log:trace(response)
            local decoded = JSON:decode(response)
            if decoded ~= nil then
                if decoded.choices[1].message.content ~= nil then
                    log:trace(decoded.choices[1].message.content)
                    return decoded.choices[1].message.content
                else
                    log:warn("OpenWebuiAPI: answer is nil")
                end
            else
                log:error('OpenWebuiAPI decoded response is nil')
            end
        else
            log:error('Got empty response from Google')
        end
    else
        log:error('OpenWebuiAPI POST request failed. ' .. self.url .. "/chat/completions")
        log:error(Util.dumpTable(headers))
        log:error(response)
        return false, nil
    end
end


function OpenWebuiAPI:analyzeImage(filePath)
    local combinedResult = {}
    local keywordSuccess = false
    local titleSuccess = false
    local altTextSuccess = false
    local captionSuccess = false
    local keywordResult, titleResult, altTextResult, captionResult
    
    local uploadSuccess, fileId = OpenWebuiAPI:uploadFile(filePath)

    if not uploadSuccess then
        log:error("Error uploading image to Open webui")
        return false, nil
    else
        log:trace("Upload successful with fileId: " .. fileId)
    end

    if prefs.generateKeywords then
        keywordSuccess, keywordResult = OpenWebuiAPI:doRequest(fileId, OpenWebuiAPI.keywordTask)
    end
    if prefs.generateTitle then
        titleSuccess, titleResult = OpenWebuiAPI:doRequest(fileId, OpenWebuiAPI.titleTask)
    end
    if prefs.generateCaption then
        captionSuccess, captionResult = OpenWebuiAPI:doRequest(fileId, OpenWebuiAPI.captionTask)
    end
    if prefs.generateAltText then
        altTextSuccess, altTextResult = OpenWebuiAPI:doRequest(fileId, OpenWebuiAPI.altTextTask)
    end

    if keywordSuccess or titleSuccess or captionSuccess or altTextResult then
        if keywordSuccess then
            -- combinedResult.keywords = keywordResult
            combinedResult.keywords = Util.string_split(keywordResult, ",")
        end
        if titleSuccess then
            combinedResult[LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageTitle=Image title"] = titleResult
        end
        if captionSuccess then
            combinedResult[LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageCaption=Image caption"] = captionResult
        end
        if altTextSuccess then
            combinedResult[LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageAltText=Image Alt Text"] = altTextResult
        end
        log:trace(Util.dumpTable(combinedResult))
        return true, combinedResult
    else
        log:error('All OpenWebuiAPI requests failed')
        return false, nil
    end
end
