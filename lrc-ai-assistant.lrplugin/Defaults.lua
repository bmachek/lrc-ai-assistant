Defaults = {}

Defaults.defaultTask = LOC "$$$/lrc-ai-assistant/Defaults/defaultTask=Describe the image contents, including all recognized objects."
Defaults.defaultSystemInstruction = LOC "$$$/lrc-ai-assistant/Defaults/defaultSystemInstruction=You are classifying images for photo management. Be very specific and detailed. Do not return more than 25 unique keywords."

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
    { title = "Google Gemini Pro 2.0 (experimental)", value = "gemini-2.0-pro-exp" },
    { title = "ChatGPT-4", value = "gpt-4o" },
    { title = "ChatGPT-4 Mini", value = "gpt-4o-mini" },
    { title = 'Ollama deepseek-r1', value = 'ollama-deepseek-r1' },
    { title = 'Ollama llama3.2-vision', value = 'ollama-llama3.2-vision' },
    { title = 'Ollama llava', value = 'ollama-llava' },
}

Defaults.exportSizes = {
    "512", "1024", "2048", "3072", "4096"
}

Defaults.baseUrls = {}
Defaults.baseUrls['gemini-1.5-flash'] = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key='
Defaults.baseUrls['gemini-1.5-pro'] = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key='
Defaults.baseUrls['gemini-2.0-flash'] = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key='
Defaults.baseUrls['gemini-2.0-pro-exp'] = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-pro-exp-02-05:generateContent?key='
Defaults.baseUrls['gpt-4o'] = 'https://api.openai.com/v1/chat/completions'
Defaults.baseUrls['gpt-4o-mini'] = 'https://api.openai.com/v1/chat/completions'
Defaults.baseUrls['ollama'] = 'http://localhost:11434/v1/chat/completions'

Defaults.pricing = {}
Defaults.pricing["gemini-1.5-pro"] = {}
Defaults.pricing["gemini-1.5-pro"].input = 3.5 / 1000000
Defaults.pricing["gemini-1.5-pro"].output= 10.5 / 1000000
Defaults.pricing["gemini-2.0-pro-exp"] = {}
Defaults.pricing["gemini-2.0-pro-exp"].input = 3.5 / 1000000
Defaults.pricing["gemini-2.0-pro-exp"].output= 10.5 / 1000000
Defaults.pricing["gemini-1.5-flash"] = {}
Defaults.pricing["gemini-1.5-flash"].input = 0.075 / 1000000
Defaults.pricing["gemini-1.5-flash"].output= 0.3 / 1000000
Defaults.pricing["gemini-2.0-flash"] = {}
Defaults.pricing["gemini-2.0-flash"].input = 0.075 / 1000000
Defaults.pricing["gemini-2.0-flash"].output= 0.3 / 1000000
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

function Defaults.getDefaultGeminiGenerationConfig()
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


function Defaults.getDefaultChatGPTGenerationConfig()
    local structure = {
        type = "OBJECT",
        properties = {},
        additionalProperties = false,
        required = {},
    }

    if prefs.generateCaption then
        log:trace('Generate caption is enabled.')
        structure.properties[LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageCaption=Image caption"] = { type = "STRING" }
        table.insert(structure.required, LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageCaption=Image caption")
    end

    if prefs.generateTitle then
        log:trace('Generate title is enabled.')
        structure.properties[LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageTitle=Image title"] = { type = "STRING" }
        table.insert(structure.required, LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageTitle=Image title")
    end

    if prefs.generateAltText then
        log:trace('Generate Alt Text is enabled.')
        structure.properties[LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageAltText=Image Alt Text"] = { type = "STRING" }
        table.insert(structure.required, LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageAltText=Image Alt Text")
    end

    if prefs.generateKeywords then
        log:trace('Generate keywords is enabled.')
        structure.properties.keywords = Defaults.keywordsGenerationConfig.keywords
        table.insert(structure.required, "keywords")
        structure.properties.keywords.additionalProperties = false
        structure.properties.keywords.required = { 
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
    end

    local generationConfig = {
        type = "json_schema",
        json_schema = {
            name = "results",
            strict = true,
            schema = structure,
        },
    }

    return generationConfig
end