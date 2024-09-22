
PluginInfoDialogSections = {}


function PluginInfoDialogSections.startDialog(propertyTable)
    if prefs.logging == nil then
        prefs.logging = false
    end
    
    if prefs.generateLanguage == nil then
        prefs.generateLanguage = "English"
    end

    if prefs.apiKey == nil then
        propertyTable.apiKey = ""
    end

    propertyTable.logging = prefs.logging
    propertyTable.generateLanguage = prefs.generateLanguage
    propertyTable.apiKey = prefs.apiKey

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
            },

            f:row {
                f:static_text {
                    title = "Google Gemini Generate language: ",
                    alignment = 'right',
                    width = share 'labelWidth',
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
            },
        },
    }
end


function PluginInfoDialogSections.endDialog(propertyTable)
    prefs.apiKey = propertyTable.apiKey
    prefs.generateLanguage = propertyTable.generateLanguage
    prefs.logging = propertyTable.logging
    if propertyTable.logging then
        log:enable('logfile')
    else
        log:disable()
    end
end

