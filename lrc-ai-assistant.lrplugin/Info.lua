return {

	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 3.0,
	LrToolkitIdentifier = 'lrc-ai-assistant',
	LrPluginName = LOC "$$$/lrc-ai-assistant/Info/PluginName=Lightroom AI assistant",
	LrInitPlugin = "Init.lua",
	LrPluginInfoProvider = 'PluginInfo.lua',
	LrPluginInfoURL = 'https://github.com/bmachek/lrc-ai-assistant',

	VERSION = { major = 3, minor = 1, revision = 0, build = 0, },

	LrLibraryMenuItems = {
		{
			title = LOC "$$$/lrc-ai-assistant/Info/GenerateImageInfo/Title=Analyze photos with AI",
			file = "GenerateImageInfo.lua",
		},
		{
			title = "Edit Keyword Categories",
			file = "KeywordConfigurator.lua",
		},
        {
            title = "Show Tree",
            file = "TreeWidget.lua",
        },
	},

}
