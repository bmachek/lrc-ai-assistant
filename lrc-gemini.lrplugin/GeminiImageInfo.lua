require "GeminiAPI"

local function exportAndAnalyzePhoto(photo, progressScope)
    progressScope:setCaption("Preparing photo...")
    local tempDir = LrPathUtils.getStandardFilePath('temp')
    local photoName = LrPathUtils.leafName(photo:getFormattedMetadata('fileName'))
    local filePath = LrPathUtils.child(tempDir, photoName)

    if LrFileUtils.exists(filePath) then
        return nil
    end

    local exportSettings = {
        LR_export_destinationType = 'specificFolder',
        LR_export_destinationPathPrefix = tempDir,
        LR_export_useSubfolder = false,
        LR_format = 'JPEG',
        LR_jpeg_quality = 0.8,
        LR_minimizeEmbeddedMetadata = true,
        LR_outputSharpeningOn = false,
        LR_size_doConstrain = true,
        LR_size_maxHeight = 2000,
        LR_size_maxWidth = 2000,
        LR_size_resizeType = 'wh',
        LR_size_units = 'pixels',
    }

    local exportSession = LrExportSession({
        photosToExport = {photo},
        exportSettings = exportSettings
    })

    local gemini = GeminiAPI:new()
    for _, rendition in exportSession:renditions() do
        local success, path = rendition:waitForRender()
        if success then
            -- log:trace(path)
            local captionSuccess, caption = gemini:imageTask("Generate image caption in German", path)
            local titleSuccess, title = gemini:imageTask("Generate image title in German", path)
            photo.catalog:withWriteAccessDo("Set Alt Text", function()
                if captionSuccess then
                    photo:setRawMetadata('caption', caption)
                end
                if titleSuccess then
                    photo:setRawMetadata('title', title)
                end
            end)

            -- Delete temp file.
            LrFileUtils.delete(path)
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
            title = "Analyzing photo with Google AI",
            functionContext = context,
        })

        local totalPhotos = #selectedPhotos
        for i, photo in ipairs(selectedPhotos) do
            progressScope:setPortionComplete(i - 1, totalPhotos)
            exportAndAnalyzePhoto(photo, progressScope)
            progressScope:setPortionComplete(i, totalPhotos)
            LrTasks.sleep(1)
        end

        progressScope:done()
    end)
end)