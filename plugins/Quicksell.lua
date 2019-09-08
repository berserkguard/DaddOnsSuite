-- Command to vendor trash at a vendor window

local Quicksell = {}

--|--------------------------|--
--|   Quicksell Public API   |--
--|--------------------------|--

-- If 'commit' is true, attempts to sell all grays to the already-open vendor window.
-- If 'commit' is false, then only a preview of grays and total worth is dumped to chat window.
function Quicksell:VendorTrash(commit)
    local totalWorth = 0

    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local containerInfo = {GetContainerItemInfo(bag, slot)}
            local itemLink = containerInfo[7]

            -- If the item link contains the hex for the gray color, it's trash
            if itemLink and string.find(itemLink, "9d9d9d") then
                local sellPrice = select(11, GetItemInfo(itemLink))
                local stackCount = containerInfo[2]
                local stackWorth = sellPrice * stackCount

                totalWorth = totalWorth + stackWorth

                if commit then
                    UseContainerItem(bag, slot)
                end
                print(tostring(stackCount) .. "x" .. itemLink .. ": " .. GetCoinText(stackWorth))
            end
        end
    end

    if commit then
        LogMessage("Trash vendored. Total: " .. GetCoinText(totalWorth))
    else
        LogMessage("Total trash worth: " .. GetCoinText(totalWorth))
    end
end

--|-------------------------|--
--|   Plugin Registration   |--
--|-------------------------|--

Daddy:RegisterPlugin("Quicksell", Quicksell)
Daddy:RegisterSubcommand("vendor", function(input) Quicksell:VendorTrash(true) end, "Vendors all trash (grays) if a vendor window is open")
Daddy:RegisterSubcommand("trashworth", function(input) Quicksell:VendorTrash(false) end, "Evaluates the total worth of trash in bags")
