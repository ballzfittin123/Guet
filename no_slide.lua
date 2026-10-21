-- High Friction Script for Delta Executor (autoexec)
-- Applies maximum friction to all BaseParts on the client.

-- 1. Define the physical properties with max friction (2.0 is the Roblox maximum).
local highFrictionProps = PhysicalProperties.new(
    1,    -- Density (default)
    2.0,  -- Friction (maximum value)
    0.5,  -- Elasticity (default)
    1,    -- FrictionWeight
    1     -- ElasticityWeight
)

-- 2. Helper function to safely apply the properties to a single part.
local function applyHighFriction(part)
    if part:IsA("BasePart") then
        pcall(function()
            part.CustomPhysicalProperties = highFrictionProps
        end)
    end
end

-- 3. Apply to every part that already exists in the game.
for _, descendant in ipairs(game:GetDescendants()) do
    applyHighFriction(descendant)
end

-- 4. (Optional) Catch any new parts that are added later, such as map chunks or props.
game.DescendantAdded:Connect(applyHighFriction)

print("[Delta Autoexec] High friction applied to all surfaces (client-side).")