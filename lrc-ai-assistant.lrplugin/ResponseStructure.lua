

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

    local catalog = LrApplication.activeCatalog()
    local structure

    catalog:withWriteAccessDo("Create keyword structure in catalog.", function()
        local topKeyword = catalog:createKeyword(self.topKeywordName, {}, false, nil, true)
        log:trace("Got or created top-level keyword: " .. self.topKeywordName)
        if #(topKeyword:getChildren()) == 0 then
            -- There is no keyword structure for this AI in the Lightroom catalog yet. Create default structure.
            log:trace("Trying to create missing keyword structure in catalog.")
            for _, keywordName in ipairs(Defaults.defaultKeywordCategories) do
                local keyword = catalog:createKeyword(keywordName, {}, false, topKeyword, true)
            end
            structure = Defaults.defaultKeywordCategories
        elseif #(topKeyword:getChildren()) > 0 then
            -- Read structure from catalog.
            log:trace("Trying to read keyword structure from catalog.")
            structure = ResponseStructure:readKeywordStructureRecurse(topKeyword)
            log:trace(Util.dumpTable(structure))
        end
    end)

    local responseStructure = {}
    responseStructure.keywords = ResponseStructure:tableToResponseStructureRecurse(structure)
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
        -- table.insert(responseStructure.properties, child)
        responseStructure.properties[v] = child
    end

    -- log:trace(Util.dumpTable(responseStructure))
    return responseStructure
end

local function showDataConfigurationDialog()
    local f = LrView.osFactory()
    local bind = LrView.bind
    local share = LrView.share

    local propertyTable = {}

    propertyTable.keywordCategories = table.concat(Defaults.defaultKeywordCategories, "\n")

     local dialogView = f:row {
        bind_to_object = propertyTable,
        f:group_box {
            title = LOC "$$$/lrc-ai-assistant/ResponseStructure/ConfigureResponseStructure=Keywords",
            f:edit_field {
                height_in_lines = #Defaults.defaultKeywordCategories,
                value = bind 'keywordCategories'
            },
        },
    }

    log:trace("PATSCH5")

    table.insert(dialogView, f:row {
            bind_to_object = propertyTable,
            f:group_box {
                title = LOC "$$$/lrc-ai-assistant/ResponseStructure/ConfigureResponseStructure=Keywords",
                f:static_text {
                    title = Defaults.defaultKeywordCategories,
                },
            },
        }
    )

    log:trace(Util.dumpTable(dialogView))

    local result = LrDialogs.presentModalDialog({
        title = LOC "$$$/lrc-ai-assistant/ResponseStructure/ConfigureResponseStructure=Configure data generation and mapping",
        contents = dialogView,
    })
    log:trace("PATSCH6")
end

LrTasks.startAsyncTask(function()
    LrFunctionContext.callWithContext("Test ResponseStructure", function(context)
        showDataConfigurationDialog()
    end)
end)