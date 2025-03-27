require "AiModelAPI"

SkipReviewCaptions = false
SkipReviewTitles = false
SkipReviewAltText = false
SkipReviewKeywords = false
SkipPreflightDialog = false
PreflightData = ""

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
        -- LrDialogs.message(LOC("$$$/lrc-ai-assistant/GenerateImageInfo/UsedTokens=Used tokens during process\nInput tokens: ^1 (USD ^3)\nOutput tokens: ^2 (USD ^4)\nTotal costs: USD ^5", totalInputTokens, totalOutputTokens, inputCosts, outputCosts, totalCosts))
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
        if type(key) == 'string' then
            photo.catalog:withWriteAccessDo("Create category keyword", function()
                -- log:trace('Creating keyword: ' .. key)
                keyword = photo.catalog:createKeyword(key, {}, false, parent, true)
                -- photo:addKeyword(keyword)
            end)
        elseif type(key) == 'number' then
            photo.catalog:withWriteAccessDo("Create and add keyword", function()
                -- log:trace('Creating keyword: ' .. value)
                keyword = photo.catalog:createKeyword(value, {}, true, parent, true)
                photo:addKeyword(keyword)
            end)
        end
        if type(value) == 'table' then
            -- log:trace('recurse')
            addKeywordRecursively(photo, value, keyword)
        end
    end
end

local function showPreflightDialog()
    local f = LrView.osFactory()
    local bind = LrView.bind
    local share = LrView.share

    local propertyTable = {}
    propertyTable.skipFromHere = SkipPreflightDialog
    propertyTable.preflightData = PreflightData

    local dialogView = f:column {
        bind_to_object = propertyTable,
        f:row {
            f:edit_field {
                value = bind 'preflightData',
                width_in_chars = 40,
                height_in_lines = 10,
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
        title = LOC "$$$/lrc-ai-assistant/GenerateImageInfo/PreflightDialogTitle=Preflight Dialog",
        contents = dialogView,
    })

    SkipPreflightDialog = propertyTable.skipFromHere

    if result == "ok" then
        PreflightData = propertyTable.preflightData
        return PreflightData
    elseif result == "cancel" then
        PreflightData = ""
        return PreflightData
    end
end

local function exportAndAnalyzePhoto(photo, progressScope)
    local tempDir = LrPathUtils.getStandardFilePath('temp')
    local photoName = LrPathUtils.leafName(photo:getFormattedMetadata('fileName'))

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

            -- Preflight Dialog
            if prefs.showPreflightDialog then
                if not SkipPreflightDialog then showPreflightDialog() end
                metadata.context = PreflightData
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
                log:trace(keywords)
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

            if type(keywords) == 'table' then
                local topKeyword
                photo.catalog:withWriteAccessDo("$$$/lrc-ai-assistant/GenerateImageInfo/saveTopKeyword=Save AI generated keywords", function()
                    topKeyword = photo.catalog:createKeyword(ai.topKeyword, {}, false, nil, true)
                    photo:addKeyword(topKeyword)
                end)
                addKeywordRecursively(photo, keywords, topKeyword)
            end

            -- Delete temp file.
            LrFileUtils.delete(path)

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