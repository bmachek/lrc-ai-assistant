
function createTreeWidget(viewFactory, props, path)
    local items = {}

    local subTable = props[path]

    if type(subTable) == "table" then
        for key, value in pairs(subTable) do
            local seen -- Helper to prevent endless loop due to circular graph in table.
            local subPath = Util.deepcopy(path, seen)
            table.insert(subPath, key)
            log:debug(Util.dumpTable(subPath) .. " - " .. type(props[subPath]))
            local level = #subPath - 1
            local isFolder = type(value) == "table"

            local nodeRow = viewFactory:row {
                viewFactory:static_text {
                    title = string.rep("    ", level),
                    width = level * 25
                },
                viewFactory:edit_field {
                    value = LrView.bind(subPath),
                    width_in_chars = 20,
                    immediate = false,
                },
                isFolder and viewFactory:push_button {
                    title = "+",
                    action = function(dialog)
                        local newPath = Util.deepcopy(subPath)
                        table.insert(newPath, "new")
                        props[newPath] = {}
                        LrDialogs.stopModalWithResult(dialog, "refresh")
                    end
                },
                viewFactory:push_button {
                    title = "×",
                    action = function(dialog)
                        props[subPath] = nil
                        LrDialogs.stopModalWithResult(dialog, "refresh")
                    end,
                    text_color = {0.8, 0.2, 0.2}
                }
            }
            if isFolder then
                table.insert(items, viewFactory:column {
                    nodeRow,
                    createTreeWidget(viewFactory, props, subPath)
                })
            end
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
        local props = LrBinding.makePropertyTable(context)

        -- Initialdaten falls nicht vorhanden
        if prefs.keywordHierarchy == nil then
            prefs.keywordHierarchy = Defaults.defaultKeywordHierarchy
        end

        log:trace("1")

        props.keywordHierarchy = prefs.keywordHierarchy
        log:trace("2")

        local content = factory:scrolled_view {
            bind_to_object = props,
            width = 500,
            height = 400,
            createTreeWidget(factory, props, { }),
            factory:row {
                factory:push_button {
                    title = "+",
                    action = function(dialog)
                        props[{ "keywordHierarchy", "New" }] = {}
                        LrDialogs.stopModalWithResult(dialog, "refresh")
                    end
                },
            }
        }

        log:trace("3")

        local result = LrDialogs.presentModalDialog {
            title = "Keyword Hierarchy Manager",
            resizable = true,
            contents = content,
            otherVerb = "Reset to defaults",
        }

        log:trace("4")

        if result == "refresh" then
            showTreeDialog()
        elseif result == "ok" then
            --prefs.keywordHierarchy = props.keywordHierarchy
            log:trace(Util.dumpTable(prefs.keywordHierarchy))
        elseif result == "other" then
            local confirm = LrDialogs.confirm("Reset to default tree structure?")
            if confirm == "ok" then
                log:trace("Reset keyword hierarchy to default")
                prefs.keywordHierarchy = Defaults.defaultKeywordHierarchy
            end
        end
    end)
end

showTreeDialog()
