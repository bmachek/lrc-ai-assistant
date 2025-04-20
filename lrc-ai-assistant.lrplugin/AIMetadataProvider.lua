
return {
    metadataFieldsForPhotos = {
        {
            id = 'aiLastRun',
            title = LOC "$$$/lrc-ai-assistant/AIMetadataProvider/aiLastRun=Last AI run",
            dataType = 'string',
            readOnly = true,
            searchable = true,
            browsable = true,
        },
        {
            id = 'aiModel',
            title = LOC "$$$/lrc-ai-assistant/AIMetadataProvider/aiModel=AI model",
            dataType = 'string',
            readOnly = true,
            searchable = true,
            browsable = true,
        },
        {
            id = 'photoContext',
            title = LOC "$$$/lrc-ai-assistant/AIMetadataProvider/photoContext=Photo context",
            dataType = 'string',
            readOnly = false,
            searchable = true,
            browsable = true,
        },
    },

    schemaVersion = 1,
    --updateFromEarlierSchemaVersion = function (catalog, previousSchemaVersion, progressScope)
            -- When the plug-in is first installed, previousSchemaVersion is nil.
            -- As of Lightroom version 3.0, a progress-scope variable is available; you can
            -- use it to signal progress for your upgrader function.
            -- Note: This function is called from within a catalog:withPrivateWriteAccessDo
            -- block. You should not call any of the with___Do functions yourself.
            -- catalog:assertHasPrivateWriteAccess("AIMetadataProvider.updateFromEarlierSchemaVersion")
            -- local myPluginId = 'lrc-ai-assistant'
            -- if previousSchemaVersion == 1 then
            --     local photosToMigrate = catalog:findPhotosWithProperty( myPluginId,'siteId')
            --     -- optional: can add property version number here
            --     for i, photo in ipairs( photosToMigrate ) do
            --         local oldSiteId = photo:getPropertyForPlugin( myPluginId, 'siteId' )
            --         -- add property version here if used above
            --         local newSiteId = "new:" .. oldSiteId
            --         -- replace this with whatever data transformation you need to do
            --         photo:setPropertyForPlugin( _PLUGIN, 'siteId', newSiteId )
            --     end
            -- elseif previousSchemaVersion == 2 then
            -- end
        --end,
}