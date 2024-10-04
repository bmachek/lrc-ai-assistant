ChatGptAPI = {}
ChatGptAPI.baseUrl = 'https://api.openai.com/v1/chat/completions'
ChatGptAPI.__index = ChatGptAPI

function ChatGptAPI:new()
    local o = setmetatable({}, ChatGptAPI)
    self.rateLimitHit = 0

    if Util.nilOrEmpty(prefs.chatgptApiKey) then
        Util.handleError('ChatGPT API key not configured.', "$$$/lrc-ai-assistant/ChatGptAPI/NoAPIkey=No ChatGPT API key configured in Add-Ons manager.")
        return nil
    else
        self.apiKey = prefs.chatgptApiKey
    end

    self.url = ChatGptAPI.baseUrl
    self.generateLanguage = prefs.generateLanguage
    if Util.nilOrEmpty(self.generateLanguage) then
        self.generateLanguage = 'English'
    end

    return o
end

function ChatGptAPI:imageTask(task, filePath)
    local body = {
        model = "gpt-4o",
        response_format = {
            type = "text"
        },
        messages = {
            {
                role = "system",
                content = task .. ' in ' .. self.generateLanguage
            },
            {
                role = "user",
                content = {
                    {
                        type = "image_url",
                        image_url = {
                            url = "data:image/jpeg;base64," .. Util.encodePhotoToBase64(filePath)
                        }
                    }
                }
            }
        }
    }

    local response, headers = LrHttp.post(self.url, JSON:encode(body), {{ field = 'Content-Type', value = 'application/json' },  { field = 'Authorization', value = 'Bearer ' .. self.apiKey }})

    if headers.status == 200 then
        self.rateLimitHit = 0
        if response ~= nil then
            log:trace(response)
            local decoded = JSON:decode(response)
            if decoded ~= nil then
                if decoded.choices[1].finish_reason == 'stop' then
                    local text = decoded.choices[1].message.content
                    log:trace(text)
                    return true, text
                else
                    log:error('Blocked: ' .. decoded.choices[1].finish_reason .. Util.dumpTable(decoded.choices[1]))
                    return false,  decoded.choices[1].finish_reason
                end
            end
        else
            log:error('Got empty response from ChatGPT')
        end
    -- elseif headers.status == 429 then
    --     log:error('Rate limit exceeded for ' .. tostring(self.rateLimitHit) .. ' times')
    --     LrTasks.sleep(5)
    --     self.rateLimitHit = self.rateLimitHit + 1
    --     if self.rateLimitHit >= 10 then
    --         log:error('Rate Limit hit 10 times, giving up')
    --         return false, 'RATE_LIMIT_EXHAUSTED'
    --     end
    --     self:imageTask(task, filePath)
    else
        log:error('ChatGptAPI POST request failed. ' .. self.url)
        log:error(Util.dumpTable(headers))
        log:error(response)
        return false, nil
    end
end


function ChatGptAPI:keywordsTask(filePath)
    local success, keywordsString = self:imageTask(Defaults.defaultKeywordsTask, filePath)
    if success then
        return success, Util.string_split(keywordsString, ',')
    end
    return false, keywordsString
end
