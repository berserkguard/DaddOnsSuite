Daddy = LibStub("AceAddon-3.0"):NewAddon("Daddy", "AceConsole-3.0")

--|------------------------|--
--|   Addon Registration   |--
--|------------------------|--

if not Daddy then
    return -- Already loaded and no upgrade necessary
end

Daddy.plugins = {}
Daddy.subcommands = {}

--|---------------------|--
--|   Local Constants   |--
--|---------------------|--

local COL_WHITE = '|cffffffff'
local COL_RED   = '|cffff0000'
local COL_CYAN  = '|cff00ffff'

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
    Daddy:RegisterChatCommand("daddy", "HandleChatCommand")

    Daddy:RegisterSubcommand("plugins", DoPlugins, "Returns a list of loaded plugins")
    Daddy:RegisterSubcommand("help", DoHelp, "Prints a listing of available subcommands")

    LogMessage("Initialized!")
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

    Daddy:EnablePlugin(name)
end

function Daddy:EnablePlugin(name)
    local plugin = Daddy:GetPlugin(name)
    local enabled = plugin.enabled or true
    
    if not enabled then
        plugin.enabled = true
        if plugin.OnEnabled ~= nil then
            plugin.OnEnabled()
        end
        LogMessage("Plugin enabled: " .. COL_CYAN .. name)
    end
end

function Daddy:DisablePlugin(name)
    local plugin = Daddy:GetPlugin(name)
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
        LogError("No plugin with name " .. COL_CYAN .. name .. COL_WHITE .. "' registered!")
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
    self.subcommands[command] = {func, help}
end
