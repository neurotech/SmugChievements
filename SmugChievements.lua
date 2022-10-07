local SMUGCHIEVEMENTS_LOG_PREFIX = '|cffffbdfe[|r|cffff7afdSmugChievements|r|cffffbdfe]|r '

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
  [1] = "Nice. I actually completed that on %DD %MM 20%YY.",
  [2] = "Heh. Not bad., %PL. Not bad at all. I completed that achievement on %DD %MM 20%YY.",
  [3] = "Good work, %PL. I've already got that achievement. Got it way back in %MM 20%YY.",
  [4] = "grats %PL. Me? I got that achievement already on %DD %%MM 20%YY."
}

function string.startswith(String, Start)
  return string.sub(String, 1, string.len(Start)) == Start
end

local SmugChievementsCooldown = 0
local SmugChievementsChatListener = CreateFrame("Frame")

SmugChievementsChatListener:RegisterEvent("CHAT_MSG_GUILD")
SmugChievementsChatListener:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")
SmugChievementsChatListener:RegisterEvent("CHAT_MSG_SAY")

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
  chatMessage = chatMessage:gsub("%%YY", completedYear)

  return chatMessage
end

SmugChievementsChatListener:SetScript("OnEvent", function(self, event, ...)
  local currentPlayer = UnitName("player")
  local message = select(1, ...)
  local sender = select(2, ...)
  local playerName = sender:gsub("%-.+", "")
  local isSelf = playerName == currentPlayer

  -- DEBUG:
  -- isSelf = false

  local isAchievementText = string.startswith(tostring(message), "has earned the achievement ") or
      string.startswith(message, "[Attune] |cf")

  if isAchievementText then
    if not isSelf then
      local pieces = split_with_colon(message);
      local _, achName, _, achCompleted, completedMonth, completedDay, completedYear = GetAchievementInfo(pieces[2
        ]);

      if SmugChievementsCooldown == 0 then
        if achCompleted then
          local delay = math.random(1, 3)

          C_Timer.After(delay, function()
            SendChatMessage(GetChatMessage(playerName, SMUGCHIEVEMENTS_MONTHS[completedMonth], completedDay,
              completedYear)
              , "GUILD")

          end)

          SmugChievementsCooldown = 5
          C_Timer.After(SmugChievementsCooldown, function()
            SmugChievementsCooldown = 0
          end)
        else
          print(SMUGCHIEVEMENTS_LOG_PREFIX ..
            'Not replying to ' .. playerName .. ' as you have not yet completed the achievement \"' .. achName .. '\".')
          SmugChievementsCooldown = 5
          C_Timer.After(SmugChievementsCooldown, function()
            SmugChievementsCooldown = 0
          end)
        end
      else
        print(SMUGCHIEVEMENTS_LOG_PREFIX .. "Cooldown active. Please wait " .. SmugChievementsCooldown .. " second(s).")

        C_Timer.After(SmugChievementsCooldown, function()
          SmugChievementsCooldown = 0
        end)
      end
    end
  end
end)
