local Module = {}
local Library = game.ReplicatedStorage.Library
local Client = Library.Client

Module.Format = function(int)
    local index, Suffix = 1, {"", "K", "M", "B", "T"}
    while int >= 1000 and index < #Suffix do
        int = int / 1000
        index = index + 1
    end
    return string.format(index == 1 and "%d" or "%.2f%s", int, Suffix[index])
end

Module.DestroyChildren = function(Path, Excludes)
    for i,v in pairs(Path:GetChildren()) do
        if not table.find(Excludes, v.Name) then v:Destroy() end
    end
end

Module.GetItem = function(Class, Id)
    for UID, v in pairs(SaveMod.Get()['Inventory'][Class] or {}) do
        if v.id == Id then return UID, v end
    end
end

Module.GetAsset = function(Id, pt)
    local Asset = require(Library.Directory.Pets)[Id]
    return string.gsub(Asset and (pt == 1 and Asset.goldenThumbnail or Asset.thumbnail) or "14976456685", "rbxassetid://", "")
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
