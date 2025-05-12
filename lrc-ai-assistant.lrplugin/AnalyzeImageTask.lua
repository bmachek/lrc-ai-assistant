
SkipReviewCaptions = false
SkipReviewTitles = false
SkipReviewAltText = false
SkipReviewKeywords = false
SkipPhotoContextDialog = false
PhotoContextData = ""
PerfLogFile = nil


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
                    local contextResult = AnalyzeImageProvider.showPhotoContextDialog(photo)
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

            local startTimeAnalyze = LrDate.currentTime()
            local analyzeSuccess, result, inputTokens, outputTokens = ai:analyzeImage(path, metadata)
            local stopTimeAnalyze = LrDate.currentTime()

            log:trace("Analyzing " .. photoName .. " with " .. prefs.ai .. " took " .. (stopTimeAnalyze - startTimeAnalyze) .. " seconds.")

            if not analyzeSuccess then -- AI API request failed.
                if result == 'RATE_LIMIT_EXHAUSTED' then
                    LrDialogs.showError(LOC "$$$/lrc-ai-assistant/AnalyzeImageTask/rateLimit=Quota exhausted, set up pay as you go at Google, or wait for some hours.")
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
            photo.catalog:withWriteAccessDo(LOC "$$$/lrc-ai-assistant/AnalyzeImageTask/saveTitleCaption=Save AI generated title and caption", function()
                local saveCaption = true
                if prefs.generateCaption and prefs.reviewCaption and not SkipReviewCaptions then
                    -- local existingCaption = photo:getFormattedMetadata('caption')
                    local prop = AnalyzeImageProvider.showTextValidationDialog(LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageCaption=Image caption", caption)
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
                    local prop = AnalyzeImageProvider.showTextValidationDialog(LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageTitle=Image title", title)
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
                    local prop = AnalyzeImageProvider.showTextValidationDialog(LOC "$$$/lrc-ai-assistant/Defaults/ResponseStructure/ImageAltText=Image Alt Text", altText)
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
                local topKeyword = nil
                if prefs.useKeywordHierarchy and prefs.useTopLevelKeyword then
                    photo.catalog:withWriteAccessDo("$$$/lrc-ai-assistant/AnalyzeImageTask/saveTopKeyword=Save AI generated keywords", function()
                        topKeyword = photo.catalog:createKeyword(ai.topKeyword, {}, false, nil, true)
                        photo:addKeyword(topKeyword)
                    end)
                end
                AnalyzeImageProvider.addKeywordRecursively(photo, keywords, topKeyword)
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

            if prefs.perfLogging and PerfLogFile ~= nil then
                PerfLogFile:write(photoName .. ";" .. (stopTimeAnalyze - startTimeAnalyze) .. ";" .. prefs.ai .. ";" ..  prefs.prompt .. ";" .. 
                prefs.generateLanguage .. ";" .. tostring(prefs.temperature) .. ";" .. tostring(prefs.generateKeywords) .. ";" .. 
                tostring(prefs.useKeywordHierarchy) .. ";" .. tostring(prefs.generateAltText) .. 
                ";" .. tostring(prefs.generateTitle) .. ";" .. tostring(prefs.generateCaption) .. ";" .. prefs.exportSize .. ";" .. prefs.exportQuality .. "\n")
            end

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
    LrFunctionContext.callWithContext("AnalyzeImageTask", function(context)
        local startTimeBatch = LrDate.currentTime()

        local catalog = LrApplication.activeCatalog()
        local selectedPhotos = catalog:getTargetPhotos()

        log:trace("Starting AnalyzeImageTask")

        if prefs.perfLogging then
            local path = LrPathUtils.child(LrPathUtils.getStandardFilePath("desktop"), "perflog.csv")
            PerfLogFile = io.open(path, "a")
            if PerfLogFile ~= nil then
                PerfLogFile:write("Filename;Duration;Model;Prompt;Language;Temperature;GenKeywords;useKeywordHierarchy;GenAltText;GenTitle;GenCaption;Export size;ExportQuality\n")
            end
        end

        if #selectedPhotos == 0 then
            LrDialogs.showError(LOC "$$$/lrc-ai-assistant/AnalyzeImageTask/noPhotos=Please select at least one photo.")
            return
        end

        if not prefs.generateCaption and not prefs.generateTitle and not prefs.generateKeywords and not prefs.generateAltText then
            LrDialogs.showError(LOC "$$$/lrc-ai-assistant/AnalyzeImageTask/nothingToGenerate=Nothing selected to generate, check add-on manager settings.")
            return
        end

        if prefs.showPreflightDialog then
            local preflightResult = AnalyzeImageProvider.showPreflightDialog(context)
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
            progressScope:setCaption(LOC("$$$/lrc-ai-assistant/AnalyzeImageTask/caption=Analyzing photo with ^1. Photo ^2/^3", prefs.ai, tostring(i), tostring(totalPhotos)))

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
                    progressScope:setCaption(LOC("$$$/lrc-ai-assistant/AnalyzeImageTask/analyzeFailed=Failed to analyze photo with AI ^1", tostring(i)))
                    LrDialogs.showError(LOC "$$$/lrc-ai-assistant/AnalyzeImageTask/fatalError=Fatal error: Cannot continue. Check logs.")
                    AnalyzeImageProvider.showUsedTokensDialog(totalInputTokens, totalOutputTokens)
                    return false
                elseif cause == "canceled" then
                    log:trace("Canceled by user validation dialog.")
                    AnalyzeImageProvider.showUsedTokensDialog(totalInputTokens, totalOutputTokens)
                    return false
                end
                    
            else
                totalSuccess = totalSuccess + 1
            end
            progressScope:setPortionComplete(i, totalPhotos)
            if progressScope:isCanceled() then
                log:trace("We got canceled.")
                AnalyzeImageProvider.showUsedTokensDialog(totalInputTokens, totalOutputTokens)
                return false
            end
        end

        progressScope:done()
        local stopTimeBatch = LrDate.currentTime()
        log:trace("Analyzing " .. totalPhotos .. " with " .. prefs.ai .. " took " .. (stopTimeBatch - startTimeBatch) .. " seconds.")

        if prefs.perfLogging and PerfLogFile ~= nil then
            PerfLogFile:close()
        end

        AnalyzeImageProvider.showUsedTokensDialog(totalInputTokens, totalOutputTokens)

        if totalFailed > 0 then
            local errorList
            for name, error in pairs(errorMessages) do
                errorList = name .. " : " .. error .. "\n"
            end
            LrDialogs.message(LOC("$$$/lrc-ai-assistant/AnalyzeImageTask/failedPhotos=Failed photos\n^1", errorList))
        end
    end)
end)