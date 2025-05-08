PromptConfigProvider = {}

local function deletePrompt(promptTitle)
    if promptTitle == "Default" then
        LrDialogs.showError("Default prompt cannot be deleted.")
        return nil
    end

    if LrDialogs.confirm("Do you really want to delete the prompt " .. promptTitle) == "ok" then
        -- table.remove(prefs.prompts, promptTitle)
        prefs.prompts[promptTitle] = nil

        if prefs.prompt == promptTitle then
            prefs.prompt = "Default"
        end
    end
end

local function addPrompt()
    local f = LrView.osFactory()
    local bind = LrView.bind
    local share = LrView.share

    local propertyTable = {}

    local dialogView = f:column {
        bind_to_object = propertyTable,
        f:row {
            f:static_text {
                width = share 'labelWidth',
                title = "Prompt name",
            },
            f:edit_field {
               value = bind 'name',
            },
        },
        f:row {
            f:static_text {
                width = share 'labelWidth',
                title = "Prompt",
            },
            f:edit_field {
               value = bind 'prompt',
               width_in_chars = 50,
               height_in_lines = 10,
            },
        },
    }

    local result = LrDialogs.presentModalDialog({
        title = "Add new prompt",
        contents = dialogView,
    })

    if result == 'ok' then
        prefs.prompts[propertyTable.name] = propertyTable.prompt
        prefs.prompt = propertyTable.name
        return propertyTable.name
    end

    return nil
end


local function editPrompt(title)
    local f = LrView.osFactory()
    local bind = LrView.bind
    local share = LrView.share

    local propertyTable = {}

    propertyTable.name = title
    propertyTable.prompt = prefs.prompts[title]

    local dialogView = f:column {
        bind_to_object = propertyTable,
        f:row {
            f:static_text {
                width = share 'labelWidth',
                title = "Prompt name",
            },
            f:edit_field {
               value = bind 'name',
            },
        },
        f:row {
            f:static_text {
                width = share 'labelWidth',
                title = "Prompt",
            },
            f:edit_field {
               value = bind 'prompt',
               width_in_chars = 50,
               height_in_lines = 10,
            },
        },
    }

    local result = LrDialogs.presentModalDialog({
        title = "Edit prompt",
        contents = dialogView,
    })

    if result == 'ok' then
        prefs.prompts[propertyTable.name] = propertyTable.prompt
        prefs.prompt = propertyTable.name
        return propertyTable.name
    end

    return nil
end


function PromptConfigProvider.showPromptConfigDialog(propertyTable)
    local f = LrView.osFactory()
    local bind = LrView.bind
    local share = LrView.share

    propertyTable.promptTitles = {}
    for title, prompt in pairs(prefs.prompts) do
        table.insert(propertyTable.promptTitles, { title = title, value = title })
    end
    
    propertyTable.prompts = prefs.prompts

    propertyTable.prompt = prefs.prompt

    propertyTable.selectedPrompt = prefs.prompts[prefs.prompt]

    propertyTable:addObserver('prompt', function(properties, key, newValue)
        properties.selectedPrompt = properties.prompts[newValue]
    end)

    propertyTable:addObserver('selectedPrompt', function(properties, key, newValue)
        properties.prompts[properties.prompt] = newValue
    end)

    local dropDown = f:popup_menu {
        items = bind 'promptTitles',
        value = bind 'prompt',

    }

    local dialogView = f:column {
        bind_to_object = propertyTable,
        f:row {
            f:static_text {
                width = share 'labelWidth',
                title = "Prompt name",
            },
            dropDown,
            f:push_button {
                title = "Add",
                action = function(button)
                    local newName = addPrompt()
                    if newName ~= nil then
                        LrDialogs.stopModalWithResult(dropDown, "cancel")
                        PromptConfigProvider.showPromptConfigDialog(propertyTable)
                    end
                end,
            },
            f:push_button {
                title = "Delete",
                action = function(button)
                    deletePrompt(propertyTable.prompt)
                    LrDialogs.stopModalWithResult(dropDown, "cancel")
                    PromptConfigProvider.showPromptConfigDialog(propertyTable)
                end,
            },
            -- f:push_button {
            --     title = "Edit",
            --     action = function(button)
            --         editPrompt(propertyTable.prompt)
            --         LrDialogs.stopModalWithResult(dropDown)
            --         PromptConfigProvider.showPromptConfigDialog()
            --     end,
            -- },
            -- f:push_button {
            --     title = "Select",
            --     action = function(button)
            --         propertyTable.selectedPrompt = propertyTable.prompts[propertyTable.prompt]
            --     end,
            -- },
        },
        f:row {
            f:static_text {
                width = share 'labelWidth',
                title = "Prompt",
            },
            f:edit_field {
                value = bind 'selectedPrompt',
                width_in_chars = 50,
                height_in_lines = 10,
                -- enabled = false,
            },
        },
    }

    local result = LrDialogs.presentModalDialog({
        title = "Configure Prompts",
        contents = dialogView,
        otherVerb = LOC "$$$/lrc-ai-assistant/ResponseStructure/ResetToDefault=Reset to defaults"
    })

    if result == 'ok' then
        prefs.prompts = propertyTable.prompts
        prefs.prompt = propertyTable.prompt
    elseif result == 'cancel' then

    elseif result == 'other' then
        prefs.prompts = { Default = Defaults.defaultSystemInstruction }
        prefs.prompt = "Default"
    end
end