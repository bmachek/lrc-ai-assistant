---@diagnostic disable: undefined-global

-- Global imports
_G.LrHttp = import 'LrHttp'
_G.LrDate = import 'LrDate'
_G.LrPathUtils = import 'LrPathUtils'
_G.LrFileUtils = import 'LrFileUtils'
_G.LrTasks = import 'LrTasks'
_G.LrErrors = import 'LrErrors'
_G.LrDialogs = import 'LrDialogs'
_G.LrView = import 'LrView'
_G.LrBinding = import 'LrBinding'
_G.LrColor = import 'LrColor'
_G.LrFunctionContext = import 'LrFunctionContext'
_G.LrApplication = import 'LrApplication'
_G.LrPrefs = import 'LrPrefs'
_G.LrProgressScope = import 'LrProgressScope'
_G.LrExportSession = import 'LrExportSession'
_G.LrStringUtils = import 'LrStringUtils'
_G.LrLocalization = import 'LrLocalization'
_G.LrShell = import 'LrShell'
_G.LrSystemInfo = import 'LrSystemInfo'

_G.JSON = require "JSON"

_G.inspect = require 'inspect'
require "Util"
require "Defaults"
require "AiModelAPI"
require "GeminiAPI"
require "ChatGptAPI"
require "OllamaAPI"
require "ResponseStructure"
require "AnalyzeImageProvider"
require "KeywordConfigProvider"
require "PromptConfigProvider"

-- Global initializations
_G.prefs = _G.LrPrefs.prefsForPlugin()
_G.log = import 'LrLogger' ('AIPlugin')
if _G.prefs.logging == nil then
    _G.prefs.logging = false
end
if _G.prefs.logging then
    _G.log:enable('logfile')
else
    _G.log:disable()
end

if _G.prefs.apiKey == nil then _G.prefs.apiKey = '' end
if _G.prefs.url == nil then _G.prefs.url = '' end

if _G.prefs.ai == nil then
    _G.prefs.ai = Defaults.defaultAiModel
end

if _G.prefs.geminiApiKey == nil then
    _G.prefs.geminiApiKey = ""
end

if _G.prefs.chatgptApiKey == nil then
    _G.prefs.chatgptApiKey = ""
end

if _G.prefs.generateTitle == nil then
    _G.prefs.generateTitle = true
end

if _G.prefs.generateKeywords == nil then
    _G.prefs.generateKeywords = true
end

if _G.prefs.generateCaption == nil then
    _G.prefs.generateCaption = true
end

if _G.prefs.generateAltText == nil then
    _G.prefs.generateAltText = true
end

if _G.prefs.reviewAltText == nil then
    _G.prefs.reviewAltText = false
end

if _G.prefs.reviewCaption == nil then
    _G.prefs.reviewCaption = false
end

if _G.prefs.reviewTitle == nil then
    _G.prefs.reviewTitle = false
end

if _G.prefs.reviewKeywords == nil then
    _G.prefs.reviewKeywords = false
end

if _G.prefs.showCosts == nil then
    _G.prefs.showCosts = true
end

if _G.prefs.generateLanguage == nil then
    _G.prefs.generateLanguage = Defaults.defaultGenerateLanguage
end

if _G.prefs.exportSize == nil then
    _G.prefs.exportSize = Defaults.defaultExportSize
end

if _G.prefs.exportQuality == nil then
    _G.prefs.exportQuality = Defaults.defaultExportQuality
end

if _G.prefs.showPreflightDialog == nil then
    _G.prefs.showPreflightDialog = true
end

if _G.prefs.showPhotoContextDialog == nil then
    _G.prefs.showPhotoContextDialog = true
end

if _G.prefs.task == nil then
    _G.prefs.task = Defaults.defaultTask
end

if _G.prefs.systemInstruction == nil then
    _G.prefs.systemInstruction = Defaults.defaultSystemInstruction
end

if _G.prefs.submitKeywords == nil then
    _G.prefs.submitKeywords = true
end

if _G.prefs.submitGPS == nil then
    _G.prefs.submitGPS = true
end

if _G.prefs.temperature == nil then
    _G.prefs.temperature = Defaults.defaultTemperature
end

if _G.prefs.useKeywordHierarchy == nil then
    _G.prefs.useKeywordHierarchy = true
end

if _G.prefs.prompts == nil then
    _G.prefs.prompts = { Default = Defaults.defaultSystemInstruction }
end

if _G.prefs.prompt == nil then
    _G.prefs.prompt = "Default"
end

function _G.JSON.assert(b, m)
    LrDialogs.showError("Error decoding JSON response.")
end