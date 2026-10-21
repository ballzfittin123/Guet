-- No-slide movement: instant start/stop on the ground
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local connection

local function setup(character)
    if connection then
        connection:Disconnect()
        connection = nil
    end

    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")

    -- High friction on every body part (density, friction, elasticity, frictionWeight, elasticityWeight)
    local function applyFriction(part)
        if part:IsA("BasePart") then
            part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 2, 0, 100, 100)
        end
    end
    for _, part in ipairs(character:GetDescendants()) do
        applyFriction(part)
    end
    character.DescendantAdded:Connect(applyFriction)

    connection = RunService.Heartbeat:Connect(function()
        if humanoid.Health <= 0 or not root.Parent then return end

        -- Only affect the player while standing on something
        if humanoid.FloorMaterial == Enum.Material.Air then return end

        local vel = root.AssemblyLinearVelocity
        local dir = humanoid.MoveDirection

        if dir.Magnitude < 0.01 then
            -- No input: stop horizontal movement immediately
            root.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0)
        else
            -- Input: reach full speed immediately
            local speed = humanoid.WalkSpeed
            root.AssemblyLinearVelocity = Vector3.new(dir.X * speed, vel.Y, dir.Z * speed)
        end
    end)
end

if player.Character then
    task.spawn(setup, player.Character)
end
player.CharacterAdded:Connect(setup)
