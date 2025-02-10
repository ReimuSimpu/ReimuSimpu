local LocalPlayer = game:GetService("Players").LocalPlayer

local DestroyChildren = function(Path, Excludes)
    for i,v in pairs(Path:GetChildren()) do
        if not table.find(Excludes, v.Name) then
            v:Destroy()
        end
    end
end

local HandleWorkspace = function(v)
    pcall(function() v.Transparency = 1 end)
    pcall(function() v.Enabled = false end)
    pcall(function() v.Visible = false end)
    pcall(function() v.MeshId = "" end)
    pcall(function() v.TextureID = "" end)
    pcall(function() v.Massless = true end)
    pcall(function() v.Material = Enum.Material.Plastic end)
end

DestroyChildren(workspace, {"Terrain", "Camera", "Map", "Map2", "Map3", "__THINGS", LocalPlayer.Name})
DestroyChildren(workspace.__THINGS, {"CustomEggs", "Eggs", "__INSTANCE_CONTAINER", "Islands"})
DestroyChildren(game:GetService("CoreGui"), {"DevConsoleMaster"})
DestroyChildren(game:GetService("Lighting"), {})
DestroyChildren(LocalPlayer.PlayerScripts.Scripts, {"Game"})
DestroyChildren(LocalPlayer.PlayerScripts.Scripts.Game, {"Breakables", "Egg Opening Frontend"})
DestroyChildren(LocalPlayer.PlayerGui, {})
DestroyChildren(game:GetService("ReplicatedFirst"), {})
DestroyChildren(game:GetService("MaterialService"), {})

for i,v in pairs(game:GetService("Players"):GetPlayers()) do
    if v ~= LocalPlayer then 
        v:Destroy() 
    end
end

for i,v in pairs(workspace:GetDescendants()) do
    HandleWorkspace(v)
end

local RunService = game:GetService("RunService")
workspace.DescendantAdded:Connect(function(v)
    RunService.Heartbeat:Wait() 
    HandleWorkspace(v)
end)
