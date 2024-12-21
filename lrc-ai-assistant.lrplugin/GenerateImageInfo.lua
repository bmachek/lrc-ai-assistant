require "AiModelAPI"

SkipReviewCaptions = false
SkipReviewTitles = false
SkipReviewAltText = false

local function validateText(text)
    local f = LrView.osFactory()
    local bind = LrView.bind
    local share = LrView.share

    local propertyTable = {}
    propertyTable.skipFromHere = false
    propertyTable.reviewedText = text

    local dialogView = f:column {
        bind_to_object = propertyTable,
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
        title = 'Review Results',
        contents = dialogView,
    })

    propertyTable.result = result

    return propertyTable
end

local function showUsedTokensDialog(totalInputTokens, totalOutputTokens)
    if prefs.showCosts then
        local inputCosts = totalInputTokens * Defaults.pricing[prefs.ai].input
        local outputCosts = totalOutputTokens * Defaults.pricing[prefs.ai].output
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

local function exportAndAnalyzePhoto(photo, progressScope)
    local tempDir = LrPathUtils.getStandardFilePath('temp')
    local photoName = LrPathUtils.leafName(photo:getFormattedMetadata('fileName'))

    local exportSettings = {
        LR_export_destinationType = 'specificFolder',
        LR_export_destinationPathPrefix = tempDir,
        LR_export_useSubfolder = false,
        LR_format = 'JPEG',
        LR_jpeg_quality = 0.5,
        LR_minimizeEmbeddedMetadata = true,
        LR_outputSharpeningOn = false,
        LR_size_doConstrain = true,
        LR_size_maxHeight = 2048,
        LR_size_resizeType = 'longEdge',
        LR_size_units = 'pixels',
        LR_collisionHandling = 'rename',
        LR_includeVideoFiles = false,
        LR_removeLocationMetadata = true,
        LR_embeddedMetadataOption = "all",
    }

    local exportSession = LrExportSession({
        photosToExport = { photo },
        exportSettings = exportSettings
    })

    local ai
    ai = AiModelAPI:new()

    if ai == nil then
        return false, 0, 0, true
    end

    for _, rendition in exportSession:renditions() do
        local success, path = rendition:waitForRender()
        local metadata = {}

        metadata.gps = photo:getRawMetadata("gps")

        if success then
            local analyzeSuccess, result, inputTokens, outputTokens = ai:analyzeImage(path, metadata)

            if result == 'RATE_LIMIT_EXHAUSTED' then
                LrDialogs.showError(LOC "$$$/lrc-ai-assistant/GenerateImageInfo/rateLimit=Quota exhausted, set up pay as you go at Google, or wait for some hours.")
                return false, inputTokens, outputTokens, true
            end

            local title, caption, keywords, altText
            if result ~= nil and analyzeSuccess then
                keywords = result.keywords
                title = result[LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageTitle=Image title"]
                caption = result[LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageCaption=Image caption"]
                altText = result[LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageAltText=Image Alt Text"]
            end


            photo.catalog:withWriteAccessDo(LOC "$$$/lrc-ai-assistant/GenerateImageInfo/saveTitleCaption=Save AI generated title and caption", function()
                local saveCaption = true
                if prefs.reviewCaption and not SkipReviewCaptions then
                    -- local existingCaption = photo:getFormattedMetadata('caption')
                    local prop = validateText(caption)
                    caption = prop.reviewedText
                    SkipReviewCaptions = prop.skipFromHere
                    if prop.result == 'cancel' then
                        saveCaption = false
                    end
                end
                if saveCaption and caption ~=nil then
                    photo:setRawMetadata('caption', caption)
                end

                local saveTitle = true
                if prefs.reviewTitle and not SkipReviewTitles then
                    -- local existingTitle = photo:getFormattedMetadata('title')
                    local prop = validateText(title)
                    title = prop.reviewedText
                    SkipReviewTitles = prop.skipFromHere
                    if prop.result == 'cancel' then
                        saveTitle = false
                    end
                end

                if saveTitle and title ~= nil then
                    photo:setRawMetadata('title', title)
                end

                local saveAltText = true
                if prefs.reviewAltText and not SkipReviewAltText then
                    -- local existingTitle = photo:getFormattedMetadata('title')
                    local prop = validateText(altText)
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

            return true, inputTokens, outputTokens, false
        else
            return false, 0, 0, false
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

        if not prefs.generateCaption and not prefs.generateTitle and not prefs.generateKeywords then
            LrDialogs.showError(LOC "$$$/lrc-ai-assistant/GenerateImageInfo/nothingToGenerate=Nothing selected to generate, check add-on manager settings.")
            return
        end

        local progressScope = LrProgressScope({
            title = "Analyzing photos with " .. prefs.ai,
            functionContext = context,
        })

        local totalPhotos = #selectedPhotos
        local totalFailed = 0
        local failedPhotos = {}
        local totalSuccess = 0
        local totalInputTokens = 0
        local totalOutputTokens = 0
        for i, photo in ipairs(selectedPhotos) do
            progressScope:setPortionComplete(i - 1, totalPhotos)
            progressScope:setCaption(LOC("$$$/lrc-ai-assistant/GenerateImageInfo/caption=Analyzing photo with ^1. Photo ^2/^3", prefs.ai, tostring(i), tostring(totalPhotos)))
            local success, inputTokens, outputTokens, fatalError = exportAndAnalyzePhoto(photo, progressScope)
            if inputTokens ~= nil then
                totalInputTokens = totalInputTokens + inputTokens
            end
            if outputTokens ~= nil then
                totalOutputTokens = totalOutputTokens + outputTokens
            end
            if not success then
                totalFailed = totalFailed + 1
                table.insert(failedPhotos, photo:getFormattedMetadata("fileName"))
                if fatalError then
                    progressScope:setCaption(LOC("$$$/lrc-ai-assistant/GenerateImageInfo/analyzeFailed=Failed to analyze photo with AI ^1", tostring(i)))
                    LrDialogs.showError(LOC "$$$/lrc-ai-assistant/GenerateImageInfo/fatalError=Fatal error: Cannot continue. Check logs.")
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
            LrDialogs.message(LOC("$$$/lrc-ai-assistant/GenerateImageInfo/failedPhotos=Failed photos\n^1", table.concat(failedPhotos, "\n")))
        end
    end)
end)