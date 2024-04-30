local SMUGCHIEVEMENTS_LOG_PREFIX = '|cffffbdfe[|r|cffff7afdSmugChievements|r|cffffbdfe]|r '
local SmugChievementsMiniMapButton

local addonLoaded = CreateFrame("Frame")
addonLoaded:RegisterEvent("ADDON_LOADED")
addonLoaded:RegisterEvent("PLAYER_LOGOUT")

local function GetMiniMapIcon()
  if SmugChievementsDB["SMUGCHIEVEMENTS_ACTIVE"] then
    return "Interface\\Addons\\SmugChievements\\minimap-icon-enabled"
  else
    return "Interface\\Addons\\SmugChievements\\minimap-icon-disabled"
  end
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

local SMUGCHIEVEMENTS_MESSAGE_TEMPLATES = {
  [1] = "Nice. I actually completed that on %DD %MM %YY.",
  [2] = "Heh. Not bad, %PL. Not bad at all. I completed that achievement on %DD %MM %YY.",
  [3] = "Good work, %PL. I've already got that achievement. Got it way back in %MM %YY.",
  [4] = "grats %PL. Me? I got that achievement already on %DD %MM %YY.",
  [5] = ":smug: grats... but i achieved that on %DD %MM %YY ;)"
}

local function startswith(String, Start)
  return string.sub(String, 1, string.len(Start)) == Start
end

local SmugChievementsCooldown = 0
local SmugChievementsChatListener = CreateFrame("Frame")

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

local function ToggleSmugChievements()
  SmugChievementsMiniMapButton.icon = GetMiniMapIcon()

  if SmugChievementsDB["SMUGCHIEVEMENTS_ACTIVE"] then
    print(SMUGCHIEVEMENTS_LOG_PREFIX .. " is now listening for achievements.")

    SmugChievementsChatListener:RegisterEvent("CHAT_MSG_GUILD")
    SmugChievementsChatListener:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")

    SmugChievementsChatListener:SetScript("OnEvent", function(_, _, ...)
      local currentPlayer = UnitName("player")
      local message = select(1, ...)
      local sender = select(2, ...)
      local playerName = sender:gsub("%-.+", "")
      local isSelf = playerName == currentPlayer

      -- DEBUG:
      -- isSelf = false

      local isAchievementText = startswith(tostring(message), "has earned the achievement |cff") or
          startswith(message, "[Attune] |cff")

      if isAchievementText then
        if not isSelf then
          local pieces = split_with_colon(message);
          local _, _, _, achCompleted, completedMonth, completedDay, completedYear = GetAchievementInfo(pieces[2
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
    print(SMUGCHIEVEMENTS_LOG_PREFIX .. " is no longer listening for achievements.")
    SmugChievementsChatListener:UnregisterEvent("CHAT_MSG_GUILD")
    SmugChievementsChatListener:UnregisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")
  end
end

local function InitialiseSmugChievements()
  SmugChievementsMiniMapButton = LibStub("LibDataBroker-1.1"):NewDataObject("SmugChievements", {
    type = "data source",
    text = "SmugChievements",
    icon = GetMiniMapIcon(),
    OnClick = function()
      SmugChievementsDB["SMUGCHIEVEMENTS_ACTIVE"] = not SmugChievementsDB["SMUGCHIEVEMENTS_ACTIVE"]
      ToggleSmugChievements()
    end,
    OnTooltipShow = function(tooltip)
      if not tooltip or not tooltip.AddLine then return end
      tooltip:AddLine("Click to toggle SmugChievements")
    end,
  })

  local icon = LibStub("LibDBIcon-1.0", true)
  icon:Register("SmugChievements", SmugChievementsMiniMapButton, SmugChievementsDB)

  ToggleSmugChievements()
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
