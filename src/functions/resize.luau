-- // Services
local Workspace = game:GetService("Workspace")

--[=[
    @within free
    @private
    
    Converts absolute pixel coordinates to viewport-relative coordinates.
    
    Takes coordinates based on a 1920x1080 reference resolution and scales them
    proportionally to the current viewport size. Useful for creating responsive
    UI elements that maintain their relative positioning across different screen sizes.
]=]
local function Resize(X: number, Y: number): Vector2
    local Relative = Vector2.new(X / 1920, Y / 1080)
    return Workspace.CurrentCamera.ViewportSize * Relative
end
return Resize
