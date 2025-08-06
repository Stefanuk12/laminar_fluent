-- // Services
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

--[=[
    @within free
    @private
    
    Detects the current operating system or platform the game is running on.
    
    Uses various Roblox services and version information to determine the platform:
    - Checks for console interfaces (Xbox, PlayStation, generic Console)
    - Detects Windows through [GuiService]
    - Identifies macOS through version string patterns
    - Distinguishes between Mobile and MetaHorizon VR platforms
]=]
local function GetOS()
    local OSName = "Unknown"

    if GuiService:IsTenFootInterface() then
        local L2Button_Name = UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonL2)

        OSName = if L2Button_Name == "ButtonLT"
            then "Xbox"
            elseif L2Button_Name == "ButtonL2" then "PlayStation"
            else "Console"
    elseif (GuiService :: any).IsWindows then
        OSName = "Windows"
    elseif version():find("^0.") == 1 then
        OSName = "macOS"
    elseif version():find("^2.") == 1 then
        OSName = UserInputService.VREnabled and "MetaHorizon" or "Mobile"
    end

    return OSName
end
return GetOS
