AnalyzeImageProvider = {}


function AnalyzeImageProvider.addKeywordRecursively(photo, keywordSubTable, parent)
    for key, value in pairs(keywordSubTable) do
        local keyword
        if type(key) == 'string' and key ~= "" then
            photo.catalog:withWriteAccessDo("Create category keyword", function()
                -- Some ollama models return "None" or "none" if a keyword category is empty.
                if key ~= "None" and key ~= "none" then
                    keyword = photo.catalog:createKeyword(key, {}, false, parent, true)
                end
            end)
        elseif type(key) == 'number' and value ~= nil and value ~= "" then
            photo.catalog:withWriteAccessDo("Create and add keyword", function()
                -- Some ollama models return "None" or "none" if a keyword category is empty.
                if value ~= "None" and value ~= "none" then
                    keyword = photo.catalog:createKeyword(value, {}, true, parent, true)
                    photo:addKeyword(keyword)
                end
            end)
        end
        if type(value) == 'table' then
            AnalyzeImageProvider.addKeywordRecursively(photo, value, keyword)
        end
    end
end