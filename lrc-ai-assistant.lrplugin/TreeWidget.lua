-- Globale Variablen für Dialogsteuerung
local props = nil
local treeData = nil

function createTreeWidget(viewFactory, data, parentPath, level)
    level = level or 0
    parentPath = parentPath or "root"
    local items = {}
    
    local sortedKeys = function(t)
        local keys = {}
        for k in pairs(t) do table.insert(keys, k) end
        table.sort(keys, function(a,b) return tostring(a) < tostring(b) end)
        return keys
    end

    for _, key in ipairs(sortedKeys(data)) do
        local value = data[key]
        local isFolder = type(value) == "table"
        local nodeId = parentPath.."/"..tostring(key)
        
        -- Initialisiere die Bindungen
        props[nodeId.."_name"] = key
        if not isFolder then
            props[nodeId.."_value"] = value
        end

        local nodeRow = viewFactory:row {
            viewFactory:static_text {
                title = string.rep("    ", level),
                width = level * 25
            },
            viewFactory:edit_field {
                value = LrView.bind(nodeId.."_name"),
                width_in_chars = 20,
                immediate = true,
                changed = function(newName)
                    if newName ~= "" and newName ~= key then
                        data[newName] = data[key]
                        data[key] = nil
                        props[nodeId.."_name"] = newName
                        LrDialogs.stopModalWithResult(dialog, "refresh")
                    end
                end
            },
            isFolder and viewFactory:push_button {
                title = "+",
                action = function(dialog)
                    local newKey = "Neuer Knoten"
                    data[newKey] = {}
                    LrDialogs.stopModalWithResult(dialog, "refresh")
                end
            },
            viewFactory:push_button {
                title = "×",
                action = function(dialog)
                    data[key] = nil
                    LrDialogs.stopModalWithResult(dialog, "refresh")
                end,
                text_color = {0.8, 0.2, 0.2}
            }
        }

        if isFolder then
            table.insert(items, viewFactory:column {
                nodeRow,
                createTreeWidget(viewFactory, value, nodeId, level + 1)
            })
        else
            table.insert(items, viewFactory:row {
                nodeRow,
                viewFactory:edit_field {
                    value = LrView.bind(nodeId.."_value"),
                    width_in_chars = 15,
                    immediate = true,
                    changed = function(newValue)
                        data[key] = newValue
                        props[nodeId.."_value"] = newValue
                    end
                }
            })
        end
    end
    
    return viewFactory:column {
        spacing = 5,
        unpack(items)
    }
end

function showTreeDialog()
    LrFunctionContext.callWithContext("treeDialog", function(context)
        local factory = LrView.osFactory()
        props = LrBinding.makePropertyTable(context)
        
        -- Beispieldaten
        if not treeData then
            treeData = Defaults.defaultKeywordHierarchy
        end

        local content = factory:scrolled_view {
            bind_to_object = props,
            width = 500,
            height = 400,
            createTreeWidget(factory, treeData, "root", 0),
            factory:row {
                factory:push_button {
                    title = "Neuer Hauptordner",
                    action = function(dialog)
                        treeData["Neuer Ordner"] = {}
                        LrDialogs.stopModalWithResult(dialog, "refresh")
                    end
                },
            }
        }

        local result = LrDialogs.presentModalDialog {
            title = "Fotografie Manager",
            resizable = true,
            contents = content
        }

        log:trace(Util.dumpTable(props.treeData))

        if result == "refresh" then
            showTreeDialog()
        end
    end)
end

-- Initialaufruf
showTreeDialog()
