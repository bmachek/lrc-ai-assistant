Defaults = {}

Defaults.defaultSystemInstruction = 'Answer appropriate for photo organization. Only one candidate.'
Defaults.defaultCaptionTask = 'Generate a detailed image caption'
Defaults.defaultTitleTask = 'Generate one image title'
Defaults.defaultKeywordsTask = 'Describe the image contents include recognized buildings, places, people and objects'
Defaults.defaultKeywordsSystemInstruction = 'Output hierarchical keywords. Be as specific as possible.'


Defaults.defaultKeywordHierarchy = {
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
                        cars = {
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
                        motorcycles = {
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
                        bicycles = {
                            type = "OBJECT",
                            properties = {
                                kind = {
                                    type = "ARRAY",
                                    items = { type = "STRING" },
                                },
                                color = {
                                    type = "ARRAY",
                                    items = { type = "STRING" },
                                },
                                brands = {
                                    type = "ARRAY",
                                    items = { type = "STRING" },
                                },
                            },
                        },
                        miscellaneous = {
                            type = "OBJECT",
                            properties = {
                                kind = {
                                    type = "ARRAY",
                                    items = { type = "STRING" },
                                },
                                color = {
                                    type = "ARRAY",
                                    items = { type = "STRING" },
                                },
                                brands = {
                                    type = "ARRAY",
                                    items = { type = "STRING" },
                                },
                            },
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
        emotions = {
            type = "ARRAY",
            items = { type = "STRING" },
        },
        scenery = {
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
        photographic_category = {
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
        topic = {
            type = "ARRAY",
            items = { type = "STRING" },
        },
    },
}


Defaults.defaultKeywordsGenerationConfig = {
    response_mime_type = "application/json",
    response_schema = Defaults.defaultKeywordHierarchy,
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
