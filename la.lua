local LocalPlayer = game.Players.LocalPlayer
local HumanoidRootPart = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
local Humanoid = LocalPlayer.Character:WaitForChild("Humanoid")

local BodyGyro = Instance.new("BodyGyro")
local BodyVelocity = Instance.new("BodyVelocity")

BodyGyro.P = 9e4
BodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
BodyGyro.cframe = HumanoidRootPart.CFrame
BodyGyro.Parent = HumanoidRootPart

BodyVelocity.velocity = Vector3.new(0, 0, 0)
BodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
BodyVelocity.Parent = HumanoidRootPart

task.spawn(function()
    while task.wait() do
        Humanoid.PlatformStand = true
        BodyVelocity.velocity = Vector3.new(0, 0.1, 0)
        BodyGyro.cframe = HumanoidRootPart.CFrame
    end
end)

local HandleWorkspace = function(v)
    pcall(function() v.Transparency = 1 end)
    pcall(function() v.Enabled = false end)
    pcall(function() v.MeshId = "" end)
    pcall(function() v.TextureID = "" end)
    pcall(function() v.Material = Enum.Material.Plastic end)
end

for i, v in ipairs(game:GetDescendants()) do 
    HandleWorkspace(v) 
end

game.DescendantAdded:Connect(function(v) 
    HandleWorkspace(v) 
end)

game:GetService("RunService"):Set3dRenderingEnabled(true)
