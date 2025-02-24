local Module = {}
local LocalPlayer = game.Players.LocalPlayer
local Library = game.ReplicatedStorage.Library
local Client = Library.Client
local Directory = require(Library.Directory)

local SaveMod = require(Client.Save)
local Network = require(Client.Network)
local EggCmds = require(Client.EggCmds)
local CurrencyCmds = require(Client.CurrencyCmds)
local InstancingCmds = require(Client.InstancingCmds)
local Directory = require(Library.Directory)

local SpecialClassCases, DirClassesTable = {Card = "CardItems", Lootbox = "Lootboxes", Box = "Boxes", Misc = "MiscItems"}, {}
for Class, _ in pairs(require(Library.Items.Types).Types) do 
    DirClassesTable[Class] = SpecialClassCases[Class] or Class .. "s" 
end

Module.Format = function(int)
    local index, Suffix = 1, {"", "K", "M", "B", "T"}
    while int >= 1000 and index < #Suffix do
        int = int / 1000
        index = index + 1
    end
    return string.format(index == 1 and "%d" or "%.2f%s", int, Suffix[index])
end

Module.GetItem = function(Class, Id)
    for UID, v in pairs(SaveMod.Get()['Inventory'][Class] or {}) do
        if v.id == Id then return UID, v end
    end
end

Module.GetAssetId = function(Class, Info)
    local Class = DirClassesTable[Class]
    local ItemTable = Directory[Class][Info.id]
    local Icon = nil
    if Info.tn then
        if ItemTable.Icon and type(ItemTable.Icon) == "function" then
            Icon = unpack(getupvalues(ItemTable.Icon))[Info.tn]
        elseif ItemTable.Tiers and ItemTable.Tiers[1] and ItemTable.Tiers[1].Effect then
            local EffectType = ItemTable.Tiers[1].Effect.Type
            Icon = EffectType and EffectType.Tiers and EffectType.Tiers[Info.tn].Icon
        end        
    end

    Icon = Icon or ItemTable.Icon or ItemTable.icon or ItemTable.thumbnail or "rbxassetid://0"
    return Icon
end

Module.DestroyChildren = function(Path, Excludes)
    for i,v in pairs(Path:GetChildren()) do
        if not table.find(Excludes, v.Name) then v:Destroy() end
    end
end

Module.GetStats = function(Cmds, Class, ItemTable)
    return Cmds.Get({
        Class = { Name = Class },
        IsA = function(InputClass) return InputClass == Class end,
        GetId = function() return ItemTable.id end,
        StackKey = function()
            return game:GetService("HttpService"):JSONEncode({id = ItemTable.id, sh = ItemTable.sh, pt = ItemTable.pt, tn = ItemTable.tn})
        end
    }) or nil
end

Module.CanAffordEgg = function(Id)
    local EggDetails = Directory.Eggs[Id]
    if not EggDetails then return false end

    setthreadidentity(2)
    local CanHatch = CurrencyCmds.Get(EggDetails.currency) >= (require(Library.Balancing.CalcEggPricePlayer)(EggDetails) * EggCmds.GetMaxHatch())
    setthreadidentity(8)

    return CanHatch
end

Module.GetEquippedPets = function()
    local EquippedPets = {}
    setidentity(2)
    for i,v in pairs(require(Client.PetCmds).GetEquipped()) do
        table.insert(EquippedPets, i)
    end
    setidentity(8)
    return EquippedPets
end

Module.UseUltimate = function()
    local UltimateCmds = require(Client.UltimateCmds)
    local EquippedUlt = UltimateCmds.GetEquippedItem()
    if EquippedUlt then
        if UltimateCmds.IsCharged(EquippedUlt._data.id) then
            UltimateCmds.Activate(EquippedUlt._data.id)
        end
    end
end

Module.GetBestPotion = function(Id)
    local BestUid, Best = nil, {tn = 0}
    for i, v in pairs(SaveMod.Get().Inventory.Potion or {}) do
        if v.id == Id and v.tn > Best.tn then
            BestUid, Best = i, v
        end
    end
    return BestUid, Best
end

Module.ConsumeFruits = function(Selected)
    local FruitCmds, Fruits = require(Client.FruitCmds), {}
    for i, v in pairs(SaveMod.Get()['Inventory']['Fruit'] or {}) do
        local MaxEat = FruitCmds.GetMaxConsume(i)
        if table.find(Selected, v.id) and MaxEat > 0 and MaxEat < (v._am or 1) then
            if not Fruits[v.id] or v.sh then   
                Fruits[v.id] = {uuid = i, info = v, eat = MaxEat}
            end
        end
    end
    for i, v in pairs(Fruits) do
        Network.Fire("Fruits: Consume", v.uuid, v.eat)
        print(string.format("[%s] Ate Fruit: %s (%sx)", LocalPlayer.Name, i, v.eat)) task.wait(.5)
    end
end

Module.DrinkPotions = function(Potions)
    for i,Id in pairs(Potions) do
        local Enabled, Tier, Time = require(Client.PotionCmds).Has(Id)
        local UID, Data = Module.GetBestPotion(Id)
        if UID and (not Enabled or Data.tn > Tier) then
            Network.Fire("Potions: Consume", UID, 1) 
            print(string.format("[%s] Drank Potion: %s %s", LocalPlayer.Name, Id, Data.tn)) task.wait(.5)
        end
    end
end
