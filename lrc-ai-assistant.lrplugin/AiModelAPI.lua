
AiModelAPI = {}
AiModelAPI.__index = AiModelAPI

function AiModelAPI:new()
    local instance = setmetatable({}, AiModelAPI)

    if string.sub(prefs.ai, 1, 6) == 'gemini' then
        self.usedApi = GeminiAPI:new()
        self.topKeyword = Defaults.googleTopKeyword
    elseif string.sub(prefs.ai, 1, 3) == 'gpt' then
        self.usedApi = ChatGptAPI:new()
        self.topKeyword = Defaults.chatgptTopKeyword
    elseif string.sub(prefs.ai, 1, 6) == 'ollama' then
        self.usedApi = OllamaAPI:new()
        self.topKeyword = Defaults.ollamaTopKeyWord
    else
        Util.handleError('Configuration error: No valid AI model selected, check Module Manager for Configuration', LOC "$$$/lrc-ai-assistant/AiModelAPI/NoModelSelectedError=No AI model selected, check Configuration in Add-Ons manager")
    end

    

    if self.usedApi == nil then
        return nil
    end
    
    return instance
end

function AiModelAPI:analyzeImage(filePath, metadata)
    return self.usedApi:analyzeImage(filePath, metadata)
end


function AiModelAPI.addKeywordHierarchyToSystemInstruction()
    local keywords = Defaults.defaultKeywordCategories
    if prefs.keywordCategories ~= nil then
        if type(prefs.keywordCategories) == "table" then
            keywords = prefs.keywordCategories
        end
    end

    local systemInstruction = prefs.prompts[prefs.prompt]
    if systemInstruction == nil then
        log:trace("Configured prompt is nil, using defaults.")
        systemInstruction = Defaults.defaultSystemInstruction
    end
    if prefs.useKeywordHierarchy and #keywords >= 1 then
        systemInstruction = systemInstruction .. "\nPut the keywords in the following categories:"
        for _, keyword in ipairs(keywords) do
            systemInstruction = systemInstruction .. "\n * " .. keyword
        end
    end

    return systemInstruction
end

function AiModelAPI.generatePromptFromConfiguration()
    local result = Defaults.defaultTask
    if prefs.generateAltText then
        result = result .. "* Alt text (with context for screen readers)\n"
    end
    if prefs.generateCaption then
        result = result .. "* Image caption\n"
    end
    if prefs.generateTitle then
        result = result .. "* Image title\n"
    end
    if prefs.generateKeywords then
        result = result .. "* Keywords\n"
    end

    result = "\nAll results should be generated in " .. prefs.generateLanguage

    return result
end