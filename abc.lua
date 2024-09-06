local LocalPlayer = game.Players.LocalPlayer
local HRP = LocalPlayer.Character.HumanoidRootPart
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local Lighting = game:GetService("Lighting")

Terrain.WaterWaveSize, Terrain.WaterWaveSpeed, Terrain.WaterReflectance, Terrain.WaterTransparency = 0, 0, 0, 0
Lighting.GlobalShadows, Lighting.FogEnd = false, 9e9

local Delete_Workspace = { "Map" }
local entities = { "Stats", "Chat", "Debris" }
local Things_ChildrenRemove = { "Flags", "Breakables", "Ski Chairs", "ShinyRelics", "BalloonGifts", "Eggs", "CustomEggs", "__FAKE_GROUND" }
local Delete_Game = { Lighting,game:GetService("Chat").ClientChatModules,game:GetService("TextChatService"),game:GetService("Stats").Sound,game:GetService("Stats").PerformanceStats }
if not CFG["Optamize+"]["CoreGui"] then table.insert(entities, "CoreGui") end

--########################################################
----------------------- Workspace ------------------------
--########################################################

for _, v in ipairs(Delete_Workspace) do
    pcall(function() workspace[v]:Destroy() end)
end

for _, v in ipairs(workspace:GetChildren()) do
    if not (v.Name == "__THINGS" or v.Name == "__DEBRIS" or v.Name == LocalPlayer.Name or v.Name == "Camera" or v.Name == "Terrain" or v.Name == "Border") then
        v.Parent = ReplicatedStorage
    end
end

pcall(function() for _, v in ipairs(workspace:GetDescendants()) do pcall(function() v.CanCollide, v.CanTouch, v.CanQuery, v.Massless, v.Transparency = false, false, false, true, 1 end) end end)

workspace.DescendantAdded:Connect(function(child)
    if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") then
        game:GetService("RunService").Heartbeat:Wait()
        child:Destroy()
    end
end)

--########################################################
------------------------- Game ---------------------------
--########################################################

pcall(function()
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") then v.Material, v.Reflectance = "Plastic", 0
        elseif v:IsA("Decal") then v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Explosion") then v.BlastPressure, v.BlastRadius = 1, 1 end
    end
end)

for _, entity in ipairs(entities) do
    pcall(function()
        for _, v in ipairs(game[entity]:GetDescendants()) do
            v:Destroy()
        end
    end)
end

--########################################################
------------------------ Things --------------------------
--########################################################

for _, v in ipairs(workspace.__THINGS:GetChildren()) do
    if table.find(Things_ChildrenRemove, v.Name) then
        for _, child in ipairs(v:GetChildren()) do
            child:Destroy()
        end
        v.Parent = ReplicatedStorage
    end
end

--########################################################
-------------------------- All ---------------------------
--########################################################

for _, v in ipairs(LocalPlayer.PlayerScripts:GetChildren()) do
    pcall(function() v:Destroy() end)
end

for _, v in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
    pcall(function() v.Enabled = false end)
end

local function cleanTaggedInstances(tag)
    for _, instance in ipairs(workspace:GetDescendants()) do
        if instance:IsA(tag) then
            pcall(function() instance:Destroy() end)
        end
    end
end

cleanTaggedInstances("Model")
cleanTaggedInstances("Script")
collectgarbage("collect")
