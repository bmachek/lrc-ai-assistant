require "AiModelAPI"

SkipReviewCaptions = false
SkipReviewTitles = false
SkipReviewAltText = false
SkipReviewKeywords = false
SkipPhotoContextDialog = false
PhotoContextData = ""

local function validateText(typeOfText, text)
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

local function showUsedTokensDialog(totalInputTokens, totalOutputTokens)
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

local function addKeywordRecursively(photo, keywordSubTable, parent)
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
            addKeywordRecursively(photo, value, keyword)
        end
    end
end

local function showPhotoContextDialog(photo)
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

local function showPreflightDialog()
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
                height_in_lines = 5,
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
                height_in_lines = 5,
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

local function exportAndAnalyzePhoto(photo, progressScope)
    local tempDir = LrPathUtils.getStandardFilePath('temp')
    local photoName = LrPathUtils.leafName(photo:getFormattedMetadata('fileName'))
    local catalog = LrApplication.activeCatalog()

    local exportSettings = {
        LR_export_destinationType = 'specificFolder',
        LR_export_destinationPathPrefix = tempDir,
        LR_export_useSubfolder = false,
        LR_format = 'JPEG',
        LR_jpeg_quality = tonumber(prefs.exportQuality) / 100,
        LR_minimizeEmbeddedMetadata = false,
        LR_outputSharpeningOn = false,
        LR_size_doConstrain = true,
        LR_size_maxHeight = tonumber(prefs.exportSize),
        LR_size_resizeType = 'longEdge',
        LR_size_units = 'pixels',
        LR_collisionHandling = 'rename',
        LR_includeVideoFiles = false,
        LR_removeLocationMetadata = false,
        LR_embeddedMetadataOption = "all",
    }

    log:trace('Export settings are: ' .. prefs.exportSize .. "px (long edge) and " .. prefs.exportQuality .. "% JPEG quality")

    local exportSession = LrExportSession({
        photosToExport = { photo },
        exportSettings = exportSettings
    })

    local ai
    ai = AiModelAPI:new()

    if ai == nil then
        return false, 0, 0, "fatal"
    end

    for _, rendition in exportSession:renditions() do
        local success, path = rendition:waitForRender()
        local metadata = {}

        metadata.gps = photo:getRawMetadata("gps")
        metadata.keywords = photo:getFormattedMetadata("keywordTagsForExport")

        if success then -- Export successful
            
            log:trace("Export file size: " .. (LrFileUtils.fileAttributes(path).fileSize / 1024) .. "kB")

            -- Photo Context Dialog
            if prefs.showPhotoContextDialog then
                if not SkipPhotoContextDialog then
                    local contextResult = showPhotoContextDialog(photo)
                    if not contextResult then
                        return false, 0, 0, "canceled", "Canceled by user in context dialog."
                    end
                end
                metadata.context = PhotoContextData
                catalog:withPrivateWriteAccessDo(function(context)
                        log:trace("Saving photo context data to metadata.")
                        photo:setPropertyForPlugin(_PLUGIN, 'photoContext', PhotoContextData)
                    end
                )
            end

            local analyzeSuccess, result, inputTokens, outputTokens = ai:analyzeImage(path, metadata)

            if not analyzeSuccess then -- AI API request failed.
                if result == 'RATE_LIMIT_EXHAUSTED' then
                    LrDialogs.showError(LOC "$$$/lrc-ai-assistant/GenerateImageInfo/rateLimit=Quota exhausted, set up pay as you go at Google, or wait for some hours.")
                    return false, inputTokens, outputTokens, "fatal", result
                end
                return false, inputTokens, outputTokens, "non-fatal", result
            end

            local title, caption, keywords, altText
            if result ~= nil and analyzeSuccess then
                keywords = result.keywords
                log:trace(Util.dumpTable(keywords))
                title = result[LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageTitle=Image title"]
                log:trace(title)
                caption = result[LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageCaption=Image caption"]
                log:trace(caption)
                altText = result[LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageAltText=Image Alt Text"]
                log:trace(altText)
            end

            local canceledByUser = false
            photo.catalog:withWriteAccessDo(LOC "$$$/lrc-ai-assistant/GenerateImageInfo/saveTitleCaption=Save AI generated title and caption", function()
                
                local saveCaption = true
                if prefs.generateCaption and prefs.reviewCaption and not SkipReviewCaptions then
                    -- local existingCaption = photo:getFormattedMetadata('caption')
                    local prop = validateText(LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageCaption=Image caption", caption)
                    caption = prop.reviewedText
                    SkipReviewCaptions = prop.skipFromHere
                    if prop.result == 'cancel' then
                        log:trace("Canceled by caption validation dialog.")
                        canceledByUser = true
                    end
                end
                if saveCaption and caption ~=nil then
                    photo:setRawMetadata('caption', caption)
                end

                local saveTitle = true
                if prefs.generateTitle and prefs.reviewTitle and not SkipReviewTitles then
                    -- local existingTitle = photo:getFormattedMetadata('title')
                    local prop = validateText(LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageTitle=Image title", title)
                    title = prop.reviewedText
                    SkipReviewTitles = prop.skipFromHere
                    if prop.result == 'cancel' then
                        log:trace("Canceled by title validation dialog.")
                        canceledByUser = true
                    end
                end

                if saveTitle and title ~= nil then
                    photo:setRawMetadata('title', title)
                end

                local saveAltText = true
                if prefs.generateAltText and prefs.reviewAltText and not SkipReviewAltText then
                    -- local existingTitle = photo:getFormattedMetadata('title')
                    local prop = validateText(LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageAltText=Image Alt Text", altText)
                    if prop.result == 'cancel' then
                        log:trace("Canceled by Alt-Text validation dialog.")
                        canceledByUser = true
                    end
                    altText = prop.reviewedText
                    SkipReviewAltText = prop.skipFromHere
                    if prop.result == 'cancel' then
                        saveAltText = false
                    end
                end

                if saveAltText and altText ~= nil then
                    photo:setRawMetadata('altTextAccessibility', altText)
                end
            end)

            if keywords ~= nil and type(keywords) == 'table' then
                local topKeyword
                photo.catalog:withWriteAccessDo("$$$/lrc-ai-assistant/GenerateImageInfo/saveTopKeyword=Save AI generated keywords", function()
                    topKeyword = photo.catalog:createKeyword(ai.topKeyword, {}, false, nil, true)
                    photo:addKeyword(topKeyword)
                end)
                addKeywordRecursively(photo, keywords, topKeyword)
            end

            -- Delete temp file.
            LrFileUtils.delete(path)

            -- Save metadata informations to catalog.
            catalog:withPrivateWriteAccessDo(function(context)
                log:trace("Save AI run model and date to metadata")
                photo:setPropertyForPlugin(_PLUGIN, 'aiModel', prefs.ai)
                local offset, daylight = LrDate.timeZone()
                local lastRunDateTime = LrDate.timeToW3CDate(LrDate.currentTime() + offset)
                photo:setPropertyForPlugin(_PLUGIN, 'aiLastRun', lastRunDateTime)
            end
        )

            if canceledByUser then
               return false, inputTokens, outputTokens, "canceled", "Canceled by user."
            end

            return true, inputTokens, outputTokens, "non-fatal", ""
        else
            return false, 0, 0, "non-fatal", "Photo rendering failed."
        end
    end
end

LrTasks.startAsyncTask(function()
    LrFunctionContext.callWithContext("GenerateImageInfo", function(context)
        local catalog = LrApplication.activeCatalog()
        local selectedPhotos = catalog:getTargetPhotos()

        log:trace("Starting GenerateImageInfo")

        if #selectedPhotos == 0 then
            LrDialogs.showError(LOC "$$$/lrc-ai-assistant/GenerateImageInfo/noPhotos=Please select at least one photo.")
            return
        end

        if not prefs.generateCaption and not prefs.generateTitle and not prefs.generateKeywords and not prefs.generateAltText then
            LrDialogs.showError(LOC "$$$/lrc-ai-assistant/GenerateImageInfo/nothingToGenerate=Nothing selected to generate, check add-on manager settings.")
            return
        end

        if prefs.showPreflightDialog then
            local preflightResult = showPreflightDialog()
            if not preflightResult then
                log:trace("Canceled by preflight dialog")
                return false
            end
        end

        local progressScope = LrProgressScope({
            title = "Analyzing photos with " .. prefs.ai,
            functionContext = context,
        })

        local totalPhotos = #selectedPhotos
        local totalFailed = 0
        local errorMessages = {}
        local totalSuccess = 0
        local totalInputTokens = 0
        local totalOutputTokens = 0
        for i, photo in ipairs(selectedPhotos) do
            progressScope:setPortionComplete(i - 1, totalPhotos)
            progressScope:setCaption(LOC("$$$/lrc-ai-assistant/GenerateImageInfo/caption=Analyzing photo with ^1. Photo ^2/^3", prefs.ai, tostring(i), tostring(totalPhotos)))

            log:trace("Analyzing " .. photo:getFormattedMetadata('fileName'))

            local success, inputTokens, outputTokens, cause, errorMessage = exportAndAnalyzePhoto(photo, progressScope)
            if inputTokens ~= nil then
                totalInputTokens = totalInputTokens + inputTokens
            end
            if outputTokens ~= nil then
                totalOutputTokens = totalOutputTokens + outputTokens
            end
            if not success then
                totalFailed = totalFailed + 1
                errorMessages[photo:getFormattedMetadata('fileName')] = errorMessage
                log:error("Unsuccessful photo analysis: " .. photo:getFormattedMetadata('fileName'))
                if cause == "fatal" then
                    log:trace("Fatal error received. Stopping.")
                    progressScope:setCaption(LOC("$$$/lrc-ai-assistant/GenerateImageInfo/analyzeFailed=Failed to analyze photo with AI ^1", tostring(i)))
                    LrDialogs.showError(LOC "$$$/lrc-ai-assistant/GenerateImageInfo/fatalError=Fatal error: Cannot continue. Check logs.")
                    showUsedTokensDialog(totalInputTokens, totalOutputTokens)
                    return false
                elseif cause == "canceled" then
                    log:trace("Canceled by user validation dialog.")
                    showUsedTokensDialog(totalInputTokens, totalOutputTokens)
                    return false
                end
                    
            else
                totalSuccess = totalSuccess + 1
            end
            progressScope:setPortionComplete(i, totalPhotos)
            if progressScope:isCanceled() then
                log:trace("We got canceled.")
                showUsedTokensDialog(totalInputTokens, totalOutputTokens)
                return false
            end
        end

        progressScope:done()
        showUsedTokensDialog(totalInputTokens, totalOutputTokens)

        if totalFailed > 0 then
            local errorList
            for name, error in pairs(errorMessages) do
                errorList = name .. " : " .. error .. "\n"
            end
            LrDialogs.message(LOC("$$$/lrc-ai-assistant/GenerateImageInfo/failedPhotos=Failed photos\n^1", errorList))
        end
    end)
end)