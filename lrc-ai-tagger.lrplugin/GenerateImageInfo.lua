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

local function addKeywordRecursively(photo, keywordSubTable, parent)
    for key, value in pairs(keywordSubTable) do
        local keyword
        if type(key) == 'string' then
            photo.catalog:withWriteAccessDo("Create and add level keyword", function()
                log:trace('Creating keyword: ' .. key)
                keyword = photo.catalog:createKeyword(key, {}, false, parent, true)
                photo:addKeyword(keyword)
            end)
        elseif type(key) == 'number' then
            photo.catalog:withWriteAccessDo("Create and add keyword", function()
                log:trace('Creating keyword: ' .. value)
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
        LR_size_maxHeight = 1600,
        LR_size_resizeType = 'longEdge',
        LR_size_units = 'pixels',
        LR_collisionHandling = 'rename',
        LR_includeVideoFiles = false,
        LR_removeLocationMetadata = false,
        LR_embeddedMetadataOption = "all",
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
                if not Util.nilOrEmpty(prefs.captionTask) then
                    captionSuccess, caption = ai:imageTask(prefs.captionTask, path)
                else
                    Util.handleError('No question for caption configured.', 'No question for caption configured.')
                end
            end
            if prefs.generateTitle then
                if not Util.nilOrEmpty(prefs.titleTask) then
                    titleSuccess, title = ai:imageTask(prefs.titleTask, path)
                else
                    Util.handleError('No question for title configured.', 'No question for title configured.')
                end
            end

            if caption == 'RATE_LIMIT_EXHAUSTED' or title == 'RATE_LIMIT_EXHAUSTED' or keywords == 'RATE_LIMIT_EXHAUSTED' then
                LrDialogs.showError("Rate limit exhausted 10 times in a row. Please try again in 24h")
                return false
            end

            photo.catalog:withWriteAccessDo("Save AI generated title and caption", function()
                if captionSuccess then
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
                    if saveCaption then
                        photo:setRawMetadata('caption', caption)
                    end
                end

                if titleSuccess then
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

                    if saveTitle then
                        photo:setRawMetadata('title', title)
                    end
                end
            end)

            if keywordsSuccess and type(keywords) == 'table' then
                local topKeyword
                photo.catalog:withWriteAccessDo("Create and add top-level keyword", function()
                    topKeyword = photo.catalog:createKeyword(ai.topKeyword, {}, false, nil, true)
                    photo:addKeyword(topKeyword)
                end)
                addKeywordRecursively(photo, keywords, topKeyword)
            end

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
            if progressScope:isCanceled() then
                log:trace("We got canceled.")
                return false
            end
        end

        progressScope:done()
    end)
end)