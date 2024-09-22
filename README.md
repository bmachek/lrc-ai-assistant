# LRC-Gemini

A Lightroom Classic to fill image title and caption by using Google AI Gemini.

### Your photos will be sent to Google for this!
### Do not use, if you don't want this.

### Usage
* Install plugin using Lightroom addon module manager
* [Obtain Google Gemini API key from Google](https://ai.google.dev/gemini-api/docs/api-key)
* Configure language and API key in Lightroom module manager
* Go to Library in Lightroom
* Select some photos
* Go to menu -> Library -> Addon Modules -> Generate image caption and title with Google AI (Gemini)
* Wait for it to crash or fill your caption and title fields

### Notes
* Google AI has safety features, so some content is blocked. Especially:
  * Nudity
  * Dangerous scenes
  * Hatecrime
  * ...
* The plugins error handling is completely log-based for now. The log file is in Documents/LrClassicLogs/GeminiPlugin.log
* Feel free to open issues or discussions. Any feedback is welcome.

## Support my work

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/donate/?hosted_button_id=2LL4K9LN5CFA6)
