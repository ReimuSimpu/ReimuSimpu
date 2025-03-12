local Modules = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Library = ReplicatedStorage.Library
local Client = Library.Client

local Directory = require(Library.Directory)
local SaveMod = require(Client.Save)
local Network = require(Client.Network)
local MasteryCmds = require(Client.MasteryCmds)

-- Special Class Cases
local SpecialClassCases = {
    Card = "CardItems",
    Lootbox = "Lootboxes",
    Box = "Boxes",
    Misc = "MiscItems"
}

-- Build DirClassesTable
local DirClassesTable = {}
for Class, _ in pairs(require(Library.Items.Types).Types) do
    DirClassesTable[Class] = SpecialClassCases[Class] or Class .. "s"
end

-- Module Functions
Modules.GetItem = function(Class, Id)
    local Inventory = SaveMod.Get().Inventory[Class]
    if not Inventory then return end

    for UID, ItemInfo in pairs(Inventory) do
        if ItemInfo.id == Id then
            return UID, ItemInfo
        end
    end
end

Modules.GetBestTier = function(Class, Id)
    local Item = { tn = 0 }
    local UUID = nil

    local Inventory = Savemod.Get().Inventory[Class] or {}

    for i, v in pairs(Inventory) do
        local CanUse = (Class ~= "Enchant") or MasteryCmds.CanUseEnchant(v.tn)
        if v.id == Id and v.tn > Item.tn and CanUse then
            UUID, Item = i, v
        end
    end
    return UUID, Item
end

Modules.CraftGift = function(Event, Item)
    local UID, Info = Modules.GetItem("Misc", Item)
    if not UID or not Info or Info._am < 10 then return end

    local CraftedAmount = math.floor(Info._am / 10)
    if Network.Invoke(Event, Info._am) then
        print(string.format("[%s] Crafted Gifts: %d (%d %s)", LocalPlayer.Name, CraftedAmount, Info._am, Item))
    end
end

Modules.GetStats = function(Cmds, Class, ItemTable)
    if not Cmds or not Cmds.Get or type(Cmds.Get) ~= "function" then
        return 0
    end

    local RequestObject = {
        Class = { Name = Class },
        IsA = function(InputClass)
            return InputClass == Class
        end,
        GetId = function()
            return ItemTable.id
        end,
        StackKey = function()
            return HttpService:JSONEncode({
                id = ItemTable.id,
                sh = ItemTable.sh,
                pt = ItemTable.pt,
                tn = ItemTable.tn
            })
        end
    }

    return Cmds.Get(RequestObject) or 0
end

Modules.GetAssetId = function(Class, Info)
    local ClassTable = DirClassesTable[Class]
    if not ClassTable then return "rbxassetid://0" end

    local ItemTable = Directory[ClassTable][Info.id]
    if not ItemTable then return "rbxassetid://0" end

    local Icon
    if Info.tn then
        if ItemTable.Icon and type(ItemTable.Icon) == "function" then
            local Upvalues = getupvalues(ItemTable.Icon)
            if Upvalues and Upvalues[1] then
                Icon = Upvalues[1][Info.tn]
            end
        elseif ItemTable.Tiers and ItemTable.Tiers[1] and ItemTable.Tiers[1].Effect then
            local EffectType = ItemTable.Tiers[1].Effect.Type
            if EffectType and EffectType.Tiers and EffectType.Tiers[Info.tn] then
                Icon = EffectType.Tiers[Info.tn].Icon
            end
        end
    end

    return Icon or ItemTable.Icon or ItemTable.icon or ItemTable.thumbnail or "rbxassetid://0"
end

Modules.AntiAfk = function()
    for _, Connection in pairs(getconnections(LocalPlayer.Idled)) do
        Connection:Disable()
    end

    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(math.random(0, 1000), math.random(0, 1000)))
    end)
end

Modules.RandomizeTeleport = function(Area, Range)
    Range = Range or math.random(1, 25)

    local RandomX = Area.X + math.random(-Range, Range)
    local RandomZ = Area.Z + math.random(-Range, Range)
    local RandomAngle = math.rad(math.random(0, 360))

    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(RandomX, Area.Y, RandomZ) * CFrame.Angles(0, RandomAngle, 0)
end

Modules.DestroyChildren = function(Instance, ExcludeList)
    local ExcludeSet = {}
    for _, Name in ipairs(ExcludeList) do
        ExcludeSet[Name] = true
    end

    for _, Child in ipairs(Instance:GetChildren()) do
        if not ExcludeSet[Child.Name] then
            Child:Destroy()
        end
    end
end

Modules.TimeToString = function(Int)
    local Hours = math.floor(Int / 3600)
    local Minutes = math.floor((Int % 3600) / 60)
    local Seconds = math.floor(Int % 60)

    return string.format("%02d:%02d:%02d", Hours, Minutes, Seconds)
end

Modules.Format = function(Int)
    local Suffix = { "", "K", "M", "B", "T" }
    local Index = 1

    if Int < 1000 then
        return string.format("%d", Int)
    end

    while Int >= 1000 and Index < #Suffix do
        Int = Int / 1000
        Index = Index + 1
    end

    return string.format("%.2f%s", Int, Suffix[Index])
end

return Modules
