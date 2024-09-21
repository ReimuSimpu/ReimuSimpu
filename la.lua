local LocalPlayer = game.Players.LocalPlayer
local HRP = LocalPlayer.Character.HumanoidRootPart
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local Lighting = game:GetService("Lighting")

Terrain.WaterWaveSize, Terrain.WaterWaveSpeed, Terrain.WaterReflectance, Terrain.WaterTransparency = 0, 0, 0, 0
Lighting.GlobalShadows, Lighting.FogEnd = false, 9e9

local Delete_Workspace = { "Map" }
local entities = { "Stats", "Chat", "Debris" }
local ThingsToRemove = { "Flags", "Breakables", "Ski Chairs", "ShinyRelics", "BalloonGifts", "Eggs", "CustomEggs", "__FAKE_GROUND" }
pcall(function() if not CFG["Optamize+"]["CoreGui"] then table.insert(entities, "CoreGui") end end)

--########################################################
----------------------- Workspace ------------------------
--########################################################
workspace.Gravity = 0

print("Useless Workspace")
for _, v in ipairs(Delete_Workspace) do
    pcall(function() workspace[v]:Destroy() end)
end

print("Workspace Children")
for _, v in ipairs(workspace:GetChildren()) do task.wait(0.25)
    if not (v.Name == "__THINGS" or v.Name == "__DEBRIS" or v.Name == LocalPlayer.Name or v.Name == "Camera" or v.Name == "CurrentCamera" or v.Name == "Terrain" or v.Name == "Border") then
        v.Parent = ReplicatedStorage
    end
end

print("Workspace Connect")
workspace.DescendantAdded:Connect(function(child)
    if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") then
        game:GetService("RunService").Heartbeat:Wait()
        child:Destroy()
    end
end)

--########################################################
------------------------ Things --------------------------
--########################################################

print("Things Move/Delete")
for _, v in ipairs(workspace.__THINGS:GetChildren()) do
    if table.find(ThingsToRemove, v.Name) then
        for _, child in ipairs(v:GetChildren()) do
            child:Destroy()
        end
    elseif not (v.Name == "Orbs" or v.Name == "__INSTANCE_CONTAINER" or v.Name == "Lootbags") then
        v.Parent = ReplicatedStorage
    end
end

--########################################################
------------------------- Game ---------------------------
--########################################################

print("Service Deletion")
for _, entity in ipairs(entities) do
    pcall(function()
        for _, v in ipairs(game:GetService(entity):GetDescendants()) do
            pcall(function() v:Destroy() end)
        end
    end)
end

--########################################################
-------------------------- All ---------------------------
--########################################################

LocalPlayer.CharacterAdded:Connect(function(i)
    Character = i
    HRP = Character:WaitForChild("HumanoidRootPart")
    HRP.Anchored = true
end)

task.spawn(function()
    while true do
        print("Player Delete")
        for i, v in game.Players:GetPlayers() do
            if v ~= game.Players.LocalPlayer then
                pcall(function()
                    v.Character:Destroy()
                end)
            end
        end
        task.wait(30)
    end
end)

pcall(function()
    if not CFG["Optamize+"]["Show Tap Gui"] then
        print("TG")
        LocalPlayer.PlayerGui:WaitForChild("_INSTANCES"):WaitForChild("FishingGame"):GetPropertyChangedSignal("Enabled"):Connect(function()
            pcall(function() LocalPlayer.PlayerGui:WaitForChild("_INSTANCES"):WaitForChild("FishingGame").Enabled = false end)
        end)
    end
end)

print("EUI")
for _, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui:GetDescendants()) do
    pcall(function() v.Enabled = false end)
end
--[[
print("DPS")
for _,v in pairs(game:GetService("Players").LocalPlayer.PlayerScripts:GetChildren()) do
    pcall(function() v:Destroy() end)
end
]]

print("pv")
for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
    pcall(function() v.Transparency = 1 end)
end

print("Workspace Descendants")
for _, v in ipairs(workspace:GetDescendants()) do
    if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
        v.Material = Enum.Material.Plastic
        v.Reflectance = 0
    elseif v:IsA("Decal") then
        v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Lifetime = NumberRange.new(0)
    elseif v:IsA("Explosion") then
        v.BlastPressure = 1
        v.BlastRadius = 1
    end
end

print("Active Descendants")
for _, v in pairs(workspace.__THINGS.__INSTANCE_CONTAINER.Active:GetDescendants()) do
    pcall(function() v.Transparency = 1 end)
end
