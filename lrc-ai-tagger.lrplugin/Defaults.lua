Defaults = {}

Defaults.defaultSystemInstruction = 'Answer appropriate for photo organization. Only one candidate.'
Defaults.defaultCaptionTask = 'Generate a detailed image caption'
Defaults.defaultTitleTask = 'Generate one image title'

Defaults.defaultKeywordsTask = 'Describe the image contents very detailed and precise.'
Defaults.defaultKeywordsSystemInstruction = 'Give keywords, according to given structure. Be as specific as possible. This is for image organisation.'


Defaults.defaultKeywordHierarchy = {
    English = {
        type = "OBJECT",
        properties = {
            activities = {
                type = "OBJECT",
                properties = {
                    sports = {
                        type = "ARRAY",
                        items = {
                            type = "STRING"
                        },
                    },
                    hobbies = {
                        type = "ARRAY",
                        items = {
                            type = "STRING"
                        },
                    },
                    occupations = {
                        type = "ARRAY",
                        items = {
                            type = "STRING"
                        },
                    },
                },
            },
            buildings = {
                type = "OBJECT",
                properties = {
                    names = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    kind = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                },
            },
            location = {
                type = "OBJECT",
                properties = {
                    countries = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    types = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                },
            },
            objects = {
                type = "OBJECT",
                properties = {
                    things = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    materials = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    brands = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    plants  = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    vehicles = {
                        type = "OBJECT",
                        properties = {
                            brands = {
                                type = "ARRAY",
                                items = { type = "STRING" },
                            },
                            models = {
                                type = "ARRAY",
                                items = { type = "STRING" },
                            },
                            kind = {
                                type = "ARRAY",
                                items = { type = "STRING" },
                            },
                            color = {
                                type = "ARRAY",
                                items = { type = "STRING" },
                            },
                        },
                    },
                    animals = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                },
            },
            persons = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            moods = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            sceneries = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            stylistic = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            texts = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            photographic_categories = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            companies = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            weather = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            topics = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            colors = {
                type = "ARRAY",
                items = { type = "STRING" },
            }
        },
    },

    German = {
        type = "OBJECT",
        properties = {
            Aktivitaeten = {
                type = "OBJECT",
                properties = {
                    Sportarten = {
                        type = "ARRAY",
                        items = {
                            type = "STRING"
                        },
                    },
                    Hobbys = {
                        type = "ARRAY",
                        items = {
                            type = "STRING"
                        },
                    },
                    Beruf = {
                        type = "ARRAY",
                        items = {
                            type = "STRING"
                        },
                    },
                },
            },
            Gebaeude = {
                type = "OBJECT",
                properties = {
                    Namen = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    Art = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                },
            },
            Orte = {
                type = "OBJECT",
                properties = {
                    Laender = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    Art = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                },
            },
            Objekte = {
                type = "OBJECT",
                properties = {
                    Gegenstaende = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    Materialien = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    Marken = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    Pflanzen  = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                    Fahrzeuge = {
                        type = "OBJECT",
                        properties = {
                            Hersteller = {
                                type = "ARRAY",
                                items = { type = "STRING" },
                            },
                            Modelle = {
                                type = "ARRAY",
                                items = { type = "STRING" },
                            },
                            Arten = {
                                type = "ARRAY",
                                items = { type = "STRING" },
                            },
                            Farben = {
                                type = "ARRAY",
                                items = { type = "STRING" },
                            },
                        },
                    },
                    Tiere = {
                        type = "ARRAY",
                        items = { type = "STRING" },
                    },
                },
            },
            Personen = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            Stimmungen = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            Szenerie = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            stilistisch = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            Texte = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            Fotografische_Kategorien = {
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
            Themen = {
                type = "ARRAY",
                items = { type = "STRING" },
            },
            Farben = {
                type = "ARRAY",
                items = { type = "STRING" },
            }
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

Defaults.googleTopKeyword = 'Gemini'
Defaults.chatgptTopKeyword = 'ChatGPT'

Defaults.geminiKeywordsGarbageAtStart = '```json'
Defaults.geminiKeywordsGarbageAtEnd = '```'

function Defaults.getDefaultKeywordsGenerationConfig(language)
    local generationConfig = {
        response_mime_type = "application/json",
        response_schema = Defaults.defaultKeywordHierarchy[language],
    }

    return generationConfig
end