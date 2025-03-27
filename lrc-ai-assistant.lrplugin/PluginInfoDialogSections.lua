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
        prefs.generateTitle = true
    end

    if prefs.generateKeywords == nil then
        prefs.generateKeywords = true
    end

    if prefs.generateCaption == nil then
        prefs.generateCaption = true
    end

    if prefs.generateAltText == nil then
        prefs.generateAltText = true
    end

    if prefs.reviewAltText == nil then
        prefs.reviewAltText = false
    end

    if prefs.reviewCaption == nil then
        prefs.reviewCaption = false
    end

    if prefs.reviewTitle == nil then
        prefs.reviewTitle = false
    end

    if prefs.reviewKeywords == nil then
        prefs.reviewKeywords = false
    end

    if prefs.showCosts == nil then
        prefs.showCosts = true
    end

    if prefs.generateLanguage == nil then
        prefs.generateLanguage = Defaults.defaultGenerateLanguage
    end

    if prefs.exportSize == nil then
        prefs.exportSize = Defaults.defaultExportSize
    end

    if prefs.exportQuality == nil then
        prefs.exportQuality = Defaults.defaultExportQuality
    end

    if prefs.showPreflightDialog == nil then
        prefs.showPreflightDialog = false
    end

    propertyTable.logging = prefs.logging
    propertyTable.geminiApiKey = prefs.geminiApiKey
    propertyTable.chatgptApiKey = prefs.chatgptApiKey
    propertyTable.generateTitle = prefs.generateTitle
    propertyTable.generateCaption = prefs.generateCaption
    propertyTable.generateKeywords = prefs.generateKeywords
    propertyTable.generateAltText = prefs.generateAltText
    
    propertyTable.reviewAltText = prefs.reviewAltText
    propertyTable.reviewCaption = prefs.reviewCaption
    propertyTable.reviewTitle = prefs.reviewTitle
    propertyTable.reviewKeywords = prefs.reviewKeywords

    propertyTable.ai  = prefs.ai
    propertyTable.exportSize = prefs.exportSize
    propertyTable.exportQuality = prefs.exportQuality

    propertyTable.showCosts = prefs.showCosts

    propertyTable.showPreflightDialog = prefs.showPreflightDialog

end

function PluginInfoDialogSections.sectionsForBottomOfDialog(f, propertyTable)
    local bind = LrView.bind
    local share = LrView.share

    return {

        {
            bind_to_object = propertyTable,
            title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/Logging=Activate debug logging",

            f:row {
                f:static_text {
                    title = Util.getLogfilePath(),
                },
            },
            f:row {
                f:checkbox {
                    value = bind 'logging',
                },
                f:static_text {
                    title = "Enable debug logging",
                    alignment = 'right',
                    -- width = share 'labelWidth'
                },
                f:push_button {
                    title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/ShowLogfile=Show logfile",
                    action = function (button)
                        LrShell.revealInShell(Util.getLogfilePath())
                    end,
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

            title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/header=AI Plugin settings",

            f:group_box {
                width = share 'groupBoxWidth',
                title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/aiModel=AI model to be used",
                f:row {
                    f:popup_menu {
                        value = bind 'ai',
                        items = Defaults.aiModels,
                    },
                    f:static_text {
                        title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/showCosts=Show costs (without any warranty!!!)",
                        -- alignment = 'right',
                        -- width = share 'labelWidth',
                    },
                    f:checkbox {
                        value = bind 'showCosts',
                        width = share 'checkboxWidth'
                    },
                },
            },

            f:group_box {
                width = share 'groupBoxWidth',
                title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/ApiKeys=API keys",
                f:row {
                    f:static_text {
                        title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/GoogleApiKey=Google API key",
                        -- alignment = 'right',
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
                        title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/ChatGPTApiKey=ChatGPT API key",
                        -- alignment = 'right',
                        width = share 'labelWidth'
                    },
                    f:edit_field {
                        value = bind 'chatgptApiKey',
                        width = share 'inputWidth',
                        width_in_chars = 40,
                    },
                },
            },
            f:group_box {
                width = share 'groupBoxWidth',
                title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/ContentValidateConfig=Content and Validation Configuration",
                f:row {
                    f:static_text {
                        title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/generate=Generate the following",
                        -- alignment = 'right',
                        width = share 'labelWidth',
                    },
                    f:checkbox {
                        value = bind 'generateCaption',
                        width = share 'checkboxWidth',
                    },
                    f:static_text {
                        title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/caption=Caption",
                    },
                    f:checkbox {
                        value = bind 'generateAltText',
                        width = share 'checkboxWidth',
                    },
                    f:static_text {
                        title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/alttext=Alt Text",
                    },
                    f:checkbox {
                        value = bind 'generateTitle',
                        width = share 'checkboxWidth',
                    },
                    f:static_text {
                        title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/title=Title",
                    },
                    f:checkbox {
                        value = bind 'generateKeywords',
                        width = share 'checkboxWidth',
                    },
                    f:static_text {
                        title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/keywords=Keywords",
                    },
                },
                f:row {
                    f:static_text {
                        title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/validateBeforeSaving=Validate before saving",
                        -- alignment = 'right',
                        width = share 'labelWidth',
                    },
                    f:checkbox {
                        value = bind 'reviewCaption',
                        width = share 'checkboxWidth',
                        enabled = bind 'generateCaption',
                    },
                    f:static_text {
                        title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/caption=Caption",
                    },
                    f:checkbox {
                        value = bind 'reviewAltText',
                        width = share 'checkboxWidth',
                        enabled = bind 'generateAltText',
                    },
                    f:static_text {
                        title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/alttext=Alt Text",
                    },
                    f:checkbox {
                        value = bind 'reviewTitle',
                        width = share 'checkboxWidth',
                        enabled = bind 'generateTitle',
                    },
                    f:static_text {
                        title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/title=Title",
                    },
                    f:checkbox {
                        value = bind 'reviewKeywords',
                        width = share 'checkboxWidth',
                        enabled = false,
                    },
                    f:static_text {
                        title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/keywords=Keywords",
                    },
                },
                f:row {
                    f:spacer {
                        width = share 'labelWidth',
                    },
                    f:checkbox {
                        value = bind 'showPreflightDialog',
                        width = share 'checkboxWidth'
                    },
                    f:static_text {
                        title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/showPreflightDialog=Show Preflight dialog",
                        width = share 'labelWidth',
                    },
                },
            },

            f:group_box {
                width = share 'groupBoxWidth',
                title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/exportSettings=Export settings",
                f:row {
                    f:static_text {
                        title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/exportSize=Export size in pixel (long edge)",
                    },
                    f:popup_menu {
                        value = bind 'exportSize',
                        items = Defaults.exportSizes,
                    },
                },
                f:row {
                    f:static_text {
                        title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/exportQuality=Export JPEG quality in percent",
                    },
                    f:slider {
                        value = bind 'exportQuality',
                        min = 1,
                        max = 100,
                        integral = true,
                        immediate = true,
                    },
                    f:static_text {
                        title = bind 'exportQuality'
                    },
                },
            },
        },
    }
end


function PluginInfoDialogSections.endDialog(propertyTable)
    prefs.geminiApiKey = propertyTable.geminiApiKey
    prefs.chatgptApiKey = propertyTable.chatgptApiKey
    prefs.generateCaption = propertyTable.generateCaption
    prefs.generateTitle = propertyTable.generateTitle
    prefs.generateKeywords = propertyTable.generateKeywords
    prefs.generateAltText = propertyTable.generateAltText
    prefs.ai = propertyTable.ai
    prefs.exportSize = propertyTable.exportSize
    prefs.exportQuality = propertyTable.exportQuality

    prefs.reviewCaption = propertyTable.reviewCaption
    prefs.reviewTitle = propertyTable.reviewTitle
    prefs.reviewAltText = propertyTable.reviewAltText
    prefs.reviewKeywords = propertyTable.reviewKeywords

    prefs.showCosts = propertyTable.showCosts

    prefs.showPreflightDialog = propertyTable.showPreflightDialog

    prefs.logging = propertyTable.logging
    if propertyTable.logging then
        log:enable('logfile')
    else
        log:disable()
    end
end

