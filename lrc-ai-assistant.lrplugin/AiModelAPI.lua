require "GeminiAPI"
require "ChatGptAPI"


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