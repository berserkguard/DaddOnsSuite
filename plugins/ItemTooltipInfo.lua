-- Adds additional information to the item tooltip

local ItemInfoTooltip = {}

--|--------------------------------|--
--|   ItemInfoTooltip Public API   |--
--|--------------------------------|--

function ItemInfoTooltip:AddItemId()
    itemName,itemLink = GameTooltip:GetItem()
    if itemLink ~= nil then
        local itemString = string.match(itemLink, "item[%-?%d:]+")
        local _, itemId, enchantId, jewelId1, jewelId2, jewelId3, 
        jewelId4, suffixId, uniqueId, linkLevel, reforgeId = strsplit(":", itemString)

        GameTooltip:AddLine("ItemID: |cFFFFFFFF"..itemId)
        GameTooltip:Show();
    end
end

--|----------------------------|--
--|   Game Hook Registration   |--
--|----------------------------|--

hooksecurefunc(GameTooltip, "SetBagItem",
    function(tip, bag, slot)
        if IsShiftKeyDown() then
            ItemInfoTooltip:AddItemId()
        end
    end
);

--|-------------------------|--
--|   Plugin Registration   |--
--|-------------------------|--

Daddy:RegisterPlugin("ItemInfoTooltip", ItemInfoTooltip)
