require "GeminiAPI"
require "ChatGptAPI"
require "OllamaAPI"
require "OpenWebuiAPI"


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
    elseif string.sub(prefs.ai, 1, 5) == 'llama' then
        self.usedApi = OllamaAPI:new()
        self.topKeyword = Defaults.ollamaTopKeyword
    elseif string.sub(prefs.ai, 1, 11) == 'open-webui-' then
        self.usedApi = OpenWebuiAPI:new()
        self.topKeyword = Defaults.openWebuiTopKeyword
    else
        Util.handleError('Configuration error: No valid AI model selected, check Module Manager for Configuration', LOC "$$$/lrc-ai-assistant/AiModelAPI/NoModelSelectedError=No AI model selected, check Configuration in Add-Ons manager")
    end

    

    if self.usedApi == nil then
        return nil
    end
    
    return instance
end

function AiModelAPI:analyzeImage(filePath)
    return self.usedApi:analyzeImage(filePath)
end