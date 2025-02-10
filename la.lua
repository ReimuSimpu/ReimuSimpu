local LocalPlayer = game.Players.LocalPlayer

local HandleWorkspace = function(v)
    pcall(function() v.Transparency = 1 end)
    pcall(function() v.Enabled = false end)
    pcall(function() v.MeshId = "" end)
    pcall(function() v.TextureID = "" end)
    pcall(function() v.Material = Enum.Material.Plastic end)
end

local DestroyChildren = function(Path, Excludes)
    for i,v in pairs(Path:GetChildren()) do
        if not table.find(Excludes, v.Name) then v:Destroy() end
    end
end

DestroyChildren(game:GetService("Players"), {LocalPlayer.Name})
DestroyChildren(game:GetService("Lighting"), {})
DestroyChildren(game:GetService("CoreGui"), {})
DestroyChildren(workspace, {"Terrain", "Camera", "__THINGS", "__INSTANCE_CONTAINER", LocalPlayer.Name})
DestroyChildren(workspace.__THINGS, {"CustomEggs", "Islands", "Tycoons"})
DestroyChildren(LocalPlayer.PlayerScripts.Scripts.Game, {"Egg Opening Frontend"})
DestroyChildren(LocalPlayer.PlayerScripts.Scripts, {"Game"})
DestroyChildren(LocalPlayer.PlayerGui, {"ScreenGui"})

for i, v in ipairs(game:GetDescendants()) do 
    HandleWorkspace(v) 
end

game.DescendantAdded:Connect(function(v) 
    HandleWorkspace(v) 
end)

game:GetService("RunService"):Set3dRenderingEnabled(true)
