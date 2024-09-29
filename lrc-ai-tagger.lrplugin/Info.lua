return {

	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 3.0,
	LrToolkitIdentifier = 'lrc-ai-tagger',
	LrPluginName = "Generative AI image analyzernalyzer",
	LrInitPlugin = "Init.lua",
	LrPluginInfoProvider = 'PluginInfo.lua',
	LrPluginInfoURL = 'https://github.com/bmachek/lrc-ai-tagger',

	VERSION = { major = 0, minor = 6, revision = 0, build = "", },

	LrLibraryMenuItems = {
		{
			title = "Analyze photo(s) with Generative AI",
			file = "GenerateImageInfo.lua",
		},
	},

}
