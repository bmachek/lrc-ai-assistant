OllamaAPI = {}

OllamaAPI.keywordTask = LOC "$$$/lrc-ai-assistant/OllamaAPI/keywordTask=Generate keywords for the image contents, separated by comma."
OllamaAPI.titleTask = LOC "$$$/lrc-ai-assistant/OllamaAPI/titleTask=Generate an image title."
OllamaAPI.captionTask = LOC "$$$/lrc-ai-assistant/OllamaAPI/captionTask=Generate an image caption."
OllamaAPI.altTextTask = LOC "$$$/lrc-ai-assistant/OllamaAPI/altTextTask=Generate an image alt text."
OllamaAPI.__index = OllamaAPI

function OllamaAPI:new()
    local o = setmetatable({}, OllamaAPI)
    self.url = Defaults.baseUrls[prefs.ai]
    self.model = prefs.ai
    return o
end

function OllamaAPI:doRequest(filePath, task)
    local body = {
        model = self.model,
        stream = false,
        format = "json",
        prompt = task,
        images = { Util.encodePhotoToBase64(filePath) },
    }

    log:trace(Util.dumpTable(body))
    local response, headers = LrHttp.post(self.url, JSON:encode(body))

    if headers.status == 200 then
        if response ~= nil then
            log:trace(response)
            local decoded = JSON:decode(response)
            if decoded ~= nil then
                if decoded.response ~= nil then
                    return decoded.response
                else
                    log:warn("OllamaAPI: answer is nil")
                end
            else
                log:error('OllamaAPI decoded response is nil')
            end
        else
            log:error('Got empty response from Google')
        end
    else
        log:error('OllamaAPI POST request failed. ' .. self.url)
        log:error(Util.dumpTable(headers))
        log:error(response)
        return false, nil
    end
end


function OllamaAPI:analyzeImage(filePath)
    local combinedResult = {}
    local keywordSuccess = false
    local titleSuccess = false
    local altTextSuccess = false
    local captionSuccess = false
    local keywordResult, titleResult, altTextResult, captionResult
    
    if prefs.generateKeywords then
        keywordSuccess, keywordResult = OllamaAPI:doRequest(filePath, OllamaAPI.keywordTask)
    end
    if prefs.generateTitle then
        titleSuccess, titleResult = OllamaAPI:doRequest(filePath, OllamaAPI.titleTask)
    end
    if prefs.generateCaption then
        captionSuccess, captionResult = OllamaAPI:doRequest(filePath, OllamaAPI.captionTask)
    end
    if prefs.generateAltText then
        altTextSuccess, altTextResult = OllamaAPI:doRequest(filePath, OllamaAPI.altTextTask)
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
        log:trace(combinedResult)
        return true, combinedResult
    else
        log:error('All OllamaAPI requests failed')
        return false, nil
    end
end
