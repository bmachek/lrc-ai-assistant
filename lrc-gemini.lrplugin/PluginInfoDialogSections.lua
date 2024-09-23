require "GeminiAPI"


PluginInfoDialogSections = {}


function PluginInfoDialogSections.startDialog(propertyTable)
    if prefs.logging == nil then
        prefs.logging = false
    end

    if prefs.apiKey == nil then
        prefs.apiKey = ""
    end

    if prefs.generateTitle == nil then
        prefs.generateTitle = false
    end

    if prefs.generateKeywords == nil then
        prefs.generateKeywords = false
    end

    if prefs.generateCaption == nil then
        prefs.generateCaption = true
    end

    if prefs.titleTask == nil then
        prefs.titleTask = GeminiAPI.defaultTitleTask
    end

    if prefs.captionTask == nil then
        prefs.captionTask = GeminiAPI.defaultCaptionTask
    end

    if prefs.keywordsTask == nil then
        prefs.keywordsTask = GeminiAPI.defaultKeywordsTask
    end

    if prefs.generateLanguage == nil then
        prefs.generateLanguage = "English"
    end

    propertyTable.logging = prefs.logging
    propertyTable.apiKey = prefs.apiKey
    propertyTable.generateTitle = prefs.generateTitle
    propertyTable.generateCaption = prefs.generateCaption
    propertyTable.generateKeywords = prefs.generateKeywords
    propertyTable.titleTask = prefs.titleTask
    propertyTable.captionTask =  prefs.captionTask
    propertyTable.keywordsTask = prefs.keywordsTask
    propertyTable.generateLanguage = prefs.generateLanguage

end

function PluginInfoDialogSections.sectionsForBottomOfDialog(f, propertyTable)
    local bind = LrView.bind
    local share = LrView.share

    return {

        {
            bind_to_object = propertyTable,

            title = "Gemini Plugin Logging",

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

            title = "Gemini Plugin Settings",

            f:row {
                f:static_text {
                    title = "Google Gemini API key: ",
                    alignment = 'right',
                    width = share 'labelWidth'
                },
                f:edit_field {
                    value = bind 'apiKey',
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
                    title = 'Language to be used: ',
                    alignment = 'right',
                    width = share 'labelWidth'
                },
                f:popup_menu {
                    value = bind 'generateLanguage',
                    items = {
                        { title = "English", value = "English" },
                        { title = "German", value = "German" },
                        { title = "Spanish", value = "Spanish" },
                        { title = "French", value = "French" },
                        { title = "Italian", value = "Italian" },
                        { title = "Portuguese", value = "Portuguese" },
                    },
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
                    width = bind 'inputWidth'
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
    prefs.apiKey = propertyTable.apiKey
    prefs.captionTask = propertyTable.captionTask
    prefs.titleTask = propertyTable.titleTask
    prefs.generateCaption = propertyTable.generateCaption
    prefs.generateTitle = propertyTable.generateTitle
    prefs.keywordsTask = propertyTable.keywordsTask
    prefs.generateKeywords = propertyTable.generateKeywords
    prefs.generateLanguage = propertyTable.generateLanguage

    prefs.logging = propertyTable.logging
    if propertyTable.logging then
        log:enable('logfile')
    else
        log:disable()
    end
end

