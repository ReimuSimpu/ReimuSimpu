local mod = {}

mod.DestroyChildren = function(Path, Excludes)
    for i,v in pairs(Path:GetChildren()) do
        if not table.find(Excludes, v.Name) then
            v:Destroy()
        end
    end
end
mod.HandleWorkspace = function(v)
    pcall(function() v.Transparency = 1 end)
    pcall(function() v.Enabled = false end)
    pcall(function() v.MeshId = "" end)
    pcall(function() v.TextureID = "" end)
    pcall(function() v.Material = Enum.Material.Plastic end)
end
return mod
