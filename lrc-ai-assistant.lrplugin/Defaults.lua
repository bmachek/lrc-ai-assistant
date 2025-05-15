Defaults = {}

Defaults.defaultTask = [[Analyze the uploaded photo and generate the following data:
]]

Defaults.defaultSystemInstruction = [[You are a professional photography analyst with expertise in object recognition and computer-generated image description. 
You also try to identify famous buildings and landmarks as well as the location where the photo was taken. 
Furthermore, you aim to specify animal and plant species as accurately as possible. 
You also describe objects—such as vehicle types and manufacturers—as specifically as you can.]]

Defaults.defaultGenerateLanguage = "English"

Defaults.generateLanguages = {
    { title = "English", value = "English" },
    { title = "German", value = "German" },
    { title = "French", value = "French" },
}

Defaults.defaultTemperature = 0.1

Defaults.defaultKeywordCategories = {
    LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Activities=Activities",
    LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Buildings=Buildings",
    LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Location=Location",
    LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Objects=Objects",
    LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/People=People",
    LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Moods=Moods",
    LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Sceneries=Sceneries",
    LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Texts=Texts",
    LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Companies=Companies",
    LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Weather=Weather",
    LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Plants=Plants",
    LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Animals=Animals",
    LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Vehicles=Vehicles",
}

Defaults.targetDataFields = {
    { title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/keywords=Keywords", value = "keyword" },
    { title = LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageTitle=Image title", value = "title" },
    { title = LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageCaption=Image caption", value = "caption" },
    { title = LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageAltText=Image Alt Text", value = "altTextAccessibility" },
}

local aiModels = {
    { title = "Google Gemini Pro 1.5", value = "gemini-1.5-pro" },
    { title = "Google Gemini Flash 2.0", value = "gemini-2.0-flash" },
    { title = "Google Gemini Flash 2.0 Lite", value = "gemini-2.0-flash-lite" },
    { title = "Google Gemini Pro 2.5 (experimental)", value = "gemini-2.5-pro-exp-03-25" },
    { title = "ChatGPT-4", value = "gpt-4o" },
    { title = "ChatGPT-4 Mini", value = "gpt-4o-mini" },
    { title = "ChatGPT 4.1", value = "gpt-4.1" },
    { title = "ChatGPT 4.1 Mini", value = "gpt-4.1-mini" },
    { title = "ChatGPT 4.1 Nano", value = "gpt-4.1-nano" },
    { title = "LMStudio gemma3-12b-mlx", value = "lmstudio-gemma-3-12b-it-qat-4bit" },
}

function Defaults.getAvailableAiModels()

    local result = {}
    for _, model in ipairs(aiModels) do
        table.insert(result, model)
    end

    local ollamaModels = OllamaAPI.getLocalVisionModels()
    if ollamaModels ~= nil then
        for _, model in ipairs(ollamaModels) do
            table.insert(result, model)
        end
    end

    log:trace("getAvailableAiModels: " .. Util.dumpTable(result))

    return result
end

Defaults.exportSizes = {
    "512", "1024", "2048", "3072", "4096"
}

Defaults.baseUrls = {}
Defaults.baseUrls['gemini-1.5-pro'] = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key='
Defaults.baseUrls['gemini-2.0-flash'] = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key='
Defaults.baseUrls['gemini-2.0-flash-lite'] = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent?key='
Defaults.baseUrls['gemini-2.5-pro-exp-03-25'] = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro-exp-03-25:generateContent?key='

Defaults.baseUrls['gpt-4o'] = 'https://api.openai.com/v1/responses'
Defaults.baseUrls['gpt-4o-mini'] = 'https://api.openai.com/v1/responses'

Defaults.baseUrls['gpt-4.1'] = 'https://api.openai.com/v1/responses'
Defaults.baseUrls['gpt-4.1-mini'] = 'https://api.openai.com/v1/responses'
Defaults.baseUrls['gpt-4.1-nano'] = 'https://api.openai.com/v1/responses'

Defaults.baseUrls['lmstudio'] = 'http://localhost:1234/v1/chat/completions'

Defaults.baseUrls['ollama'] = 'http://localhost:11434'
Defaults.ollamaGenerateUrl = '/api/generate'
Defaults.ollamaChatUrl = '/api/chat'
Defaults.ollamaListModelUrl = '/api/tags'
Defaults.ollamaModelInfoUrl = '/api/show'

Defaults.pricing = {}
Defaults.pricing["gemini-1.5-pro"] = {}
Defaults.pricing["gemini-1.5-pro"].input = 1.25 / 1000000
Defaults.pricing["gemini-1.5-pro"].output= 5 / 1000000
Defaults.pricing["gemini-2.5-pro-exp-03-25"] = {}
Defaults.pricing["gemini-2.5-pro-exp-03-25"].input = 3.5 / 1000000
Defaults.pricing["gemini-2.5-pro-exp-03-25"].output= 10.5 / 1000000
Defaults.pricing["gemini-2.0-flash"] = {}
Defaults.pricing["gemini-2.0-flash"].input = 0.1 / 1000000
Defaults.pricing["gemini-2.0-flash"].output= 0.4 / 1000000
Defaults.pricing["gemini-2.0-flash-lite"] = {}
Defaults.pricing["gemini-2.0-flash-lite"].input = 0.075 / 1000000
Defaults.pricing["gemini-2.0-flash-lite"].output= 0.3 / 1000000
Defaults.pricing["gpt-4o"] = {}
Defaults.pricing["gpt-4o"].input = 2.5 / 1000000
Defaults.pricing["gpt-4o"].output= 10 / 1000000
Defaults.pricing["gpt-4o-mini"] = {}
Defaults.pricing["gpt-4o-mini"].input = 0.15 / 1000000
Defaults.pricing["gpt-4o-mini"].output= 0.6 / 1000000

Defaults.pricing["gpt-4.1"] = {}
Defaults.pricing["gpt-4.1"].input = 2 / 1000000
Defaults.pricing["gpt-4.1"].output= 8 / 1000000

Defaults.pricing["gpt-4.1-mini"] = {}
Defaults.pricing["gpt-4.1-mini"].input = 0.4 / 1000000
Defaults.pricing["gpt-4.1-mini"].output= 1.6 / 1000000

Defaults.pricing["gpt-4.1-nano"] = {}
Defaults.pricing["gpt-4.1-nano"].input = 0.1 / 1000000
Defaults.pricing["gpt-4.1-nano"].output= 0.4 / 1000000


Defaults.defaultAiModel = "gpt-4.1-nano"

Defaults.defaultExportSize = "2048"
Defaults.defaultExportQuality = 50

Defaults.googleTopKeyword = 'Google Gemini'
Defaults.chatgptTopKeyword = 'ChatGPT'
Defaults.ollamaTopKeyWord = 'Ollama'
Defaults.lmStudioTopKeyWord = 'LMStudio'

Defaults.geminiKeywordsGarbageAtStart = '```json'
Defaults.geminiKeywordsGarbageAtEnd = '```'
