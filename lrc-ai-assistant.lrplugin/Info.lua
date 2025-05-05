return {

	LrSdkVersion = 11.0,
	LrSdkMinimumVersion = 11.0,
	LrToolkitIdentifier = 'lrc-ai-assistant',
	LrPluginName = LOC "$$$/lrc-ai-assistant/Info/PluginName=Lightroom AI assistant",
	LrInitPlugin = "Init.lua",
	LrPluginInfoProvider = 'PluginInfo.lua',
	LrPluginInfoURL = 'https://blog.fokuspunk.de/lrc-ai-assistant/',

	VERSION = { major = 3, minor = 7, revision = 0, build = 0, },

	LrMetadataProvider = "AIMetadataProvider.lua",


	LrLibraryMenuItems = {
		{
			title = LOC "$$$/lrc-ai-assistant/Info/GenerateImageInfo/Title=Analyze photos with AI",
			file = "AnalyzeImageTask.lua",
		},
	},
}
