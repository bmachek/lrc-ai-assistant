

ResponseStructure = {}
ResponseStructure.__index = ResponseStructure

function ResponseStructure:readKeywordStructureRecurse(parent)
    local result = {}
    local children = parent:getChildren()
    if #children > 0 then
        for _, child in pairs(children) do
            if #(child:getChildren()) > 0 then
                log:trace(#(child:getChildren()))
                table.insert(result, child:getName())
                local nextLevelChildren = ResponseStructure:readKeywordStructureRecurse(child)
                if #nextLevelChildren > 0 then
                    table.insert(result, nextLevelChildren)
                end
            end
        end
    end
    return result
end

function ResponseStructure:new()
    local instance = setmetatable({}, ResponseStructure)

    if string.sub(prefs.ai, 1, 6) == 'gemini' then
        self.topKeyword = Defaults.googleTopKeyword
        self.strArray = "ARRAY"
        self.strObject = "OBJECT"
        self.strString = "STRING"
    elseif string.sub(prefs.ai, 1, 3) == 'gpt' then
        self.topKeywordName = Defaults.chatgptTopKeyword
        self.strArray = "array"
        self.strObject = "object"
        self.strString = "string"
    else
        Util.handleError('Configuration error: No valid AI model selected, check Module Manager for Configuration', LOC "$$$/lrc-ai-assistant/ResponseStructure/NoModelSelectedError=No AI model selected, check Configuration in Add-Ons manager")
    end

    return instance
end


function ResponseStructure:generateResponseStructure()

    local keywords = {}
    keywords = Defaults.defaultKeywordCategories
    if prefs.keywordCategories ~= nil then
        if type(prefs.keywordCategories) == "table" then
            keywords = prefs.keywordCategories
        end
    end

    local responseStructure = ResponseStructure:tableToResponseStructureRecurse(keywords)
    log:trace(Util.dumpTable(responseStructure))
    return responseStructure

end

-- Convert table into proper formatted table before converting it to JSON
function ResponseStructure:tableToResponseStructureRecurse(table)
    local responseStructure = {}
    responseStructure.properties = {}
    responseStructure.type = self.strObject

    for _, v in pairs(table) do
        local child = {}
        if type(v) == "string" then
            child.type = self.strArray
            child.items = {}
            child.items.type = self.strString
        elseif type(v) == "table" then
            child.type = self.strObject
            child.properties = ResponseStructure:tableToResponseStructureRecurse(v)
        end
        responseStructure.properties[v] = child
    end

    return responseStructure
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

    log:trace(Util.dumpTable(dialogView))

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
        local confirmed = LrDialogs.confirm(LOC "$$$/lrc-ai-assistant/ResponseStructure/ResetToDefaultKeywordStructure=Reset to default keyword structure?")
        if confirmed == 'ok' then
            log:trace("Reset keyword categories to default")
            prefs.keywordCategories = Defaults.defaultKeywordCategories
        end
    end
end

LrTasks.startAsyncTask(function()
    LrFunctionContext.callWithContext("Edit keyword categories", function(context)
        showDataConfigurationDialog()
    end)
end)