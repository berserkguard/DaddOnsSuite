-- Sorts bags!

local BagSorter = {}

--|-------------------|--
--|   Local Helpers   |--
--|-------------------|--

local function ToSortMap(inlist)
    local built = {}
    
    for k,v in ipairs(inlist) do
        built[v] = k
    end
    
    return built
end

local function ExtractItemId(itemLink)
    local itemString = string.match(itemLink, "item[%-?%d:]+")
    local itemId = string.match(itemString, "item:(%d+):")
    
    return tonumber(itemId)
end

--|---------------------|--
--|   Local Constants   |--
--|---------------------|--

-- TODO make this customizable via in-game addon config window
local FAVORITES_SORTING = ToSortMap({
    6948,  -- Hearthstone

    -- Fishing Poles --
    6256,  -- Fishing Pole
    12225, -- Blump Family Fishing Pole
    6365,  -- Strong Fishing Pole
    6366,  -- Darkwood Fishing Pole
    6367,  -- Big Iron Fishing Pole
    19970, -- Arcanite Fishing Pole

    -- Pickaxes & Hammers --
    2901,  -- Mining Pick
    778,   -- Kobold Excavation Pick
    1959,  -- Cold Iron Pick
    756,   -- Tunnel Pick
    20723, -- Brann's Trusty Pick
    5956,  -- Blacksmith Hammer

    -- Healing Potions --
    118,   -- Minor Healing Potion
    858,   -- Lesser Healing Potion
    929,   -- Healing Potion
    1710,  -- Greater Healing Potion
    3928,  -- Superior Healing Potion
    13446, -- Major Healing Potion

    -- Mana Potions --
    2455,  -- Minor Mana Potion
    3385,  -- Lesser Mana Potion
    3827,  -- Mana Potion
    6149,  -- Greater Mana Potion
    13443, -- Superior Mana Potion
})

local TRADE_GOODS_SORTING = ToSortMap({
    -- Cloths --
    2589,  -- Linen Cloth
    2592,  -- Wool Cloth
    4306,  -- Silk Cloth
    4338,  -- Mageweave Cloth
    
    -- Bolts --
    2996,  -- Bolt of Linen Cloth
    2997,  -- Bolt of Woolen Cloth
    4305,  -- Bolt of Silk Cloth
    4339,  -- Bolt of Mageweave Cloth
    
    -- Ores (Common) --
    2770,  -- Copper Ore
    2771,  -- Tin Ore
    2772,  -- Iron Ore
    3857,  -- Coal
    3858,  -- Mithril Ore
    10620, -- Thorium Ore
    
    -- Ores (Uncommon) --
    2775,  -- Silver Ore
    2776,  -- Gold Ore
    7911,  -- Truesilver Ore

    -- Bars (Common) --
    2840,  -- Copper Bar
    3576,  -- Tin Bar
    2841,  -- Bronze Bar
    3575,  -- Iron Bar
    3859,  -- Steel Bar
    3860,  -- Mithril Bar
    3861,  -- Blacksteel Bar
    12359, -- Thorium Bar

    -- Bars (Uncommon) --
    2842,  -- Silver Bar
    3577,  -- Gold Bar
    6037,  -- Truesilver Bar
    12360, -- Arcanite Bar

    -- Stones --
    2836,  -- Coarse Stone
    2835,  -- Rough Stone
    2838,  -- Heavy Stone
    7912,  -- Solid Stone
    12365, -- Dense Stone

    -- Grinding Stones --
    3470,  -- Rough Grinding Stone
    3478,  -- Coarse Grinding Stone
    3486,  -- Heavy Grinding Stone
    7966,  -- Solid Grinding Stone
    12644, -- Dense Grinding Stone

    -- Leathers --
    2934,  -- Ruined Leather Scraps
    2318,  -- Light Leather
    2319,  -- Medium Leather
    4234,  -- Heavy Leather
    4304,  -- Thick Leather
    8170,  -- Rugged Leather
    17012, -- Core Leather

    -- Hides (Uncured) --
    783,   -- Light Hide
    4232,  -- Medium Hide
    4235,  -- Heavy Hide
    8169,  -- Thick Hide
    8171,  -- Rugged Hide

    -- Hides (Cured) --
    4231,  -- Cured Light Hide
    4233,  -- Cured Medium Hide
    4236,  -- Cured Heavy Hide
    8172,  -- Cured Thick Hide
    15407, -- Cured Rugged Hide
})

--|-------------------------|--
--|   Filtering & Sorting   |--
--|-------------------------|--

-- TODO add checks for equipment (equippable armor/weapons)
local function IsEpicEquipment(itemInfo)
    local itemRarity = itemInfo[4]
    return itemRarity == 4
end

local function IsRareEquipment(itemInfo)
    local itemRarity = itemInfo[4]
    return itemRarity == 3
end

local function IsUncommonEquipment(itemInfo)
    local itemRarity = itemInfo[4]
    return itemRarity == 2
end

local function IsCommonEquipment(itemInfo)
    local itemRarity = itemInfo[4]
    return itemRarity == 1
end

local function IsPoorEquipment(itemInfo)
    local itemRarity = itemInfo[4]
    return itemRarity == 0
end

local function IsConsumable(itemInfo)
    local itemType = itemInfo[7]
    return itemType == "Consumable"
end

local function IsQuest(itemInfo)
    local itemType = itemInfo[7]
    return itemType == "Quest"
end

local function IsTool(itemInfo)
    local itemType = itemInfo[7]
    local itemSubType = itemInfo[8]
    
    print(tostring(itemType) .. ", " .. tostring(itemSubType) .. ": " .. itemInfo[2])
    
    return itemType == "Key"
end

local function IsFavorite(itemInfo)
    return FAVORITES_SORTING[itemInfo[1]] ~= nil
end
local function SortFavorite(a, b)
    local valA = FAVORITES_SORTING[a[3][1]] or -1
    local valB = FAVORITES_SORTING[b[3][1]] or -1
    
    if valA == valB then
        return SortDefault(a, b)
    end
    return valA < valB
end

local function IsTradeGood(itemInfo)
    local itemType = itemInfo[7]
    return itemType == "Trade Goods"
end
local function SortTradeGood(a, b)
    local valA = TRADE_GOODS_SORTING[a[3][1]] or -1
    local valB = TRADE_GOODS_SORTING[b[3][1]] or -1
    
    if valA == valB then
        return SortDefault(a, b)
    end
    return valA < valB
end

local function SortDefault(a, b)
    local infoA = a[3]
    local infoB = b[3]

    if infoA[1] == infoB[1] then
        _, countA = GetContainerItemInfo(a[1], a[2])
        _, countB = GetContainerItemInfo(b[1], b[2])
        
        return countA > countB
    else
        return infoA[1] > infoB[1]
    end
end

--|--------------------------|--
--|   BagSorter Public API   |--
--|--------------------------|--

function BagSorter:GetItemInfo(itemLink)
    local itemId = ExtractItemId(itemLink)

    -- https://vanilla-wow.fandom.com/wiki/API_GetItemInfo
    return {itemId, GetItemInfo(itemLink)}
end

function BagSorter:SortBags(input)
    print("Sorting bags...")
    
    if CursorHasItem() then
        message("You must place the item under cursor before sorting!")
        return
    end

    -- First element is filtered list of slots, second is chooser, third is subsorter
    local sublists = {
        {{}, IsFavorite, SortFavorite},
        {{}, IsTool, SortTool},
        {{}, IsConsumable, SortDefault},
        {{}, IsQuest, SortDefault},
        {{}, IsTradeGood, SortTradeGood},
        {{}, IsEpicEquipment, SortEpicEquipment},
        {{}, IsRareEquipment, SortRareEquipment},
        {{}, IsUncommonEquipment, SortUncommonEquipment},
        {{}, IsCommonEquipment, SortCommonEquipment},
        {{}, IsPoorEquipment, SortPoorEquipment},

        -- Last sublist is the catch-all
        {{}, function(p) return true end, SortDefault},
    }

    -- We use the empty slot as the temporary storage for swapping slots during sort
    local emptySlot = nil

    local slotMap = {}

    -- First pass: build out filtered sublists
    for bagid = 0, 4 do
        for slotid = 1, GetContainerNumSlots(bagid) do
            -- Check against each sublist
            for _, sublist in ipairs(sublists) do
                local link = GetContainerItemLink(bagid, slotid)
                if link then
                    local info = BagSorter:GetItemInfo(link)

                    -- If this item passes the sublist filter func
                    if sublist[2](info) then
                        local key = ('%s:%s'):format(bagid, slotid)

                        slotMap[key] = {bagid, slotid, info}
                        table.insert(sublist[1], slotMap[key])
                        break
                    end
                elseif not emptySlot then
                    emptySlot = {bagid, slotid}
                    break
                end
            end
        end
    end

    if not emptySlot then
        message("Must have at least one empty slot to sort bags!")
        return
    end

    -- Make last slot the empty slot
    --local lastBagId = self.pluginFor.bagIndexes[#self.pluginFor.bagIndexes]
    --local lastSlotId = self.pluginFor.frame.bags[lastBagId].size
    
    --self:SwapItems(emptySlot[1], emptySlot[2], lastBagId, lastSlotId, slotMap)
    --emptySlot[1] = lastBagId
    --emptySlot[2] = lastSlotId

    local slots = {}

    -- Second pass: sort each sublist via their subsorters and build out final list
    local merged = {}
    for listid, sublist in ipairs(sublists) do
        -- Invoke subsorter on sublist
        --sublist[3](sublist[1])
        table.sort(sublist[1], sublist[3])

        local debugstr = "    " .. tostring(listid) .. ": "
        for _, item in ipairs(sublist[1]) do
            table.insert(merged, item)
            
            debugstr = debugstr .. tostring(item[3][1]) .. ", "
        end
        --print(debugstr)
    end

    local curItemIndex = 1
    local curItem = merged[curItemIndex]

    for bagid = 0, 4 do
        for slotid = 1, GetContainerNumSlots(bagid) do
            if curItem then
                -- Move pre-existing item from target slot to placeholder slot
                --local link = GetContainerItemLink(bagid, slotid)
                --if link then
                --    self:SwapItems(bagid, slotid, emptySlot[1], emptySlot[2], slotMap)
                --end

                -- Now move next item into its target slot
                BagSorter:SwapItems(curItem[1], curItem[2], bagid, slotid, slotMap)

                curItemIndex = curItemIndex + 1
                curItem = merged[curItemIndex]
            end
        end
    end

    return slots
end

function BagSorter:SwapItems(fromBag, fromSlot, toBag, toSlot, slotMap)
    if fromBag == toBag and fromSlot == toSlot then
        return
    end

    PickupContainerItem(fromBag, fromSlot)  -- Pick up item in 'from' slot, storing under cursor
    PickupContainerItem(toBag, toSlot)      -- Swap into 'to' slot, storing that item under cursor
    PickupContainerItem(fromBag, fromSlot)  -- Place item from 'to' slot into 'from' slot

    -- Update mappings in lookup table, if one was specified
    if slotMap then
        local fromKey = ('%s:%s'):format(fromBag, fromSlot)
        local toKey = ('%s:%s'):format(toBag, toSlot)

        local fromItem = slotMap[fromKey]
        local toItem = slotMap[toKey]

        --slotMap[fromKey] = nil
        --slotMap[toKey] = nil

        if fromItem and toItem then
            --print("    Swap: " .. tostring(fromItem[3][1]) .. " & " .. tostring(toItem[3][1]))
        end

        if fromItem then
            fromItem[1] = toBag
            fromItem[2] = toSlot
        end
        if toItem then
            toItem[1] = fromBag
            toItem[2] = fromSlot
        end

        slotMap[toKey] = fromItem
        slotMap[fromKey] = toItem
    end
end

--|-------------------------|--
--|   Plugin Registration   |--
--|-------------------------|--

Daddy:RegisterPlugin("BagSorter", BagSorter)
Daddy:RegisterSubcommand("sortbags", BagSorter.SortBags, "Sorts bags according to customizable criteria")
