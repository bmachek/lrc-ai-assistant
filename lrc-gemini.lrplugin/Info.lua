return {

	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 3.0,
	LrToolkitIdentifier = 'lrc-ai-tagger',
	LrPluginName = "Generative AI image Analyzer",
	LrInitPlugin = "Init.lua",
	LrPluginInfoProvider = 'PluginInfo.lua',
	LrPluginInfoURL = 'https://github.com/bmachek/lrc-ai-tagger',

	VERSION = { major = 0, minor = 3, revision = 0, build = "beta", },

	LrLibraryMenuItems = {
		{
			title = "Analyze photo(s) with Generative AI",
			file = "GenerateImageInfo.lua",
		},
	},

}
