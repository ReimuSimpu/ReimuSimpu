-- THIS IS ORIGINALLY MY OWN CODE WITH AI "OPTAMIZATIONS"
-- THIS IS ORIGINALLY MY OWN CODE WITH AI "OPTAMIZATIONS"
-- THIS IS ORIGINALLY MY OWN CODE WITH AI "OPTAMIZATIONS"
-- THIS IS ORIGINALLY MY OWN CODE WITH AI "OPTAMIZATIONS"
-- THIS IS ORIGINALLY MY OWN CODE WITH AI "OPTAMIZATIONS"

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

-- Cached requires
local Directory = require(Library.Directory)
local Savemod = require(Client.Save)
local Network = require(Client.Network)
local MasteryCmds = require(Client.MasteryCmds)
local Items = require(Library.Items)
local ItemTypes = require(Library.Items.Types).Types

-- Predefined tables
local SpecialClassCases = {
    Card = "CardItems",
    Lootbox = "Lootboxes",
    Box = "Boxes",
    Misc = "MiscItems"
}

-- Build DirClassesTable once
local DirClassesTable = {}
for Class in pairs(ItemTypes) do
    DirClassesTable[Class] = SpecialClassCases[Class] or Class .. "s"
end

-- Cache frequently used functions
local math_floor = math.floor
local math_random = math.random
local string_format = string.format
local table_insert = table.insert
local pairs = pairs
local ipairs = ipairs
local pcall = pcall
local tonumber = tonumber
local tostring = tostring

-- Module Functions
function Modules.LibraryItem(Class, Item, Func)
    local ItemInstance = Items[Class](Item)
    return ItemInstance[Func](ItemInstance)
end

function Modules.GetItem(Class, Id)
    local Inventory = Savemod.Get().Inventory[Class]
    if not Inventory then return end

    for UID, ItemInfo in pairs(Inventory) do
        if ItemInfo.id == Id then
            return UID, ItemInfo
        end
    end
end

Modules.ChangeSettings = function(Desired) 
	local SaveData = Savemod.Get()
	for i,v in pairs(Desired) do
		if SaveData['Settings'][i] ~= v then
			if Network.Invoke("Toggle Setting", i,v) then
				print(string.format("[%s] Changed Settings %s to %s from %s", LocalPlayer.Name, i, v, SaveData['Settings'][i]))
			end
		end
	end
end

function Modules.GetStartTime(Folder)
    local File = Folder .. "/" .. LocalPlayer.Name .. ".json"
    
    if not isfolder(Folder) then
        makefolder(Folder)
        print(string_format("[%s] Created Folder: %s", LocalPlayer.Name, Folder))
    end
    
    if not isfile(File) then
        writefile(File, tostring(os.clock()))
        print(string_format("[%s] Created File: %s", LocalPlayer.Name, File))
        return 0
    end

    local Success, StoredTime = pcall(readfile, File)
    return Success and tonumber(StoredTime) or 0
end

function Modules.GetBestTier(Class, Id)
    local BestItem = { tn = 0 }
    local BestUUID = nil
    local Inventory = Savemod.Get().Inventory[Class] or {}

    for UID, ItemInfo in pairs(Inventory) do
        local CanUse = (Class ~= "Enchant") or MasteryCmds.CanUseEnchant(ItemInfo.tn)
        if ItemInfo.id == Id and ItemInfo.tn > BestItem.tn and CanUse then
            BestUUID, BestItem = UID, ItemInfo
        end
    end
    
    return BestUUID, BestItem
end

function Modules.CraftGift(Event, Item)
    local UID, Info = Modules.GetItem("Misc", Item)
    if not UID or not Info or (Info._am or 1) < 10 then return end
    
    local CraftedAmount = math_floor(Info._am / 10)
    if Network.Invoke(Event, Info._am) then
        print(string_format("[%s] Crafted Gifts: %d (%d %s)", LocalPlayer.Name, CraftedAmount, Info._am, Item))
    end
end

Modules.GetPlayerImg = function(Type)
	local URL = string.format("https://thumbnails.roblox.com/v1/users/%s?userIds=%s&size=420x420&format=Png&isCircular=false", Type, LocalPlayer.UserId)
	return game.HttpService:JSONDecode(game:HttpGet(URL)).data[1].imageUrl
end

function Modules.GetStats(Cmds, Class, ItemTable)
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

function Modules.GetAssetId(Class, Info)
    local ClassTable = DirClassesTable[Class]
    if not ClassTable then return "rbxassetid://0" end

    local ItemTable = Directory[ClassTable][Info.id]
    if not ItemTable then return "rbxassetid://0" end

    if not Info.tn then
        return ItemTable.Icon or ItemTable.icon or ItemTable.thumbnail or "rbxassetid://0"
    end

    if ItemTable.Icon and type(ItemTable.Icon) == "function" then
        local Upvalues = debug.getupvalue(ItemTable.Icon, 1)
        if Upvalues and Upvalues[Info.tn] then
            return Upvalues[Info.tn]
        end
    elseif ItemTable.Tiers and ItemTable.Tiers[1] and ItemTable.Tiers[1].Effect then
        local EffectType = ItemTable.Tiers[1].Effect.Type
        if EffectType and EffectType.Tiers and EffectType.Tiers[Info.tn] then
            return EffectType.Tiers[Info.tn].Icon or "rbxassetid://0"
        end
    end

    return ItemTable.Icon or ItemTable.icon or ItemTable.thumbnail or "rbxassetid://0"
end

function Modules.AntiAfk()
    for _, Connection in ipairs(getconnections(LocalPlayer.Idled)) do
        Connection:Disable()
    end

    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(math_random(0, 1000), math_random(0, 1000)))
    end)
end

function Modules.RandomizeTeleport(Area, Range)
    Range = Range or math_random(1, 25)
    local RandomX = Area.X + math_random(-Range, Range)
    local RandomZ = Area.Z + math_random(-Range, Range)
    local RandomAngle = math.rad(math_random(0, 360))

    local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if HumanoidRootPart then
        HumanoidRootPart.CFrame = CFrame.new(RandomX, Area.Y, RandomZ) * CFrame.Angles(0, RandomAngle, 0)
    end
end

function Modules.DestroyChildren(Instance, ExcludeList)
    local ExcludeSet = {}
    for _, Name in ipairs(ExcludeList) do
        ExcludeSet[Name] = true
    end

    for _, Child in ipairs(Instance:GetChildren()) do
        if not ExcludeSet[Child.Name] then
            pcall(Child.Destroy, Child)
        end
    end
end

function Modules.TimeToString(Int)
    local Hours = math_floor(Int / 3600)
    local Minutes = math_floor((Int % 3600) / 60)
    local Seconds = math_floor(Int % 60)

    return string_format("%02d:%02d:%02d", Hours, Minutes, Seconds)
end

function Modules.Format(Int)
    Int = Int or 0
    if Int < 1000 then return tostring(Int) end

    local Suffixes = {
        "K", "M", "B", "T",                   -- Thousand, Million, Billion, Trillion
        "Qa", "Qi", "Sx", "Sp", "Oc", "No",    -- Quadrillion to Nonillion
        "Dc", "UDc", "DDc", "TDc", "QaDc",     -- Decillion to Quattuordecillion
        "QiDc", "SxDc", "SpDc", "OcDc", "NoDc", -- Quindecillion to Novemdecillion
        "Vg"                                   -- Vigintillion
    }

    local Index = 1
    while Int >= 1000 and Index < #Suffixes do
        Int = Int / 1000
        Index = Index + 1
    end

    return string_format("%.2f%s", Int, Suffixes[Index])
end

return Modules
