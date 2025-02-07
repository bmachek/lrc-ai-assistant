

KeywordStructure = {}
KeywordStructure.__index = KeywordStructure

local function readKeywordStructureRecurse(parent)
    local result = {}
    local children = parent.getChildren()
    if #children > 0 then
        table.insert(result, children.getName())
        if #children.getChildren() > 0 then
            table.insert(readKeywordStructureRecurse(children))
        end
    end
end

function KeywordStructure:new()
    local instance = setmetatable({}, KeywordStructure)

    if string.sub(prefs.ai, 1, 6) == 'gemini' then
        self.topKeyword = Defaults.googleTopKeyword
    elseif string.sub(prefs.ai, 1, 3) == 'gpt' then
        self.topKeyword = Defaults.chatgptTopKeyword
    else
        Util.handleError('Configuration error: No valid AI model selected, check Module Manager for Configuration', LOC "$$$/lrc-ai-assistant/KeywordStructure/NoModelSelectedError=No AI model selected, check Configuration in Add-Ons manager")
    end

    self.structure = {}

    return instance
end


function KeywordStructure:generateResponseStructure()

    local catalog = LrApplication.activeCatalog()

    catalog:withWriteAccessDo("Create keyword structure in catalog.", function()
        local topKeyword = catalog:createKeyword(self.topKeyword, {}, false, nil, true)
        if #topKeyword.getChildren() == 0 then
            -- There is no keyword structure for this AI in the Lightroom catalog yet. Create default structure.
            for _, keywordName in ipairs(Defaults.defaultKeywordCategories) do
                local keyword = catalog:createKeyword(keywordName, {}, false, topKeyword, true)
            end
            self.structure = Defaults.defaultKeywordCategories
        elseif #topKeyword.getChildren > 0 then
            -- Read structure from catalog.
            self.structure = readKeywordStructureRecurse(topKeyword)
        end
    end)

    return self:tableToResponseStructure()

end
