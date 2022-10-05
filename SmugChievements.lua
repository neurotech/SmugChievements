function string.startswith(String, Start)
  return string.sub(String, 1, string.len(Start)) == Start
end

local chatListener = CreateFrame("Frame")

chatListener:RegisterEvent("CHAT_MSG_GUILD")
chatListener:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")
chatListener:RegisterEvent("CHAT_MSG_SAY")

local function split_with_colon(str)
  local fields = {}
  for field in str:gmatch('([^:]+)') do
    fields[#fields + 1] = field
  end
  return fields
end

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

chatListener:SetScript("OnEvent", function(self, event, ...)
  local currentPlayer = UnitName("player")
  local message = select(1, ...)
  local sender = select(2, ...)
  local playerName = sender:gsub("%-.+", "")
  local isSelf = playerName == currentPlayer

  local isAchievementText = string.startswith(tostring(message), "has earned the achievement ") or
      string.startswith(message, "[Attune] ")

  if isAchievementText then
    if isSelf then
      print("IT'S YOU!")
    else
      local pieces = split_with_colon(message);
      local achievementID, _, _, achCompleted, completedMonth, completedDay, completedYear = GetAchievementInfo(pieces[2
        ]);

      if achCompleted then
        local delay = math.random(1, 3)

        C_Timer.After(delay, function()
          SendChatMessage('Nice. I actually completed that on ' ..
            completedDay .. ' ' .. SMUGCHIEVEMENTS_MONTHS[completedMonth] .. ' ' .. '20' .. completedYear .. '.', "GUILD")
        end)
      else
        print('NO')
      end
    end
  end
end)
