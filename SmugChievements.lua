local chatListener = CreateFrame("Frame")

chatListener:RegisterEvent("CHAT_MSG_GUILD")

chatListener:SetScript("OnEvent", function(self, event, ...)
    local currentPlayer = UnitName("player")
    local channelName = select(9, ...)
    local message = select(1, ...)
    local sender = select(2, ...)
    local playerName = sender:gsub("%-.+", "")
    local channelIndex = select(8, ...)

    print("currentPlayer: " + currentPlayer)
    print("channelName: " + channelName)
    print("message: " + message)
    print("sender: " + sender)
    print("playerName: " + playerName)
    print("channelIndex: " + channelIndex)
end)
