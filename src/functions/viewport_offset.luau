-- // Services
local Workspace = game:GetService("Workspace")

--[=[
    @private
    @within free

    Maps a value from one range to another range using linear interpolation.
]=]
local function Remap(Value: number, InMin: number, InMax: number, OutMin: number, OutMax: number): number
    return (Value - InMin) * (OutMax - OutMin) / (InMax - InMin) + OutMin
end

--[=[
    @private
    @within free

    Calculates a responsive offset value based on the current viewport height.
    
    This function provides a dynamic offset that scales with the viewport size,
    useful for creating responsive UI elements that adapt to different screen sizes.
    The offset ranges from 8 pixels (at viewport height 0) to 56 pixels (at viewport height 2560).
    
    @return -- The calculated offset value in pixels (8-56 range)
]=]
local function ViewportOffset(): number
    local CurrentCamera = Workspace.CurrentCamera
    local ViewportSizeY = CurrentCamera.ViewportSize.Y
    return Remap(ViewportSizeY, 0, 2560, 8, 56)
end
return ViewportOffset
