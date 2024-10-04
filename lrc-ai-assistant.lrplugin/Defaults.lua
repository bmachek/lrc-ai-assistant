Defaults = {}

Defaults.defaultTask = LOC "$$$/lrc-ai-assistant/Defaults/defaultTask=Describe the image contents."
Defaults.defaultSystemInstruction = LOC "$$$/lrc-ai-assistant/Defaults/defaultSystemInstruction=Always generate caption and title and keywords. Be very specific an detailed."

Defaults.defaultResponseStructure = {
    type = "OBJECT",
    properties = {
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
        ImageCaption =  {
            type = "STRING",
        },
        ImageTitle =  {
            type = "STRING",
        },
        -- ImageRatinginPercent = {
        --     type = "STRING",
        -- },
    },
}



Defaults.aiModels = {
    { title = "Google Gemini Flash 1.5", value = "gemini-1.5-flash" },
    { title = "Google Gemini Pro 1.5", value = "gemini-1.5-pro" },
--    { title = "ChatGPT-4", value = "gpt-4o" },
}

Defaults.pricing = {}
Defaults.pricing["gemini-1.5-pro"] = {}
Defaults.pricing["gemini-1.5-pro"].input = 3.5 / 1000000
Defaults.pricing["gemini-1.5-pro"].output= 10.5 / 1000000
Defaults.pricing["gemini-1.5-flash"] = {}
Defaults.pricing["gemini-1.5-flash"].input = 0.075 / 1000000
Defaults.pricing["gemini-1.5-flash"].output= 0.3 / 1000000

Defaults.defaultAiModel = "gemini-1.5-flash"

Defaults.googleTopKeyword = 'Google Gemini'
Defaults.chatgptTopKeyword = 'ChatGPT'

Defaults.geminiKeywordsGarbageAtStart = '```json'
Defaults.geminiKeywordsGarbageAtEnd = '```'

function Defaults.getDefaultGenerationConfig()
    local generationConfig = {
        response_mime_type = "application/json",
        response_schema = Defaults.defaultResponseStructure,
    }

    return generationConfig
end