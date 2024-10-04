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

    if prefs.reviewCaption == nil then
        prefs.reviewCaption = false
    end

    if prefs.reviewTitle == nil then
        prefs.reviewTitle = false
    end

    if prefs.showCosts == nil then
        prefs.showCosts = false
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
        prefs.generateLanguage = Defaults.defaultGenerateLanguage
    end

    propertyTable.logging = prefs.logging
    propertyTable.geminiApiKey = prefs.geminiApiKey
    propertyTable.chatgptApiKey = prefs.chatgptApiKey
    propertyTable.generateTitle = prefs.generateTitle
    propertyTable.generateCaption = prefs.generateCaption
    propertyTable.generateKeywords = prefs.generateKeywords
    propertyTable.titleTask = prefs.titleTask
    propertyTable.captionTask =  prefs.captionTask
    propertyTable.keywordsTask = prefs.keywordsTask
    propertyTable.generateLanguage = prefs.generateLanguage

    propertyTable.reviewCaption = prefs.reviewCaption
    propertyTable.reviewTitle = prefs.reviewTitle

    propertyTable.ai  = prefs.ai

    propertyTable.showCosts = prefs.showCosts

end

function PluginInfoDialogSections.sectionsForBottomOfDialog(f, propertyTable)
    local bind = LrView.bind
    local share = LrView.share

    return {

        {
            bind_to_object = propertyTable,

            title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/Logging=Activate debug logging",

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

            title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/Title=AI Plugin settings",

            f:row {
                f:static_text {
                    title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/GoogleApiKey=Google API key",
                    alignment = 'right',
                    width = share 'labelWidth'
                },
                f:edit_field {
                    value = bind 'geminiApiKey',
                    width = share 'inputWidth',
                    width_in_chars = 40,
                },
            },

            f:row {
                f:static_text {
                    title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/aiModel=AI model to be used",
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
                    title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/showCosts=Show costs (without any warranty!!!)",
                    alignment = 'right',
                    width = share 'labelWidth',
                },

                f:checkbox {
                    value = bind 'showCosts',
                    width = share 'checkboxWidth'
                },
            },

            f:row {
                f:static_text {
                    title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/validateBeforeSaving=Validate before saving",
                    alignment = 'right',
                    width = share 'labelWidth',
                },
                f:checkbox {
                    value = bind 'reviewCaption',
                    width = share 'checkboxWidth',
                },
                f:static_text {
                    title = 'Caption',
                },
            },
            f:row {
                f:spacer {
                    width = share 'labelWidth',
                },
                f:checkbox {
                    value = bind 'reviewTitle',
                    width = share 'checkboxWidth',
                },
                f:static_text {
                    title = 'Title',
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
    prefs.generateKeywords = propertyTable.generateKeywords
    prefs.generateLanguage = propertyTable.generateLanguage
    prefs.ai = propertyTable.ai

    prefs.reviewCaption = propertyTable.reviewCaption
    prefs.reviewTitle = propertyTable.reviewTitle

    prefs.showCosts = propertyTable.showCosts

    prefs.logging = propertyTable.logging
    if propertyTable.logging then
        log:enable('logfile')
    else
        log:disable()
    end
end

