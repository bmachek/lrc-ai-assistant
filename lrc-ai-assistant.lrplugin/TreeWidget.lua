local function sortedKeys(t)
    local keys = {}
    for k in pairs(t) do table.insert(keys, k) end
    table.sort(keys, function(a,b) return tostring(a) < tostring(b) end)
    return keys
end

local function createEditableTree(viewFactory, data, level, parentPath, props)
    level = level or 0
    parentPath = parentPath or "root"
    local items = {}
    local counter = 1
    
    for _, key in ipairs(sortedKeys(data)) do
        local value = data[key]
        local isTable = type(value) == "table"
        local nodeId = parentPath.."_"..counter
        
        -- Initialisiere Properties
        props[nodeId.."_name"] = props[nodeId.."_name"] or tostring(key)
        props[nodeId.."_expanded"] = props[nodeId.."_expanded"] or (level == 0)

        -- UI-Elemente
        local nodeRow = viewFactory:row {
            viewFactory:static_text {
                title = "",
                width = level * 25
            },
            isTable and viewFactory:push_button {
                title = "▼",
                width = 20,
                enabled = false,
            },
            viewFactory:edit_field {
                value = LrView.bind(nodeId.."_name"),
                width_in_chars = 25,
                immediate = true,
                truncation = 'head'
            }
        }

        if isTable then
            -- Rekursiver Aufruf für Kinder
            local children = createEditableTree(
                viewFactory, 
                value, 
                level + 1, 
                nodeId,
                props
            )
            
            table.insert(items, viewFactory:column {
                nodeRow,
                LrView.conditionalItem(
                    LrView.bind(nodeId.."_expanded"),
                    children
                )
            })
        else
            -- Blattknoten mit Wert
            table.insert(items, viewFactory:row {
                nodeRow,
                viewFactory:static_text {
                    title = ": "..tostring(value),
                    text_color = {0.4,0.4,0.4}
                }
            })
        end
        
        counter = counter + 1
    end
    
    return viewFactory:column {
        bind_to_object = props,
        spacing = 3,
        unpack(items)
    }
end

local function showTreeDialog()
    LrFunctionContext.callWithContext("treeDialog", function(context)
        local factory = LrView.osFactory()
        local props = LrBinding.makePropertyTable(context)
        
        -- Beispiel-Daten mit Default-Werten
        local sampleData = {
            ["Root Node"] = {
                ["First Branch"] = {
                    Value1 = "Editable",
                    ["Nested Branch"] = {
                        ["Deep Value"] = 123
                    }
                },
                ["Second Branch"] = {
                    Example = "Test"
                }
            }
        }

        LrDialogs.presentModalDialog {
            title = "Editable Tree",
            contents = factory:scrolled_view {
                width = 400,
                height = 500,
                createEditableTree(factory, Defaults.defaultKeywordCategories, 0, "root", props)
            }
        }
    end)
end

showTreeDialog()