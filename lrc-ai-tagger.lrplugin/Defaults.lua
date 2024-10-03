Defaults = {}

-- Defaults.defaultDatabaseFilepath = LrPathUtils.parent(LrApplication.activeCatalog():getPath()) .. "lrc-ai-tagger.db"
Defaults.defaultTask = 'Describe the image contents very detailed.'
Defaults.defaultSystemInstruction = 'Always generate caption and title and keywords. Rate image asthetics in percent. Be specific. Do not make any assumptions.'


Defaults.defaultResponseStructure = {
    English = {
        type = "OBJECT",
        properties = {
            keywords = {
                type = "OBJECT",
                properties = {
                    Activities = {
                        type = "ARRAY",
                        items = {
                            type = "STRING"
                        },
                    },
                    Buildings = {
                        type = "ARRAY",
                        items = {
                            type = "STRING"
                        },
                    },
                    Location = {
                        type = "ARRAY",
                        items = {
                            type = "STRING"
                        },
                    },
                    Objects = {
                        type = "ARRAY",
                        items = {
                            type = "STRING"
                        },
                    },
                    People = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    Moods = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    Sceneries = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    Texts = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    Companies = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    Weather = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    Plants = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    Animals = {
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
            ImageRatinginPercent = {
                type = "STRING",
            },
        },
    },

    German = {
        type = "OBJECT",
        properties = {
            keywords = {
                type = "OBJECT",
                properties = {
                    ["Aktivitäten"] = {
                        type = "ARRAY",
                        items = {
                            type = "STRING"
                        },
                    },
                    ["Gebäude"] = {
                        type = "ARRAY",
                        items = {
                            type = "STRING"
                        },
                    },
                    Ort = {
                        type = "ARRAY",
                        items = {
                            type = "STRING"
                        },
                    },
                    ["Gegenstände"] = {
                        type = "ARRAY",
                        items = {
                            type = "STRING"
                        },
                    },
                    Menschen = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    Stimmung = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    Texte = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    Firmen = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    Wetter = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    Tiere = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    Pflanzen = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                },
            },
            ImageCaption = {
                type = "STRING",
            },
            ImageTitle = {
                type = "STRING",
            },
            ImageRatinginPercent = {
                type = "STRING",
            },
        },
    },
}




Defaults.aiModels = {
    { title = "Google Gemini Flash 1.5", value = "gemini-1.5-flash" },
    { title = "Google Gemini Pro 1.5", value = "gemini-1.5-pro" },
--    { title = "ChatGPT-4", value = "gpt-4o" },
}

Defaults.generateLanguages = {
    { title = "English", value = "English" },
    { title = "German", value = "German" },
}

Defaults.defaultGenerateLanguage = 'English'

Defaults.defaultAiModel = "gemini-1.5-flash"

Defaults.googleTopKeyword = 'Google Gemini'
Defaults.chatgptTopKeyword = 'ChatGPT'

Defaults.geminiKeywordsGarbageAtStart = '```json'
Defaults.geminiKeywordsGarbageAtEnd = '```'

function Defaults.getDefaultGenerationConfig(language)
    local generationConfig = {
        response_mime_type = "application/json",
        response_schema = Defaults.defaultResponseStructure[language],
    }

    return generationConfig
end