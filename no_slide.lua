-- No-slide (Atlas-compatible): friction + braking only when no input
-- and no automated movement is detected.
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Settings
local FRICTION = 3          -- higher = grippier (try 2 to 5)
local FRICTION_WEIGHT = 100 -- makes your friction win over the floor's
local BRAKE = 0.5           -- 0 = stop instantly when you let go, 1 = no braking (try 0 to 0.6)

local player = Players.LocalPlayer
while not player do
    task.wait()
    player = Players.LocalPlayer
end

local connections = {}

local function clear()
    for _, c in ipairs(connections) do
        c:Disconnect()
    end
    table.clear(connections)
end

-- Returns true if the character is being moved by an external script (e.g., Atlas)
local function isAutomatedMovement(humanoid, root)
    -- Pathfinding / MoveTo
    if humanoid.WalkToPoint ~= Vector3.zero or humanoid.WalkToPart ~= nil then
        return true
    end

    -- Tweening often anchors the root part to avoid physics interference
    if root.Anchored then
        return true
    end

    -- Common constraints used by tween / auto‑walk scripts
    for _, child in ipairs(root:GetChildren()) do
        if child:IsA("AlignPosition")
            or child:IsA("AlignOrientation")
            or child:IsA("LinearVelocity")
            or child:IsA("BodyPosition")
            or child:IsA("BodyGyro")
            or child:IsA("BodyVelocity")
        then
            return true
        end
    end

    return false
end

local function setup(character)
    clear()

    local humanoid = character:WaitForChild("Humanoid", 10)
    local root = character:WaitForChild("HumanoidRootPart", 10)
    if not humanoid or not root then return end

    local function applyFriction(part)
        if part:IsA("BasePart") then
            local p = part.CustomPhysicalProperties or PhysicalProperties.new(part.Material)
            part.CustomPhysicalProperties = PhysicalProperties.new(
                p.Density, FRICTION, p.Elasticity, FRICTION_WEIGHT, p.ElasticityWeight
            )
        end
    end
    for _, part in ipairs(character:GetDescendants()) do
        applyFriction(part)
    end
    table.insert(connections, character.DescendantAdded:Connect(applyFriction))

    -- Brake only when grounded, no manual input, and no automated movement
    table.insert(connections, RunService.Heartbeat:Connect(function()
        if humanoid.Health <= 0 or not root.Parent then return end
        if humanoid.FloorMaterial == Enum.Material.Air then return end

        -- Skip braking if Atlas (or any other script) is driving the character
        if isAutomatedMovement(humanoid, root) then return end

        if humanoid.MoveDirection.Magnitude > 0.01 then return end

        local v = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(v.X * BRAKE, v.Y, v.Z * BRAKE)
    end))
end

if player.Character then
    task.spawn(setup, player.Character)
end
player.CharacterAdded:Connect(setup)