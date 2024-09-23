return {

	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 3.0,
	LrToolkitIdentifier = 'lrc-gemini',
	LrPluginName = "Google AI Gemini Plugin",
	LrInitPlugin = "Init.lua",
	LrPluginInfoProvider = 'PluginInfo.lua',
	LrPluginInfoURL = 'https://github.com/bmachek/lrc-gemini',

	VERSION = { major = 0, minor = 3, revision = 0, build = "beta", },

	LrLibraryMenuItems = {
		{
			title = "Run Google AI Gemini plugin",
			file = "GeminiImageInfo.lua",
		},
	},

}
