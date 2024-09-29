require "AiModelAPI"

SkipReviewCaptions = false
SkipReviewTitles = false

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
                title = 'Skip from here'
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


local function exportAndAnalyzePhoto(photo, progressScope)
    local tempDir = LrPathUtils.getStandardFilePath('temp')
    local photoName = LrPathUtils.leafName(photo:getFormattedMetadata('fileName'))

    local exportSettings = {
        LR_export_destinationType = 'specificFolder',
        LR_export_destinationPathPrefix = tempDir,
        LR_export_useSubfolder = false,
        LR_format = 'JPEG',
        LR_jpeg_quality = 0.6,
        LR_minimizeEmbeddedMetadata = true,
        LR_outputSharpeningOn = false,
        LR_size_doConstrain = true,
        LR_size_maxHeight = 2000,
        LR_size_maxWidth = 2000,
        LR_size_resizeType = 'wh',
        LR_size_units = 'pixels',
        LR_collisionHandling = 'rename',
        LR_includeVideoFiles = false,
    }

    local exportSession = LrExportSession({
        photosToExport = { photo },
        exportSettings = exportSettings
    })

    local ai
    ai = AiModelAPI:new()

    if ai == nil then
        return false
    end
    for _, rendition in exportSession:renditions() do
        local success, path = rendition:waitForRender()
        if success then
            local title
            local caption
            local keywords
            local titleSuccess = false
            local captionSuccess = false
            local keywordsSuccess = false

            if prefs.generateKeywords then
                keywordsSuccess, keywords = ai:keywordsTask(path)
            end

            if prefs.generateCaption then
                if not util.nilOrEmpty(prefs.captionTask) then
                    captionSuccess, caption = ai:imageTask(prefs.captionTask, path)
                else
                    util.handleError('No question for caption configured.', 'No question for caption configured.')
                end
            end
            if prefs.generateTitle then
                if not util.nilOrEmpty(prefs.titleTask) then
                    titleSuccess, title = ai:imageTask(prefs.titleTask, path)
                else
                    util.handleError('No question for title configured.', 'No question for title configured.')
                end
            end

            if caption == 'RATE_LIMIT_EXHAUSTED' or title == 'RATE_LIMIT_EXHAUSTED' or keywords == 'RATE_LIMIT_EXHAUSTED' then
                LrDialogs.showError("Rate limit exhausted 10 times in a row. Please try again in 24h")
                return false
            end

            photo.catalog:withWriteAccessDo("Save AI generated description", function()
                if keywordsSuccess and keywords ~= nil then
                    local catalog = LrApplication.activeCatalog()
                    local topKeyword = catalog:createKeyword(ai.topKeyword, {}, false, nil, true)
                    photo:addKeyword(topKeyword)

                    for _, keywordName in ipairs(keywords) do
                        if not util.nilOrEmpty(keywordName) then
                            local keyword = catalog:createKeyword(keywordName, {}, true, topKeyword, true)
                            if keyword then
                                photo:addKeyword(keyword)
                            end
                        end
                    end


                end

                if captionSuccess then
                    local saveCaption = true
                    if prefs.reviewCaption and not SkipReviewCaptions then
                        local existingCaption = photo:getFormattedMetadata('caption')
                        local prop = validateText(caption)
                        caption = prop.reviewedText
                        SkipReviewCaptions = prop.skipFromHere
                        if prop.result == 'cancel' then
                            saveCaption = false
                        end

                    end
                    if saveCaption then
                        photo:setRawMetadata('caption', caption)
                    end
                end

                if titleSuccess then
                    local saveTitle = true
                    if prefs.reviewTitle and not SkipReviewTitles then
                        local existingTitle = photo:getFormattedMetadata('title')
                        local prop = validateText(title)
                        title = prop.reviewedText
                        SkipReviewTitles = prop.skipFromHere
                        if prop.result == 'cancel' then
                            saveTitle = false
                        end
                    end
                    
                    if saveTitle then
                        photo:setRawMetadata('title', title)
                    end
                end
            end)

            -- Delete temp file.
            LrFileUtils.delete(path)

            return true
        else
            return false
        end
    end
end

LrTasks.startAsyncTask(function()
    LrFunctionContext.callWithContext("GenerateImageInfo", function(context)
        local catalog = LrApplication.activeCatalog()
        local selectedPhotos = catalog:getTargetPhotos()

        log:trace("Starting GenerateImageInfo")

        if #selectedPhotos == 0 then
            LrDialogs.message("Please select at least one photo.")
            return
        end

        local progressScope = LrProgressScope({
            title = "Analyzing photos with " .. prefs.ai,
            functionContext = context,
        })

        local totalPhotos = #selectedPhotos
        for i, photo in ipairs(selectedPhotos) do
            progressScope:setPortionComplete(i - 1, totalPhotos)
            progressScope:setCaption("Analyzing photo with " .. prefs.ai .. " " .. tostring(i) .. '/' .. tostring(totalPhotos))
            if not exportAndAnalyzePhoto(photo, progressScope) then
                progressScope:setCaption("Failed to analyze photo with AI " .. tostring(i))
                return false
            end
            progressScope:setPortionComplete(i, totalPhotos)
        end

        progressScope:done()
    end)
end)