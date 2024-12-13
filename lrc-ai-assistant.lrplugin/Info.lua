return {

	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 3.0,
	LrToolkitIdentifier = 'lrc-ai-assistant',
	LrPluginName = LOC "$$$/lrc-ai-assistant/Info/PluginName=Lightroom AI assistant",
	LrInitPlugin = "Init.lua",
	LrPluginInfoProvider = 'PluginInfo.lua',
	LrPluginInfoURL = 'https://github.com/bmachek/lrc-ai-assistant',

	VERSION = { major = 1, minor = 4, revision = 0, build = "", },

	LrLibraryMenuItems = {
		{
			title = LOC "$$$/lrc-ai-assistant/Info/GenerateImageInfo/Title=Analyze photos with AI",
			file = "GenerateImageInfo.lua",
		},
	},

}
