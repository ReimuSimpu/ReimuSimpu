local ABC = {}

ABC.OptamizeParts = function(descendant)
    pcall(function()
        if not descendant:IsDescendantOf(Players.LocalPlayer.PlayerGui) then
            if table.find(PartClassNames, descendant.ClassName) then
                descendant.Material = Enum.Material.Plastic
                descendant.Reflectance = 0
                descendant.Massless = true
                descendant.Transparency = 1
                descendant.MeshId = ""
                descendant.TextureID = ""
            elseif table.find(DestroyClass, descendant.ClassName) then
                descendant:Destroy()
            elseif descendant:IsA("Explosion") then
                descendant.BlastPressure = 1
                descendant.BlastRadius = 1
                descendant.Visible = false
            elseif descendant:IsA("PostEffect") then
                descendant.Enabled = false
            elseif table.find(DisableClass, descendant.ClassName) then
                descendant.Enabled = false
            elseif descendant:IsDescendantOf("CoreGui") then
                descendant.Transparency = 1
            end
        end
    end)
end

ABC.HandlePlayer = function(player)
    pcall(function() player.leaderstats:Destroy() end)
    player.CharacterAdded:Connect(function(character)
        for _, v in pairs(character:GetDescendants()) do
            pcall(function()
                if PlayerObjectsDestroy[v.ClassName] or NamesToDestroy[v.Name] then
                    v:Destroy()
                elseif not string.find(v.Name, "HippoHaven") then
                    v.Transparency = 1
                end
            end)
        end
    end)
end

return ABC
