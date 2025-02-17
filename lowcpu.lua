-- old thing from root

local LocalPlayer = game.Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local Terrain = game:FindFirstChildOfClass('Terrain')

UserSettings():GetService("UserGameSettings").MasterVolume = 0
UserSettings():GetService("UserGameSettings").GraphicsQualityLevel = 1

sethiddenproperty(Lighting, "Technology", 2)
sethiddenproperty(Terrain, "Decoration", false)
Terrain.WaterWaveSize = 0
Terrain.WaterWaveSpeed = 0
Terrain.WaterReflectance = 0
Terrain.WaterTransparency = 0
Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9
Lighting.Brightness = 0

local HandlePart = function(v)
    if v:IsA("BasePart") and not v:IsA("MeshPart") then
        v.Material = Enum.Material.Plastic
        v.Reflectance = 0
    elseif v:IsA("Decal") or v:IsA("Texture") then
        v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Lifetime = NumberRange.new(0)
    elseif v:IsA("Explosion") then
        v.BlastPressure = 1
        v.BlastRadius = 1
    elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
        v.Enabled = false
    elseif v:IsA("MeshPart") then
        v.Material = Enum.Material.Plastic
        v.Reflectance = 0
        v.TextureID = 10385902758728957
    elseif v:IsA("SpecialMesh") then
        v.TextureId = 0
    elseif v:IsA("ShirtGraphic") then
        v.Graphic = 1
    elseif v:IsA("Shirt") or v:IsA("Pants") then
        v[v.ClassName .. "Template"] = 1
    end
end

for i,v in pairs(Lighting:GetChildren()) do
    if table.find({"BlurEffect","SunRaysEffect","ColorCorrectionEffect","BloomEffect","DepthOfFieldEffect"}, v.ClassName) then
        v.Enabled = false
    end
end

for i,v in pairs(workspace:GetDescendants()) do
    HandlePart(v)
end

workspace.DescendantAdded:Connect(function(v)
    task.wait() HandlePart(v)
end)
