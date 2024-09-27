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
        util.handleError('Configuration error: No valid AI model selected, check Module Manager for Configuration', 'Configuration error: No valid AI model selected, check Module Manager for Configuration')
    end
    
    return instance
end


function AiModelAPI:imageTask(task, filePath)
    return self.usedApi:imageTask(task, filePath)
end

function AiModelAPI:keywordsTask(filePath)
    return self.usedApi:keywordsTask(filePath)
end