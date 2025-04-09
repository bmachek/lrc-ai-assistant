Defaults = {}

Defaults.defaultTask = LOC "$$$/lrc-ai-assistant/Defaults/defaultTask=Describe the image contents, including all recognized objects."
Defaults.defaultSystemInstruction = LOC "$$$/lrc-ai-assistant/Defaults/defaultSystemInstruction=You are classifying images for photo management. Be very specific and detailed."

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

Defaults.defaultKeywordHierarchy = {
    [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Activities=Activities"] = {},
    [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Location=Location"] = {},
    [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Objects=Objects"] = {
        [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Vehicles=Vehicles"] = {},
        [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Buildings=Buildings"] = {},

    },
    [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/People=People"] = {},
    [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Moods=Moods"] = {},
    [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Sceneries=Sceneries"] = {},
    [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Texts=Texts"] = {},
    [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Companies=Companies"] = {},
    [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Weather=Weather"] = {},
    [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Nature=Nature"] = {
        [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Plants=Plants"] = {},
        [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Animals=Animals"] = {},
    },
}

setmetatable(Defaults.defaultKeywordHierarchy, {
    __index = function(t, k)
        if type(k) == "table" then
            log:trace("Trying to access nested table: " .. Util.dumpTable(k))
            for i,v in ipairs(k) do
                if not t then error("attempt to index nil") end
                t = rawget(t, v)
            end
            log:trace("Returning nested table: " .. Util.dumpTable(t))
            return t
        else
            log:trace("Trying to access value: " .. k)
            if rawget(t, k) ~= nil then
                log:trace("Returning value: " .. rawget(t, k))
            end
            return rawget(t, k)
        end
    end
    }
)


Defaults.targetDataFields = {
    { title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/keywords=Keywords", value = "keyword" },
    { title = LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageTitle=Image title", value = "title" },
    { title = LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageCaption=Image caption", value = "caption" },
    { title = LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageAltText=Image Alt Text", value = "altTextAccessibility" },
}

Defaults.aiModels = {
    { title = "Google Gemini Pro 1.5", value = "gemini-1.5-pro" },
    { title = "Google Gemini Flash 2.0", value = "gemini-2.0-flash" },
    { title = "Google Gemini Flash 2.0 Lite", value = "gemini-2.0-flash-lite" },
    { title = "Google Gemini Pro 2.5 (experimental)", value = "gemini-2.5-pro-exp-03-25" },
    { title = "ChatGPT-4", value = "gpt-4o" },
    { title = "ChatGPT-4 Mini", value = "gpt-4o-mini" },
    { title = 'Ollama deepseek-r1', value = 'ollama-deepseek-r1' },
    { title = 'Ollama llama3.2-vision', value = 'ollama-llama3.2-vision' },
    { title = 'Ollama llava', value = 'ollama-llava' },
    { title = 'Ollama gemma3', value = 'ollama-gemma3' },
    { title = 'Ollama mistral-small3.1', value = 'ollama-mistral-small3.1' },
}

Defaults.exportSizes = {
    "512", "1024", "2048", "3072", "4096"
}

Defaults.baseUrls = {}
Defaults.baseUrls['gemini-1.5-pro'] = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key='
Defaults.baseUrls['gemini-2.0-flash'] = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key='
Defaults.baseUrls['gemini-2.0-flash-lite'] = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent?key='
Defaults.baseUrls['gemini-2.5-pro-exp-03-25'] = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro-exp-03-25:generateContent?key='
Defaults.baseUrls['gpt-4o'] = 'https://api.openai.com/v1/chat/completions'
Defaults.baseUrls['gpt-4o-mini'] = 'https://api.openai.com/v1/chat/completions'
Defaults.baseUrls['ollama'] = 'http://localhost:11434/v1/chat/completions'

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


Defaults.defaultAiModel = "gpt-4o-mini"

Defaults.defaultExportSize = "2048"
Defaults.defaultExportQuality = 50

Defaults.googleTopKeyword = 'Google Gemini'
Defaults.chatgptTopKeyword = 'ChatGPT'
Defaults.ollamaTopKeyWord = 'Ollama'

Defaults.geminiKeywordsGarbageAtStart = '```json'
Defaults.geminiKeywordsGarbageAtEnd = '```'
