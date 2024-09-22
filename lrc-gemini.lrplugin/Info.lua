return {

	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 3.0,
	LrToolkitIdentifier = 'lrc-gemini',
	LrPluginName = "Google Gemini Tagger",
	LrInitPlugin = "Init.lua",
	LrPluginInfoProvider = 'PluginInfo.lua',
	LrPluginInfoURL = 'https://github.com/bmachek/lrc-gemini',

	VERSION = { major = 0, minor = 2, revision = 0, build = "beta", },

	LrLibraryMenuItems = {
		{
			title = "Generate image caption and title with Google AI (Gemini)",
			file = "GeminiImageInfo.lua",
		},
	},

}
