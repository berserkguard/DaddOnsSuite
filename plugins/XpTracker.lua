-- Simple XP tracking functionality

local XpTracker = {
}

--|-----------------------------|--
--|   Blizzard Event Handlers   |--
--|-----------------------------|--

function XpTracker:PLAYER_LEVEL_UP(newLvl)
    LogMessageDelayed("Daddy congratulates you on your new level! Feel his warmth inside you!")
end

function XpTracker:TIME_PLAYED_MSG(totalMins, levelSecs)
    if levelSecs == 0 then
        levelSecs = 1
    end

    local levelXp = UnitXP("player")
    local levelXpPerHour = floor(levelXp / (levelSecs / 3600))

    local msg = "That's about " .. tostring(levelXpPerHour) .. " XP/hour!"

    local xpToLevel = UnitXPMax("player") - levelXp
    if levelXpPerHour > 0 then
        local secsToLevel = (xpToLevel / levelXpPerHour) * 3600
        msg = msg .. " And " .. SecondsToTime(secsToLevel) .. " to next level!"
    end

    LogMessageDelayed(msg)
end

--|--------------------------|--
--|   XpTracker Public API   |--
--|--------------------------|--

function XpTracker:OnInitialize()
    self.xpGained = 0
    self.startTime = 0
    self.curTime = 0

    self.startXp = UnitXP("player")
    self.maxXp = UnitXPMax("player")
end

function XpTracker:OnEnabled()
    Daddy.frame:RegisterEvent("PLAYER_LEVEL_UP")
    Daddy.frame:RegisterEvent("TIME_PLAYED_MSG")
end

function XpTracker:OnDisabled()
    Daddy.frame:UnregisterEvent("PLAYER_LEVEL_UP")
    Daddy.frame:UnregisterEvent("TIME_PLAYED_MSG")
end

-- TODO elapsed should really be delta...
function XpTracker:OnUpdate(elapsed)
    if self.startTime == 0 then
        self.startTime = elapsed
    end
    self.curTime = elapsed
end

function XpTracker:ResetTracking()
    LogMessage("Reset XP tracking.")

    self.xpGained = 0
    self.startTime = 0

    self.startXp = UnitXP("player")
    self.maxXp = UnitXPMax("player")
end

function XpTracker:GetInfo()
    local seconds = floor(self.curTime - self.startTime)
    local xpGained = UnitXP("player") - self.startXp
    local xpPerHour = xpGained / (seconds / 3600)


    LogMessage("Gained " .. tostring(xpGained) .. " XP over the past " .. SecondsToTime(seconds))
    LogMessage("That's about " .. floor(xpPerHour) .. " XP/hour!")
end

--|-------------------------|--
--|   Plugin Registration   |--
--|-------------------------|--

Daddy:RegisterPlugin("XpTracker", XpTracker)
Daddy:RegisterSubcommand("xpreset", function(input) XpTracker:ResetTracking() end, "Resets the XP tracking session.")
Daddy:RegisterSubcommand("xpinfo", function(input) XpTracker:GetInfo() end, "Displays the XP tracking info for the current session.")
