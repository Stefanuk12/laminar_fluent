-- // Services
local Workspace = game:GetService("Workspace")

--[=[
    @private
    @within free

    Converts a 2D screen position to a 3D world position at a specified distance from the camera.
]=]
local function WorldToScreen(Position: Vector2, Distance: number): Vector3
    local CurrentCamera = Workspace.CurrentCamera
    local UnitRay = CurrentCamera:ScreenPointToRay(Position.X, Position.Y)
    return UnitRay.Origin + (UnitRay.Direction * Distance)
end
return WorldToScreen
