require "GeminiAPI"


PluginInfoDialogSections = {}


function PluginInfoDialogSections.startDialog(propertyTable)
    if prefs.logging == nil then
        prefs.logging = false
    end

    if prefs.ai == nil then
        prefs.ai = Defaults.defaultAiModel
    end

    if prefs.geminiApiKey == nil then
        prefs.geminiApiKey = ""
    end

    if prefs.chatgptApiKey == nil then
        prefs.chatgptApiKey = ""
    end

    if prefs.generateTitle == nil then
        prefs.generateTitle = false
    end

    if prefs.generateKeywords == nil then
        prefs.generateKeywords = true
    end

    if prefs.generateCaption == nil then
        prefs.generateCaption = false
    end

    if prefs.titleTask == nil then
        prefs.titleTask = Defaults.defaultTitleTask
    end

    if prefs.captionTask == nil then
        prefs.captionTask = Defaults.defaultCaptionTask
    end

    if prefs.keywordsTask == nil then
        prefs.keywordsTask = Defaults.defaultKeywordsTask
    end

    if prefs.generateLanguage == nil then
        prefs.generateLanguage = "English"
    end

    propertyTable.logging = prefs.logging
    propertyTable.geminiApiKey = prefs.geminiApiKey
    propertyTable.chatgptApiKey = prefs.chatgptApiKey
    propertyTable.generateTitle = prefs.generateTitle
    propertyTable.generateCaption = prefs.generateCaption
    propertyTable.generateKeywords = prefs.generateKeywords
    propertyTable.titleTask = prefs.titleTask
    propertyTable.captionTask =  prefs.captionTask
    propertyTable.keywordsTask = Defaults.defaultKeywordsTask
    propertyTable.generateLanguage = prefs.generateLanguage
    propertyTable.ai  = prefs.ai

end

function PluginInfoDialogSections.sectionsForBottomOfDialog(f, propertyTable)
    local bind = LrView.bind
    local share = LrView.share

    return {

        {
            bind_to_object = propertyTable,

            title = "AI Plugin Logging",

            f:row {
                f:checkbox {
                    value = bind 'logging',
                },
                f:static_text {
                    title = "Enable debug logging",
                    alignment = 'right',
                    width = share 'labelWidth'
                },
            },
        },
    }
end

function PluginInfoDialogSections.sectionsForTopOfDialog(f, propertyTable)
    local bind = LrView.bind
    local share = LrView.share

    return {

        {
            bind_to_object = propertyTable,

            title = "AI Plugin Settings",

            f:row {
                f:static_text {
                    title = "Google Gemini API key: ",
                    alignment = 'right',
                    width = share 'labelWidth'
                },
                f:edit_field {
                    value = bind 'geminiApiKey',
                    width = share 'inputWidth',
                    width_in_chars = 40,
                },
                f:spacer {
                    width = share 'checkboxWidth'
                },
                f:spacer {
                    width = share 'enabledWidth'
                },
            },

            f:row {
                f:static_text {
                    title = "ChatGPT API key: ",
                    alignment = 'right',
                    width = share 'labelWidth'
                },
                f:edit_field {
                    value = bind 'chatgptApiKey',
                    width = share 'inputWidth',
                    width_in_chars = 40,
                },
                f:spacer {
                    width = share 'checkboxWidth'
                },
                f:spacer {
                    width = share 'enabledWidth'
                },
            },

            f:row {
                f:static_text {
                    title = 'AI model to be used:',
                    alignment = 'right',
                    width = share 'labelWidth',
                },

                f:popup_menu {
                    value = bind 'ai',
                    items = Defaults.aiModels,
                },
            },

            f:row {
                f:static_text {
                    title = 'Language to be used: ',
                    alignment = 'right',
                    width = share 'labelWidth'
                },
                f:popup_menu {
                    value = bind 'generateLanguage',
                    items = Defaults.generateLanguages,
                },
                f:spacer {
                    width = share 'checkboxWidth',
                },
                f:spacer {
                    width = share 'enabledWidth',
                },
            },

            f:row {
                f:static_text {
                    title = "Question for image title",
                    alignment = 'right',
                    width = share 'labelWidth',
                    enabled = bind 'generateTitle',
                },
                f:edit_field {
                    value = bind 'titleTask',
                    width = share 'inputWidth',
                    enabled = bind 'generateTitle',
                },
                f:checkbox {
                    value = bind 'generateTitle',
                    width = share 'checkboxWidth',
                },
                f:static_text {
                    width = share 'enabledWidth',
                    title = 'Enable'
                },
            },

            f:row {
                f:static_text {
                    title = "Question for image caption: ",
                    alignment = 'right',
                    width = share 'labelWidth',
                    enabled = bind 'generateCaption',
                },
                f:edit_field {
                    value = bind 'captionTask',
                    width = share 'inputWidth',
                    enabled = bind 'generateCaption',
                },
                f:checkbox {
                    value = bind 'generateCaption',
                    width = share 'checkboxWidth',
                },
                f:static_text {
                    width = share 'enabledWidth',
                    title = 'Enable'
                },
            },

            f:row {
                f:static_text {
                    title = "Generate Keywords: ",
                    alignment = 'right',
                    width = share 'labelWidth',
                    enabled = bind 'generateKeywords',
                },
                f:edit_field {
                    value = bind 'keywordsTask',
                    enabled = false,
                    width = share 'inputWidth'
                },
                f:checkbox {
                    value = bind 'generateKeywords',
                    width = share 'checkboxWidth',
                },
                f:static_text {
                    width = share 'enabledWidth',
                    title = 'Enable'
                },
            },
        },
    }
end


function PluginInfoDialogSections.endDialog(propertyTable)
    prefs.geminiApiKey = propertyTable.geminiApiKey
    prefs.chatgptApiKey = propertyTable.chatgptApiKey
    prefs.captionTask = propertyTable.captionTask
    prefs.titleTask = propertyTable.titleTask
    prefs.generateCaption = propertyTable.generateCaption
    prefs.generateTitle = propertyTable.generateTitle
    prefs.keywordsTask = propertyTable.keywordsTask
    -- prefs.generateKeywords = propertyTable.generateKeywords
    prefs.generateLanguage = propertyTable.generateLanguage
    prefs.ai = propertyTable.ai

    prefs.logging = propertyTable.logging
    if propertyTable.logging then
        log:enable('logfile')
    else
        log:disable()
    end
end

