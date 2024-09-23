require "GeminiAPI"

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
    }

    local exportSession = LrExportSession({
        photosToExport = { photo },
        exportSettings = exportSettings
    })

    local gemini = GeminiAPI:new()
    if gemini == nil then
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
                keywordsSuccess, keywords = gemini:keywordsTask(path)
            end

            if prefs.generateCaption then
                if not util.nilOrEmpty(prefs.captionTask) then
                    captionSuccess, caption = gemini:imageTask(prefs.captionTask, path)
                else
                    util.handleError('No question for caption configured.', 'No question for caption configured.')
                end
            end
            if prefs.generateTitle then
                if not util.nilOrEmpty(prefs.titleTask) then
                    titleSuccess, title = gemini:imageTask(prefs.titleTask, path)
                else
                    util.handleError('No question for title configured.', 'No question for title configured.')
                end
            end

            if caption == 'RATE_LIMIT_EXHAUSTED' or  title == 'RATE_LIMIT_EXHAUSTED' then
                util.handleError("Rate limit exhausted 10 times in a row. Please try in 24h.", "Rate limit exhausted 10 times in a row. Please try again in 24h.")
                return false
            end

            photo.catalog:withWriteAccessDo("Save Google AI generated description", function()
                if keywordsSuccess and keywords ~= nil then
                    local catalog = LrApplication.activeCatalog()
                    local topKeyword = catalog:createKeyword('Google AI', {}, false, nil, true)
                    
                    for _, keywordName in ipairs(keywords) do
                        local keyword = catalog:createKeyword(keywordName, {}, true, topKeyword, true)
                        photo:addKeyword(keyword)
                    end


                end
                if captionSuccess then
                    photo:setRawMetadata('caption', caption)
                end
                if titleSuccess then
                    photo:setRawMetadata('title', title)
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

        log:trace("Starting GeminiImageInfo")

        if #selectedPhotos == 0 then
            LrDialogs.message("Please select at least one photo.")
            return
        end

        local progressScope = LrProgressScope({
            title = "Analyzing photos with Google AI",
            functionContext = context,
        })

        local totalPhotos = #selectedPhotos
        for i, photo in ipairs(selectedPhotos) do
            progressScope:setPortionComplete(i - 1, totalPhotos)
            progressScope:setCaption("Analyzing photo with Google AI " .. tostring(i) .. '/' .. tostring(totalPhotos))
            if not exportAndAnalyzePhoto(photo, progressScope) then
                progressScope:setCaption("Failed to analyze photo with Google AI " .. tostring(i))
                break
            end
            progressScope:setPortionComplete(i, totalPhotos)
        end

        progressScope:done()
    end)
end)