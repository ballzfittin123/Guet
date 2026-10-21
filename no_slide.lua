-- No-slide movement: instant start/stop on the ground
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
while not player do
    task.wait()
    player = Players.LocalPlayer
end

print("[no_slide] loaded")

local connections = {}

local function clear()
    for _, c in ipairs(connections) do
        c:Disconnect()
    end
    table.clear(connections)
end

local function setup(character)
    clear()

    local humanoid = character:WaitForChild("Humanoid", 10)
    local root = character:WaitForChild("HumanoidRootPart", 10)
    if not humanoid or not root then
        warn("[no_slide] humanoid/root not found")
        return
    end

    print("[no_slide] attached to character")

    local function applyFriction(part)
        if part:IsA("BasePart") then
            part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 2, 0, 100, 100)
        end
    end
    for _, part in ipairs(character:GetDescendants()) do
        applyFriction(part)
    end
    table.insert(connections, character.DescendantAdded:Connect(applyFriction))

    local function step()
        if humanoid.Health <= 0 or not root.Parent then return end
        if humanoid.FloorMaterial == Enum.Material.Air then return end
        if humanoid:GetState() == Enum.HumanoidStateType.Seated then return end

        local vel = root.AssemblyLinearVelocity
        local dir = humanoid.MoveDirection

        if dir.Magnitude < 0.01 then
            root.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0)
        else
            local speed = humanoid.WalkSpeed
            root.AssemblyLinearVelocity = Vector3.new(dir.X * speed, vel.Y, dir.Z * speed)
        end
    end

    -- Run before and after physics so the game's movement can't undo it
    table.insert(connections, RunService.Stepped:Connect(step))
    table.insert(connections, RunService.Heartbeat:Connect(step))
end

if player.Character then
    task.spawn(setup, player.Character)
end
player.CharacterAdded:Connect(setup)
