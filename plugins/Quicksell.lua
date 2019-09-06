-- Command to vendor trash at a vendor window

local Quicksell = {}

--|--------------------------|--
--|   Quicksell Public API   |--
--|--------------------------|--

function Quicksell:VendorTrash(input)
    local c, i, n, v = 0
    
    for b = 0, 4 do
        for s = 1, GetContainerNumSlots(b) do
            i = {GetContainerItemInfo(b,s)}
            n = i[7]
            
            if n and string.find(n, "9d9d9d") then
                v = {GetItemInfo(n)}
                q = i[2]
                c = c + v[11] * q
                
                UseContainerItem(b, s)
                print(n, q)
            end
        end
    end
    LogMessage("Trash vendored. Total: " .. GetCoinText(c))
end

--|-------------------------|--
--|   Plugin Registration   |--
--|-------------------------|--

Daddy:RegisterPlugin("Quicksell", Quicksell)
Daddy:RegisterSubcommand("vendor", Quicksell.VendorTrash, "Vendors all trash (grays) if a vendor window is open")
