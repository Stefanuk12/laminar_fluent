-- // Dependencies
local Trove = require("@pkgs/trove")
local WorldToScreen = require("@functions/world_to_screen")
local ViewportOffset = require("@functions/viewport_offset")
local Create = require("@functions/create")

-- // Services
local Workspace = game:GetService("Workspace")

-- // Types
export type AcrylicBlurData = {
    Trove: Trove.Trove,
    Distance: number,
    Frame: Frame,
    Part: Part,
    Mesh: SpecialMesh,
    Positions: {
        TopLeft: Vector2,
        TopRight: Vector2,
        BottomRight: Vector2,
    },
}

-- WARN: this is DETECTABLE
local GlobalBlurFolder = Instance.new("Folder")
GlobalBlurFolder.Parent = Workspace.CurrentCamera

--[=[
    @private

    Creates a new acrylic part with a special mesh for the blur effect.
]=]
local function CreateAcrylic()
    local SpecialMesh = Create("SpecialMesh", {
        MeshType = Enum.MeshType.Brick,
        Offset = Vector3.new(0, 0, -0.000001),
    })
    return Create("Part", {
        Name = "Body",
        Color = Color3.new(0, 0, 0),
        Material = Enum.Material.Glass,
        Size = Vector3.new(1, 1, 0),
        Anchored = true,
        CanCollide = false,
        Locked = true,
        CastShadow = false,
        Transparency = 0.98,
    }, { SpecialMesh }),
        SpecialMesh
end

--[=[
    @class AcrylicBlur
    
    A blur effect system that creates an acrylic glass-like appearance behind GUI elements.
    This uses a 3D part positioned in world space to create the blur effect.
    
    :::warning Detectable
    This blur effect is **detectable** as it creates objects in the workspace.
    :::
]=]
local AcrylicBlur = {}
AcrylicBlur.__index = AcrylicBlur
export type AcrylicBlur = typeof(setmetatable({} :: AcrylicBlurData, AcrylicBlur))
do
    --[=[
        Creates a new [AcrylicBlur] instance.
        
        @param Distance number? -- Optional distance from camera for the blur effect (defaults to 0.001)
    ]=]
    function AcrylicBlur.new(Distance: number?): AcrylicBlur
        -- // Create the object
        local self = setmetatable({}, AcrylicBlur)

        -- // Set
        self.Distance = Distance or 0.001
        self.Trove = Trove.new()
        self.Positions = {
            TopLeft = Vector2.zero,
            TopRight = Vector2.zero,
            BottomRight = Vector2.zero,
        }

        -- // Create the objects
        local Acrylic, Mesh = CreateAcrylic()
        Acrylic.Parent = GlobalBlurFolder
        self.Frame = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
        }) :: Frame
        self.Part = Acrylic :: Part
        self.Mesh = Mesh :: SpecialMesh

        -- // Initiaise connections
        self:Initialise()

        -- // Return the object
        return self
    end

    --[=[
        Destroy this object, and perform cleanup.
    ]=]
    function AcrylicBlur.Destroy(self: AcrylicBlur)
        self.Trove:Destroy()
        setmetatable(self :: any, nil)
    end

    --[=[
        @private

        Updates the cached screen positions for the blur area.
    ]=]
    function AcrylicBlur.UpdatePositions(self: AcrylicBlur, Size: Vector2, Position: Vector2)
        self.Positions.TopLeft = Position
        self.Positions.TopRight = Position + Vector2.new(Size.X, 0)
        self.Positions.BottomRight = Position + Size
    end

    --[=[
        @private

        Renders the blur effect by positioning and scaling the 3D part based on screen positions.
    ]=]
    function AcrylicBlur.Render(self: AcrylicBlur)
        local CurrentCamera = Workspace.CurrentCamera
        local CameraTransform = if CurrentCamera then CurrentCamera.CFrame else CFrame.identity

        local TopLeft = WorldToScreen(self.Positions.TopLeft, self.Distance)
        local TopRight = WorldToScreen(self.Positions.TopRight, self.Distance)
        local BottomRight = WorldToScreen(self.Positions.BottomRight, self.Distance)
        local PartCFrame = CFrame.fromMatrix(
            (TopLeft + BottomRight) / 2,
            CameraTransform.XVector,
            CameraTransform.YVector,
            CameraTransform.ZVector
        )

        local Width = (TopRight - TopLeft).Magnitude
        local Height = (TopRight - BottomRight).Magnitude
        local Scale = Vector3.new(Width, Height, 0)

        self.Part.CFrame = PartCFrame
        self.Mesh.Scale = Scale
    end

    --[=[
        Updates the blur effect when the tracked GUI object changes.

        @param Object GuiObject -- The GUI object to track for blur positioning
    ]=]
    function AcrylicBlur.Changed(self: AcrylicBlur, Object: GuiObject)
        local Offset = ViewportOffset()
        local OffsetVector = Vector2.new(Offset, Offset)

        local Size = Object.AbsoluteSize - OffsetVector
        local Position = Object.AbsolutePosition + OffsetVector / 2
        self:UpdatePositions(Size, Position)

        task.spawn(function()
            self:Render()
        end)
    end

    --[=[
        Sets the visibility of the blur effect.

        @param Value boolean -- Whether the blur should be visible
    ]=]
    function AcrylicBlur.SetVisiblity(self: AcrylicBlur, Value: boolean)
        self.Frame.Transparency = Value and 0.98 or 1
    end

    --[=[
        Adds a parent GUI object to track visibility changes.
        The blur will automatically hide/show based on the parent's visibility.
        
        @param Parent GuiObject -- The parent GUI object to track
    ]=]
    function AcrylicBlur.AddParent(self: AcrylicBlur, Parent: GuiObject)
        self.Trove:Add(self.Frame:GetPropertyChangedSignal("Visible"):Connect(function()
            self:SetVisiblity(Parent.Visible)
        end))
    end

    --[=[
        @private

        Initializes the blur system by setting up camera and frame change listeners.
        This is called automatically when creating a new instance.
    ]=]
    function AcrylicBlur.Initialise(self: AcrylicBlur)
        local CurrentCamera = Workspace.CurrentCamera

        local function Render()
            self:Render()
        end

        self.Trove:Add(self.Part.Destroying:Connect(function()
            self:Destroy()
        end))

        self.Trove:Add(CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(Render))
        self.Trove:Add(CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(Render))
        self.Trove:Add(CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(Render))

        task.spawn(Render)

        local function OnChange()
            self:Changed(self.Frame)
        end

        self.Trove:Add(self.Frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(OnChange))
        self.Trove:Add(self.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(OnChange))
    end
end
return AcrylicBlur
