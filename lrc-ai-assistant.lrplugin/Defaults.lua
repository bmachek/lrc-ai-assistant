Defaults = {}

Defaults.defaultTask = LOC "$$$/lrc-ai-assistant/Defaults/defaultTask=Describe the image contents, including all recognized objects."
Defaults.defaultSystemInstruction = LOC "$$$/lrc-ai-assistant/Defaults/defaultSystemInstruction=You are classifying images for photo management. Be very specific an detailed. Do not return more than 25 unique keywords."

Defaults.keywordsGenerationConfig = {
    keywords = {
        type = "OBJECT",
        properties = {
            [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Activities=Activities"] = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Buildings=Buildings"] = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Location=Location"] = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Objects=Objects"] = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/People=People"] = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Moods=Moods"] = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Sceneries=Sceneries"] = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Texts=Texts"] = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Companies=Companies"] = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Weather=Weather"] = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Plants=Plants"] = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Animals=Animals"] = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            [LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/keywords/Vehicles=Vehicles"] = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
        },
    },
}

Defaults.aiModels = {
    { title = "Google Gemini Flash 1.5", value = "gemini-1.5-flash" },
    { title = "Google Gemini Pro 1.5", value = "gemini-1.5-pro" },
    { title = "Google Gemini Flash 2.0", value = "gemini-2.0-flash" },
--     { title = "Google Gemini Pro 1.5-002", value = "gemini-1.5-pro-002" },
--    { title = "ChatGPT-4", value = "gpt-4o" },
}

Defaults.baseUrls = {}
Defaults.baseUrls['gemini-1.5-flash'] = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key='
Defaults.baseUrls['gemini-1.5-pro'] = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key='
Defaults.baseUrls['gemini-2.0-flash'] = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key='

Defaults.pricing = {}
Defaults.pricing["gemini-1.5-pro"] = {}
Defaults.pricing["gemini-1.5-pro"].input = 3.5 / 1000000
Defaults.pricing["gemini-1.5-pro"].output= 10.5 / 1000000
Defaults.pricing["gemini-1.5-flash"] = {}
Defaults.pricing["gemini-1.5-flash"].input = 0.075 / 1000000
Defaults.pricing["gemini-1.5-flash"].output= 0.3 / 1000000
Defaults.pricing["gemini-2.0-flash"] = {}
Defaults.pricing["gemini-2.0-flash"].input = 0.075 / 1000000
Defaults.pricing["gemini-2.0-flash"].output= 0.3 / 1000000

Defaults.defaultAiModel = "gemini-2.0-flash"

Defaults.googleTopKeyword = 'Google Gemini'
Defaults.chatgptTopKeyword = 'ChatGPT'

Defaults.geminiKeywordsGarbageAtStart = '```json'
Defaults.geminiKeywordsGarbageAtEnd = '```'

function Defaults.getDefaultGenerationConfig()
    local structure = {
        type = "OBJECT",
        properties = {}
    }

    if prefs.generateCaption then
        log:trace('Generate caption is enabled.')
        structure.properties[LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageCaption=Image caption"] = { type = "STRING" }

    end

    if prefs.generateTitle then
        log:trace('Generate title is enabled.')
        structure.properties[LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageTitle=Image title"] = { type = "STRING" }
    end

    if prefs.generateAltText then
        log:trace('Generate Alt Text is enabled.')
        structure.properties[LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageAltText=Image Alt Text"] = { type = "STRING" }
    end

    if prefs.generateKeywords then
        log:trace('Generate keywords is enabled.')
        structure.properties.keywords = Defaults.keywordsGenerationConfig.keywords
    end

    local generationConfig = {
        response_mime_type = "application/json",
        response_schema = structure,
    }

    return generationConfig
end