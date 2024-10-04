return {

	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 3.0,
	LrToolkitIdentifier = 'lrc-ai-tagger',
	LrPluginName = LOC "$$$/lrc-ai-tagger/Info/PluginName=Lightroom AI assistant",
	LrInitPlugin = "Init.lua",
	LrPluginInfoProvider = 'PluginInfo.lua',
	LrPluginInfoURL = 'https://github.com/bmachek/lrc-ai-tagger',

	VERSION = { major = 0, minor = 7, revision = 0, build = "", },

	LrLibraryMenuItems = {
		{
			title = LOC("$$$/lrc-ai-tagger/Info/GenerateImageInfo/Title=Analyze photos with AI (^1)", prefs.ai),
			file = "GenerateImageInfo.lua",
		},
	},

}
