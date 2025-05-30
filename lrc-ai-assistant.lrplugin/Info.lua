Info = {}

Info.MAJOR = 3
Info.MINOR = 8
Info.REVISION = 1

Info.VERSION = { major = Info.MAJOR, minor = Info.MINOR, revision = Info.REVISION, build = 0, }


return {

	LrSdkVersion = 11.0,
	LrSdkMinimumVersion = 11.0,
	LrToolkitIdentifier = 'lrc-ai-assistant',
	LrPluginName = LOC "$$$/lrc-ai-assistant/Info/PluginName=Lightroom AI assistant",
	LrInitPlugin = "Init.lua",
	LrPluginInfoProvider = 'PluginInfo.lua',
	LrPluginInfoURL = 'https://blog.fokuspunk.de/lrc-ai-assistant/',

	VERSION = Info.VERSION,

	LrMetadataProvider = "AIMetadataProvider.lua",


	LrLibraryMenuItems = {
		{
			title = LOC "$$$/lrc-ai-assistant/Info/Title=Analyze photos with AI",
			file = "AnalyzeImageTask.lua",
		},
	},
}
