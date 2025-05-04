AnalyzeImageDialogs = {}

function AnalyzeImageDialogs.showTextValidationDialog(typeOfText, text)
    local f = LrView.osFactory()
    local bind = LrView.bind
    local share = LrView.share

    local propertyTable = {}
    propertyTable.skipFromHere = false
    propertyTable.reviewedText = text

    local dialogView = f:column {
        bind_to_object = propertyTable,
        f:row {
            f:static_text {
                title = typeOfText,
            },
        },
        f:row {
            f:edit_field {
                value = bind 'reviewedText',
                width_in_chars = 40,
                height_in_lines = 10,
            },
        },
        f:row {
            f:checkbox {
                value = bind 'skipFromHere'
            },
            f:static_text {
                title = LOC "$$$/lrc-ai-assistant/GenerateImageInfo/SkipFromHere=Save following without reviewing.",
            },
        },
    }

    local result = LrDialogs.presentModalDialog({
        -- title = 'Review Results',
        title = LOC "$$$/lrc-ai-assistant/GenerateImageInfo/ReviewWindowTitle=Review results",
        contents = dialogView,
    })

    propertyTable.result = result

    log:trace(result)

    return propertyTable
end

function AnalyzeImageDialogs.showUsedTokensDialog(totalInputTokens, totalOutputTokens)
    if Defaults.pricing[prefs.ai] == nil then
        log:trace("No cost information for selected AI model, not showing usedTokenDialog.")
        return nil
    end

    if prefs.showCosts then
        local inputCostPerToken = 0
        if Defaults.pricing[prefs.ai].input ~= nil then
            inputCostPerToken = Defaults.pricing[prefs.ai].input
        else
            return nil
        end

        local outputCostPerToken = 0
        if Defaults.pricing[prefs.ai].output ~= nil then
            outputCostPerToken = Defaults.pricing[prefs.ai].output
        else
            return nil
        end

        local inputCosts = totalInputTokens * inputCostPerToken
        local outputCosts = totalOutputTokens * outputCostPerToken
        local totalCosts = inputCosts + outputCosts

        local f = LrView.osFactory()
        local share = LrView.share
        local dialog = {}
        dialog.title = LOC "$$$/lrc-ai-assistant/GenerateImageInfo/UsedTokenDialog/Title=Generation costs"
        dialog.resizable = false
        dialog.contents = f:column {
            f:row {
                size = "small",
                f:column {
                    f:group_box {
                        width = share 'groupBoxWidth',
                        title = LOC "$$$/lrc-ai-assistant/GenerateImageInfo/UsedTokenDialog/UsedTokens=Used Tokens",
                        f:spacer {
                            width = share 'spacerWidth',
                        },
                        f:static_text {
                            title = 'Input:',
                            font = "<system/bold>",
                        },
                        f:static_text {
                            title = tostring(totalInputTokens),
                            width = share 'valWidth',
                        },
                        f:static_text {
                            title = 'Output:',
                            font = "<system/bold>",
                        },
                        f:static_text {
                            title = tostring(totalOutputTokens),
                            width = share 'valWidth',
                        },
                    },
                },
                f:column {
                    size = "small",
                    f:group_box {
                        width = share 'groupBoxWidth',
                        title = LOC "$$$/lrc-ai-assistant/GenerateImageInfo/UsedTokenDialog/GeneratedCosts=Generated costs",
                        f:spacer {
                            width = share 'spacerWidth',
                        },
                        f:static_text {
                            title = 'Input:',
                            font = "<system/bold>",
                        },
                        f:static_text {
                            title = tostring(inputCosts) .. " USD",
                            width = share 'valWidth',
                        },
                        f:static_text {
                            title = 'Output:',
                            font = "<system/bold>",
                        },
                        f:static_text {
                            title = tostring(outputCosts) .. " USD",
                            width = share 'valWidth',
                        },
                    },
                },
            },
            f:row {
                f:spacer {
                    height = 20,
                },
            },
            f:row {
                font = "<system/bold>",
                f:static_text {
                    title = LOC "$$$/lrc-ai-assistant/GenerateImageInfo/UsedTokenDialog/TotalCosts=Total costs:",
                },
                f:static_text {
                    title = tostring(totalCosts) .. " USD",
                },
            },
        }


        LrDialogs.presentModalDialog(dialog)
    end
end


function AnalyzeImageDialogs.showPhotoContextDialog(photo)
    local f = LrView.osFactory()
    local bind = LrView.bind
    local share = LrView.share

    local propertyTable = {}
    propertyTable.skipFromHere = SkipPhotoContextDialog
    local photoContextFromCatalog = photo:getPropertyForPlugin(_PLUGIN, 'photoContext')
    if photoContextFromCatalog ~= nil then
        PhotoContextData = photoContextFromCatalog
    end
    propertyTable.photoContextData = PhotoContextData

    local tempDir = LrPathUtils.getStandardFilePath('temp')
    local exportSettings = {
        LR_export_destinationType = 'specificFolder',
        LR_export_destinationPathPrefix = tempDir,
        LR_export_useSubfolder = false,
        LR_format = 'JPEG',
        LR_jpeg_quality = 60,
        LR_minimizeEmbeddedMetadata = true,
        LR_outputSharpeningOn = false,
        LR_size_doConstrain = true,
        LR_size_maxHeight = 460,
        LR_size_resizeType = 'longEdge',
        LR_size_units = 'pixels',
        LR_collisionHandling = 'rename',
        LR_includeVideoFiles = false,
        LR_removeLocationMetadata = true,
        LR_embeddedMetadataOption = "copyrightOnly",
    }

    local exportSession = LrExportSession({
        photosToExport = { photo },
        exportSettings = exportSettings
    })

    local photoPath = ""
    local renderSuccess = false
    for _, rendition in exportSession:renditions() do
        local success, path = rendition:waitForRender()
        if success then
            photoPath = path
            renderSuccess = success
        end
    end

    local dialogView = f:column {
        bind_to_object = propertyTable,
        f:row {
            f:static_text {
                title = photo:getFormattedMetadata('fileName'),
            },
        },
        f:row {
            f:spacer {
                height = 10,
            },
        },
        f:row {
            alignment = "center",
            f:picture {
                alignment = "center",
                value = photoPath,
                frame_width = 0,
            },
        },
        f:row {
            f:spacer {
                height = 10,
            },
        },
        f:row {
            f:static_text {
                title = LOC "$$$/lrc-ai-assistant/GenerateImageInfo/PhotoContextDialogData=Photo Context",
            },
        },
        f:row {
            f:spacer {
                height = 10,
            },
        },
        f:row {
            f:edit_field {
                value = bind 'photoContextData',
                width_in_chars = 40,
                height_in_lines = 10,
            },
        },
        f:row {
            f:spacer {
                height = 10,
            },
        },
        f:row {
            f:checkbox {
                value = bind 'skipFromHere'
            },
            f:static_text {
                title = LOC "$$$/lrc-ai-assistant/GenerateImageInfo/SkipPreflightFromHere=Use for all following pictures.",
            },
        },
    }

    local result = LrDialogs.presentModalDialog({
        title = LOC "$$$/lrc-ai-assistant/GenerateImageInfo/PhotoContextDialogData=Photo Context",
        contents = dialogView,
    })

    if renderSuccess then LrFileUtils.delete(photoPath) end

    SkipPhotoContextDialog = propertyTable.skipFromHere

    if result == "ok" then
        PhotoContextData = propertyTable.photoContextData
        return true
    elseif result == "cancel" then
        PhotoContextData = ""
        return false
    end
end

function AnalyzeImageDialogs.showPreflightDialog()
    local f = LrView.osFactory()
    local bind = LrView.bind
    local share = LrView.share

    local propertyTable = {}
    propertyTable.task = prefs.task
    propertyTable.systemInstruction = prefs.systemInstruction

    propertyTable.generateTitle = prefs.generateTitle
    propertyTable.generateCaption = prefs.generateCaption
    propertyTable.generateKeywords = prefs.generateKeywords
    propertyTable.generateAltText = prefs.generateAltText

    propertyTable.reviewTitle = prefs.reviewTitle
    propertyTable.reviewCaption = prefs.reviewCaption
    propertyTable.reviewKeywords = prefs.reviewKeywords
    propertyTable.reviewAltText = prefs.reviewAltText

    propertyTable.ai = prefs.ai
    propertyTable.showCosts = prefs.showCosts
    propertyTable.showPhotoContextDialog = prefs.showPhotoContextDialog

    propertyTable.submitGPS = prefs.submitGPS
    propertyTable.submitKeywords = prefs.submitKeywords

    propertyTable.temperature = prefs.temperature


    local dialogView = f:column {
        spacing = 10,
        bind_to_object = propertyTable,
        f:row {
            f:static_text {
                width = share 'labelWidth',
                title = "Model:",
                alignment = "right",
            },
            f:popup_menu {
                value = bind 'ai',
                items = Defaults.getAvailableAiModels(),
            },
        },
        f:row {
            f:static_text {
                width = share 'labelWidth',
                title = "AI behavior:",
                alignment = "right",
            },
            f:static_text {
                title = "Be coherent"
            },
            f:slider {
                value = bind 'temperature',
                min = 0.0,
                max = 1.0,
                immediate = true,
            },
            f:static_text {
                title = "Be creative"
            },
        },
        f:row {
            f:static_text {
                width = share 'labelWidth',
                title = "Task:",
                alignment = "right",
            },
            f:edit_field {
                value = bind 'task',
                width_in_chars = 40,
                height_in_lines = 8,
                wraps = true,
            }
        },
        f:row {
            f:static_text {
                width = share 'labelWidth',
                title = "System instruction:",
                alignment = "right",
            },
            f:edit_field {
                value = bind 'systemInstruction',
                width_in_chars = 40,
                height_in_lines = 8,
                wraps = true,
            }
        },
        f:row {
            f:static_text {
                width = share 'labelWidth',
                alignment = "right",
                title = "Submit:",
            },
            f:checkbox {
                value = bind 'submitKeywords',
                width = share 'checkboxWidth',
            },
            f:static_text {
                title = "Existing keywords"
            },
            f:checkbox {
                value = bind 'submitGPS',
                width = share 'checkboxWidth',
            },
            f:static_text {
                title = "GPS coordinates"
            },
        },
        f:row {
            f:static_text {
                width = share 'labelWidth',
                title = "Costs:",
                alignment = "right",
            },
            f:checkbox {
                value = bind 'showCosts',
                width = share 'checkboxWidth'
            },
            f:static_text {
                title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/showCosts=Show costs (without any warranty!!!)",
            },
        },
        f:row {
            f:static_text {
                title = "Generate:",
                alignment = 'right',
                width = share 'labelWidth',
            },
            f:checkbox {
                value = bind 'generateCaption',
                width = share 'checkboxWidth',
            },
            f:static_text {
                title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/caption=Caption",
            },
            f:checkbox {
                value = bind 'generateAltText',
                width = share 'checkboxWidth',
            },
            f:static_text {
                title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/alttext=Alt Text",
            },
            f:checkbox {
                value = bind 'generateTitle',
                width = share 'checkboxWidth',
            },
            f:static_text {
                title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/title=Title",
            },
            f:checkbox {
                value = bind 'generateKeywords',
                width = share 'checkboxWidth',
            },
            f:static_text {
                title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/keywords=Keywords",
            },
        },
        f:row {
            f:static_text {
                title = "Validate:",
                alignment = 'right',
                width = share 'labelWidth',
            },
            f:checkbox {
                value = bind 'reviewCaption',
                width = share 'checkboxWidth',
                enabled = bind 'generateCaption',
            },
            f:static_text {
                title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/caption=Caption",
            },
            f:checkbox {
                value = bind 'reviewAltText',
                width = share 'checkboxWidth',
                enabled = bind 'generateAltText',
            },
            f:static_text {
                title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/alttext=Alt Text",
            },
            f:checkbox {
                value = bind 'reviewTitle',
                width = share 'checkboxWidth',
                enabled = bind 'generateTitle',
            },
            f:static_text {
                title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/title=Title",
            },
            f:checkbox {
                value = bind 'reviewKeywords',
                width = share 'checkboxWidth',
                enabled = false,
            },
            f:static_text {
                title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/keywords=Keywords",
            },
        },
        f:row {
            f:static_text {
                title = "Context:",
                width = share 'labelWidth',
                alignment = "right",
            },
            f:checkbox {
                value = bind 'showPhotoContextDialog',
                width = share 'checkboxWidth'
            },
            f:static_text {
                title = LOC "$$$/lrc-ai-assistant/PluginInfoDialogSections/showPhotoContextDialog=Show Photo Context dialog",
                width = share 'labelWidth',
            },
        },
    }

    local result = LrDialogs.presentModalDialog({
        title = LOC "$$$/lrc-ai-assistant/GenerateImageInfo/PreflightDialogTitle=Preflight Dialog",
        contents = dialogView,
    })

    if result == "ok" then
        prefs.task = propertyTable.task
        prefs.systemInstruction = propertyTable.systemInstruction
    
        prefs.generateTitle = propertyTable.generateTitle
        prefs.generateCaption = propertyTable.generateCaption
        prefs.generateKeywords = propertyTable.generateKeywords
        prefs.generateAltText = propertyTable.generateAltText
    
        prefs.reviewTitle = propertyTable.reviewTitle
        prefs.reviewCaption = propertyTable.reviewCaption
        prefs.reviewKeywords = propertyTable.reviewKeywords
        prefs.reviewAltText = propertyTable.reviewAltText
    
        prefs.ai = propertyTable.ai
        prefs.showCosts = propertyTable.showCosts
        prefs.showPhotoContextDialog = propertyTable.showPhotoContextDialog

        prefs.submitGPS = propertyTable.submitGPS
        prefs.submitKeywords = propertyTable.submitKeywords

        prefs.temperature = propertyTable.temperature
        
        return true
    elseif result == "cancel" then
        return false
    end
end
