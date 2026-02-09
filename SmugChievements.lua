local SMUGCHIEVEMENTS_LOG_PREFIX = '|cffffbdfe[|r|cffff7afdSmugChievements|r|cffffbdfe]|r '

local addonLoaded = CreateFrame("Frame")
addonLoaded:RegisterEvent("ADDON_LOADED")
addonLoaded:RegisterEvent("PLAYER_LOGOUT")

local SMUGCHIEVEMENTS_MONTHS = {
    [1] = "January",
    [2] = "February",
    [3] = "March",
    [4] = "April",
    [5] = "May",
    [6] = "June",
    [7] = "July",
    [8] = "August",
    [9] = "September",
    [10] = "October",
    [11] = "November",
    [12] = "December"
}

local SMUGCHIEVEMENTS_MESSAGE_TEMPLATES = {
    [1] = "Nice. I actually completed that on %DD %MM %YY.",
    [2] = "Heh. Not bad, %PL. Not bad at all. I completed that achievement on %DD %MM %YY.",
    [3] = "Good work, %PL. I've already got that achievement. Got it way back in %MM %YY.",
    [4] = "grats %PL. Me? I got that achievement already on %DD %MM %YY.",
    [5] = "grats... but i achieved that on %DD %MM %YY ;)"
}

local SmugChievementsCooldown = 0
local SmugChievementsChatListener = CreateFrame("Frame")

local function startswith(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

local function split_with_colon(str)
    local fields = {}
    for field in str:gmatch('([^:]+)') do
        fields[#fields + 1] = field
    end
    return fields
end

local function GetChatMessage(playerName, completedMonth, completedDay, completedYear)
    local randIndex = math.random(1, #SMUGCHIEVEMENTS_MESSAGE_TEMPLATES)
    local template = SMUGCHIEVEMENTS_MESSAGE_TEMPLATES[randIndex]
    local chatMessage = template

    chatMessage = chatMessage:gsub("%%PL", playerName)
    chatMessage = chatMessage:gsub("%%DD", completedDay)
    chatMessage = chatMessage:gsub("%%MM", completedMonth)
    chatMessage = chatMessage:gsub("%%YY", completedYear + 2000)

    return chatMessage
end

local function ResetCooldown()
    C_Timer.After(SmugChievementsCooldown, function()
        SmugChievementsCooldown = 0
    end)
end

local function InitialiseSmugChievements()
    if SmugChievementsDB["SMUGCHIEVEMENTS_ACTIVE"] then
        print(SMUGCHIEVEMENTS_LOG_PREFIX .. "is ON.")

        SmugChievementsChatListener:RegisterEvent("CHAT_MSG_ACHIEVEMENT")

        SmugChievementsChatListener:SetScript("OnEvent", function(_, _, ...)
            local currentPlayer = UnitName("player")
            local message = select(1, ...)
            local sender = select(2, ...)
            local playerName = sender:gsub("%-.+", "")
            local isSelf = playerName == currentPlayer

            -- DEBUG:
            -- isSelf = false

            local isAchievementText = startswith(tostring(message), "has earned the achievement |cff") or
                startswith(message, "[Attune] |cff") or
                startswith(tostring(message), "%s has earned the achievement |cff")

            if isAchievementText then
                if not isSelf then
                    local pieces = split_with_colon(message);
                    local _, _, _, completed, month, day, year = GetAchievementInfo(pieces[2]);

                    if SmugChievementsCooldown == 0 then
                        if completed then
                            local delay = math.random(1, 3)

                            C_Timer.After(delay, function()
                                local message = GetChatMessage(playerName, SMUGCHIEVEMENTS_MONTHS[month], day, year)
                                SendChatMessage(message, "WHISPER", nil, playerName)
                            end)

                            SmugChievementsCooldown = 5
                            ResetCooldown()
                        else
                            SmugChievementsCooldown = 5
                            ResetCooldown()
                        end
                    else
                        ResetCooldown()
                    end
                end
            end
        end)
    else
        print(SMUGCHIEVEMENTS_LOG_PREFIX .. "is OFF.")
        SmugChievementsChatListener:UnregisterEvent("CHAT_MSG_ACHIEVEMENT")
    end
end

local function ToggleSmugChievements()
    SmugChievementsDB["SMUGCHIEVEMENTS_ACTIVE"] = not SmugChievementsDB["SMUGCHIEVEMENTS_ACTIVE"]
    InitialiseSmugChievements()
end

addonLoaded:SetScript(
    "OnEvent",
    function(_, event, arg1)
        if event == "ADDON_LOADED" and arg1 == "SmugChievements" then
            if SmugChievementsDB == nil then
                -- Seed preferences with defaults
                SmugChievementsDB = {}
                SmugChievementsDB["SMUGCHIEVEMENTS_ACTIVE"] = false
            end

            InitialiseSmugChievements()

            addonLoaded:UnregisterEvent("ADDON_LOADED")
        elseif event == "PLAYER_LOGOUT" then
            -- --
        end
    end
)

SLASH_SMUG1 = "/smug"
SlashCmdList.SMUG = function()
    ToggleSmugChievements()
end
