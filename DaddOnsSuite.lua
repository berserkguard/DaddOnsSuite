Daddy = LibStub("AceAddon-3.0"):NewAddon("Daddy", "AceConsole-3.0")

--|------------------------|--
--|   Addon Registration   |--
--|------------------------|--

if not Daddy then
    return -- Already loaded and no upgrade necessary
end

Daddy.plugins = {}
Daddy.subcommands = {}
Daddy.queuedMessages = {}

--|---------------------|--
--|   Local Constants   |--
--|---------------------|--

local COL_WHITE = '|cffffffff'
local COL_RED   = '|cffff0000'
local COL_CYAN  = '|cff00ffff'

local UPDATE_RATE = 1.0 / 30.0 -- In seconds

local ADDON_NAME = "|cffff0000D|cffff7f00a|cffffff00d|cff00ff00d|cff00ffffO|cff0000ffn|cff8b00ffs" .. COL_WHITE
--local ADDON_NAME = COL_RED .. "DaddOns" .. COL_WHITE

--|--------------------|--
--|   Global Helpers   |--
--|--------------------|--

function LogError(msg)
    message("DaddOns - Error: " .. msg)
end

function LogMessage(msg)
    print(ADDON_NAME .. " - " .. msg)
end

function LogMessageDelayed(msg)
    table.insert(Daddy.queuedMessages, msg)
end

--|-------------------|--
--|   Local Helpers   |--
--|-------------------|--

local function InvokeOnPlugins(funcname, ...)
    for name, obj in pairs(Daddy.plugins) do
        local enabled = obj.enabled or true
        if enabled and obj[funcname] ~= nil then
            obj[funcname](obj, ...)
        end
    end
end

--|-----------------------|--
--|   Built-in Commands   |--
--|-----------------------|--

local function DoPlugins(input)
    local str = ""

    local first = true
    for name, _ in pairs(Daddy.plugins) do
        if not first then
            str = str .. ", "
        end
        str = str .. COL_CYAN .. name .. COL_WHITE
        first = false
    end
    
    LogMessage("Loaded Plugins: " .. str)
end

local function DoHelp(input)
    LogMessage("Help for " .. COL_CYAN .. "/daddy <cmd>" .. COL_WHITE .. ", where " .. COL_CYAN .. "<cmd>" .. COL_WHITE .. " is one of:")
    for cmd, subcmd in pairs(Daddy.subcommands) do
        print("    " .. COL_CYAN .. cmd .. COL_WHITE .. " - " .. subcmd[2])
    end
end

--|--------------------------|--
--|   Lifecycle Management   |--
--|--------------------------|--

-- Called automatically by AceAddon.
function Daddy:OnInitialize()
    self:RegisterChatCommand("daddy", "HandleChatCommand")

    self:RegisterSubcommand("plugins", DoPlugins, "Returns a list of loaded plugins")
    self:RegisterSubcommand("help", DoHelp, "Prints a listing of available subcommands")

    local frame = CreateFrame("Frame", "DaddOnsFrame")
    self.frame = frame
    self.runningTime = 0
    self.fixedTime = 0

    frame:SetScript("OnUpdate", function(_, elapsed) self:OnUpdate(elapsed) end)
    frame:SetScript("OnEvent", function(_, event, ...)
        --LogMessage("Event: " .. event)
        InvokeOnPlugins(event, ...)
    end)
    --frame:Hide()

    -- OnInitialize() is called on plugins first, regardless of whether they're enabled or not
    InvokeOnPlugins("OnInitialize")

    -- TODO read settings to only enable ones that were previously enabled
    -- Until then, assume all plugins are enabled
    for name, _ in pairs(Daddy.plugins) do
        self:EnablePlugin(name)
    end

    LogMessage("Initialized!")
end

-- Called automatically by AceAddon.
function Daddy:OnEnable()
    --LogMessage("Enabled!")
end

-- Called automatically by AceAddon.
function Daddy:OnDisable()
    --LogMessage("Disabled!")
end

-- Called by our DaddOnsFrame's OnUpdate script, once per frame
function Daddy:OnUpdate(elapsed)
    self.runningTime = self.runningTime + elapsed
    self.fixedTime = self.fixedTime + elapsed
    
    local propagate = false
    
    -- Clamp addon updates to once every UPDATE_RATE seconds
    while self.fixedTime >= UPDATE_RATE do
        propagate = true
        self.fixedTime = self.fixedTime - UPDATE_RATE
    end
    
    if propagate then
        InvokeOnPlugins("OnUpdate", self.runningTime)
    end

    if #self.queuedMessages > 0 then
        for _, msg in pairs(self.queuedMessages) do
            LogMessage(msg)
        end
        self.queuedMessages = {}
    end
end

--|-----------------------|--
--|   Plugin Management   |--
--|-----------------------|--

function Daddy:RegisterPlugin(name, data)
    if self.plugins[name] ~= nil then
        LogError("Plugin with name " .. COL_CYAN .. name .. COL_WHITE .. " already registered!")
        return
    end

    self.plugins[name] = data

    LogMessage("Plugin registered: " .. COL_CYAN .. name)
end

function Daddy:EnablePlugin(name)
    local plugin = self:GetPlugin(name)
    local enabled = plugin.enabled or false
    
    if not enabled then
        plugin.enabled = true
        if plugin.OnEnabled ~= nil then
            plugin.OnEnabled()
        end
        LogMessage("Plugin enabled: " .. COL_CYAN .. name)
    end
end

function Daddy:DisablePlugin(name)
    local plugin = self:GetPlugin(name)
    local enabled = plugin.enabled or true
    
    if enabled then
        plugin.enabled = false
        if plugin.OnDisabled ~= nil then
            plugin.OnDisabled()
        end
        LogMessage("Plugin disabled: " .. COL_CYAN .. name)
    end
end

function Daddy:GetPlugin(name)
    if self.plugins[name] == nil then
        LogError("No plugin with name " .. COL_CYAN .. name .. COL_WHITE .. " registered!")
    end
    return self.plugins[name]
end

--|-------------------|--
--|   Chat Commands   |--
--|-------------------|--

function Daddy:HandleChatCommand(input)
    input = string.trim(input, " ");

    for cmd, subcmd in pairs(self.subcommands) do
        if input == cmd or Strings:StartsWith(input, cmd .. " ") then
            local func = subcmd[1]

            func(string.trim(input:sub(1, #cmd)))
            return
        end
    end

    LogMessage("Unknown subcommand: " .. input)
    print("   Type " .. COL_CYAN .. "/daddy help" .. COL_WHITE .. " for a listing")
end

function Daddy:RegisterSubcommand(command, func, help)
    if self.subcommands[command] ~= nil then
        LogError("Subcommand " .. COL_CYAN .. command .. COL_WHITE .. " was already registered!")
    end

    self.subcommands[command] = {func, help}
end
