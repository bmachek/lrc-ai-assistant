require "ResponseStructure"

local function changeTopSelectedTopLevel(propertyTable)
    log:trace("KeywordConfigurator: Top-level changed.")

    -- Hide all
    for k, v in pairs(propertyTable.topKeywords) do
        propertyTable['visibleCategory' .. v.value] = false
    end

    if propertyTable.checkedTopLevelKeyword ~= nil then
        log:trace("KeywordConfigurator: Top-level changed to: " .. propertyTable.checkedTopLevelKeyword)
        -- Show selected
        propertyTable['visibleCategory' .. propertyTable.checkedTopLevelKeyword] = true
    else
        log:trace("KeywordConfigurator: Top-level deselected.")
    end
end

local function showHierarchicalKeywordConfigurator(ctx)
    local f = LrView.osFactory()
    local bind = LrView.bind
    local share = LrView.share

    local propertyTable = LrBinding.makePropertyTable(ctx)

    propertyTable.keywords = {}
    propertyTable.keywords = Defaults.defaultKeywordCategories
    if prefs.keywordCategories ~= nil then
        if type(prefs.keywordCategories) == "table" then
            propertyTable.keywords = prefs.keywordCategories
        end
    end

    table.sort(propertyTable.keywords)

    propertyTable.topKeywords = {}
    propertyTable.subkeywords = {}
    propertyTable.subkeywords2 = {}

    propertyTable.checkedTopLevelKeyword = nil
    propertyTable:addObserver('checkedTopLevelKeyword', changeTopSelectedTopLevel)


    local topLevelKeywordsRows = {}
    local secondLevelKeywordsRows = {}
    local thirdLevelKeywordsRows = {}

    -- Populate keyword lists
    for k, v in pairs(propertyTable.keywords) do
        local val = ""
        if type(v) == "string" then
            val = v
        elseif type(v) == "table" then
            val = k
            for k2, v2 in pairs(v) do
                local val2 = ""
                if type(v2) == "string" then
                    val2 = v2
                elseif type(v2) == "table" then
                    val2 = k2
                    for k3, v3 in pairs(v2) do
                        local val3 = ""
                        if type(v3) == "string" then
                            val3 = v3
                        elseif type(v3) == "table" then
                            val3 = k3
                        end
                        local key3 = "keywordCategory_" .. val .. "_" .. val2 .. "_" .. val3
                        propertyTable[key3] = val3
                        propertyTable['visibleCategory' .. val2] = false
                        table.insert(propertyTable.subkeywords2, { title = val3, value = val3 })
                        table.insert(thirdLevelKeywordsRows, f:row { f:radio_button { visible = bind('visibleCategory' .. val2), value = bind 'checkedThirdLevelKeyword', checked_value = val3 }, f:edit_field { visible = bind('visibleCategory' .. val2), value = bind(key3), width = share 'keywordWidth' }, })
                        log:trace("Added 3rd-level: " .. key3 .. " = " .. val3)
                    end
                end
                local key2 = "keywordCategory_" .. val .. "_" .. val2
                propertyTable[key2] = val2
                propertyTable['visibleCategory' .. val] = false
                table.insert(propertyTable.subkeywords, { title = val2, value = val2 })
                table.insert(secondLevelKeywordsRows, f:row { f:radio_button { visible = bind('visibleCategory' .. val), value = bind 'checkedSecondLevelKeyword', checked_value = val2 }, f:edit_field { visible = bind('visibleCategory' .. val), value = bind(key2), width = share 'keywordWidth' }, })
                log:trace("Added 2nd-level: " .. key2 .. " = " .. val2)
            end
        end
        local key = "keywordCategory_" .. val
        propertyTable[key] = val
        table.insert(propertyTable.topKeywords, { title = val, value = val })
        table.insert(topLevelKeywordsRows, f:row { f:radio_button { value = bind 'checkedTopLevelKeyword', checked_value = val }, f:edit_field { value = bind(key), width = share 'keywordWidth' }, })
        log:trace("Added top-level: " .. key .. " = " .. val)
    end

    topLevelKeywordsRows.title = "Top-level keywords"
    topLevelKeywordsRows.height = 300
    topLevelKeywordsRows.width = 300
    secondLevelKeywordsRows.title = "2nd-level keywords"
    secondLevelKeywordsRows.height = 300
    secondLevelKeywordsRows.width = 300
    thirdLevelKeywordsRows.title = "3rd-level keywords"
    thirdLevelKeywordsRows.height = 300
    thirdLevelKeywordsRows.width = 300


    local topLevel = f:column(topLevelKeywordsRows)
    local secondLevel = f:column(secondLevelKeywordsRows)
    local thirdLevel = f:column(thirdLevelKeywordsRows)


    local dialogView = f:row {
        bind_to_object = propertyTable,
        topLevel,
        secondLevel,
        thirdLevel,
    }

    local result = LrDialogs.presentModalDialog({
        title = LOC "$$$/lrc-ai-assistant/ResponseStructure/ConfigureResponseStructure=Configure data generation and mapping",
        contents = dialogView,
        otherVerb = LOC "$$$/lrc-ai-assistant/ResponseStructure/ResetToDefault=Reset to defaults",
        resizable = true,
    })

    if result == 'ok' then
        log:trace('Saving changes to keyword categories.')
        -- TODO
    elseif result == 'other' then
        local confirm = LrDialogs.confirm(LOC "$$$/lrc-ai-assistant/ResponseStructure/ResetToDefaultKeywordStructure=Reset to default keyword structure?")
        if confirm == 'ok' then
            log:trace("Reset keyword categories to default")
            prefs.keywordCategories = Defaults.defaultKeywordCategories
        end
    end
end


local function showDataConfigurationDialog()
    local f = LrView.osFactory()
    local bind = LrView.bind
    local share = LrView.share

    local propertyTable = {}

    local keywords = {}
    keywords = Defaults.defaultKeywordCategories
    if prefs.keywordCategories ~= nil then
        if type(prefs.keywordCategories) == "table" then
            keywords = prefs.keywordCategories
        end
    end

    table.sort(keywords)

    local editFields = {}
    for i = 1, #keywords do
        local key = "keywordCategory_" .. i
        propertyTable[key] = keywords[i]
        table.insert(editFields, f:edit_field { value = bind(key), immediate = true })
    end
    editFields.title = LOC "$$$/lrc-ai-assistant/ResponseStructure/ConfigureResponseStructure=Keywords"

    local keywordBox = f:group_box(editFields)

    local dialogView = f:row {
        bind_to_object = propertyTable,
        f:column {
            keywordBox,
        },
        f:column {
            f:group_box {
                title = LOC "$$$/lrc-ai-assistant/ResponseStructure/NewKeywordCategory=New Category",
                f:edit_field {
                    value = bind 'new',
                },
                f:push_button {
                    title = LOC "$$$/lrc-ai-assistant/ResponseStructure/AddKeywordCategory=Add",
                    action = function (button)
                        table.insert(prefs.keywordCategories, propertyTable.new)
                        LrDialogs.stopModalWithResult(keywordBox, "cancel")
                        showDataConfigurationDialog()
                    end
                }
            },
        },
    }

    local result = LrDialogs.presentModalDialog({
        title = LOC "$$$/lrc-ai-assistant/ResponseStructure/ConfigureResponseStructure=Configure data generation and mapping",
        contents = dialogView,
        otherVerb = LOC "$$$/lrc-ai-assistant/ResponseStructure/ResetToDefault=Reset to defaults"
    })

    if result == 'ok' then
        log:trace('Saving changes to keyword categories.')
        prefs.keywordCategories = {}
        for i = 1, #keywords do
            local key = "keywordCategory_" .. i
            if propertyTable[key] ~= nil and propertyTable[key] ~= "" then 
                table.insert(prefs.keywordCategories, propertyTable[key])
            end
        end
        log:trace(Util.dumpTable(prefs.keywordCategories))
    elseif result == 'other' then
        local confirm = LrDialogs.confirm(LOC "$$$/lrc-ai-assistant/ResponseStructure/ResetToDefaultKeywordStructure=Reset to default keyword structure?")
        if confirm == 'ok' then
            log:trace("Reset keyword categories to default")
            prefs.keywordCategories = Defaults.defaultKeywordCategories
        end
    end
end

LrTasks.startAsyncTask(function()
    LrFunctionContext.callWithContext("Edit keyword categories", function(context)
        showDataConfigurationDialog()
        -- showHierarchicalKeywordConfigurator(context)
        -- log:trace(Util.dumpTable(ResponseStructure:new():generateResponseStructure()))
    end)
end)