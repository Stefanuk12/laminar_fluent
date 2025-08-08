-- // Dependencies
local Trove = require("@pkgs/trove")
local Flipper = require("@pkgs/flipper")

-- // Services
local UserInputService = game:GetService("UserInputService")

-- // Types
export type DraggerConstructorData = {
    DragFrame: Frame,
    GetStartPosition: () -> UDim2,
    SetPosition: (Position: UDim2) -> (),
}
export type DraggerData = DraggerConstructorData & {
    Dragging: boolean,
    DragInput: Enum.InputType?,
    DragStart: Vector2?,
    DragStartPosition: Vector2?,
    MousePosition: Vector3?,
    StartPosition: UDim2?,
}
export type ResizerConstructorData = {
    ResizeFrame: Frame,
    SizeMotor: typeof(Flipper.SingleMotor.new(0)),
    GetStartSize: () -> UDim2,
    GetMinSize: () -> Vector2,
    SetSize: (Size: UDim2) -> (),
}
export type ResizerData = ResizerConstructorData & {
    Resizing: boolean,
    ResizePosition: UDim2?,
}
export type DraggerResizerConstructorData = | {
    Mode: "Drag",
    Data: DraggerConstructorData,
} | {
    Mode: "Resize",
    Data: ResizerConstructorData,
} | {
    Mode: "Both",
    Data: DraggerConstructorData & ResizerConstructorData,
}
export type DraggerResizerMode = | {
    Mode: "Drag",
    Data: DraggerData,
} | {
    Mode: "Resize",
    Data: ResizerData,
} | {
    Mode: "Both",
    Data: DraggerData & ResizerData,
}
export type DraggerResizerData = {
    Trove: Trove.Trove,
    Mode: DraggerResizerMode,
}

-- //
local DraggerResizer = {}
DraggerResizer.__index = DraggerResizer
export type DraggerResizer = typeof(setmetatable({} :: DraggerResizerData, DraggerResizer))
do
    --[=[
        Create a new [DraggerResizer] object.
    ]=]
    function DraggerResizer.new(Data: DraggerResizerConstructorData): DraggerResizer
        -- // Create the object
        local self = setmetatable({}, DraggerResizer)

        -- // Set
        self.Trove = Trove.new()
        if Data.Mode == "Drag" then
            local ActualData = Data.Data
            local Mode: DraggerData = {
                DragFrame = ActualData.DragFrame,
                GetStartPosition = ActualData.GetStartPosition,
                SetPosition = ActualData.SetPosition,
                Dragging = false,
            }
            self.Mode = { Mode = "Drag", Data = Mode }
        elseif Data.Mode == "Resize" then
            local ActualData = Data.Data
            local Mode: ResizerData = {
                ResizeFrame = ActualData.ResizeFrame,
                SizeMotor = ActualData.SizeMotor,
                GetStartSize = ActualData.GetStartSize,
                GetMinSize = ActualData.GetMinSize,
                SetSize = ActualData.SetSize,
                Resizing = false,
            }
            self.Mode = { Mode = "Resize", Data = Mode }
        else
            local ActualData = Data.Data
            local Mode: DraggerResizerData = {
                DragFrame = ActualData.DragFrame,
                GetStartPosition = ActualData.GetStartPosition,
                Dragging = false,

                ResizeFrame = ActualData.ResizeFrame,
                SizeMotor = ActualData.SizeMotor,
                GetStartSize = ActualData.GetStartSize,
                GetMinSize = ActualData.GetMinSize,
                SetSize = ActualData.SetSize,
                Resizing = false,
            }
            self.Mode = { Mode = "Both", Data = Mode }
        end

        -- // Return the object
        return self
    end

    --[=[
        Destroy this object
    ]=]
    function DraggerResizer.Destroy(self: DraggerResizer)
        self.Trove:Destroy()
        setmetatable(self :: any, nil)
    end

    --[=[
        Create the dragger connections
    ]=]
    function DraggerResizer.CreateDragger(self: DraggerResizer)
        if self.Mode.Mode == "Resize" then
            return
        end
        local Data = self.Mode.Data

        self.Trove:Add(Data.DragFrame.InputBegan:Connect(function(Input)
            if
                Input.UserInputType ~= Enum.UserInputType.MouseButton1
                or Input.UserInputType ~= Enum.UserInputType.Touch
            then
                return
            end

            Data.Dragging = true
            Data.MousePosition = Input.Position
            Data.StartPosition = Data.GetStartPosition()

            local Connection
            Connection = Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    (Connection :: any):Disconnect()
                    Data.Dragging = false
                end
            end)
            Trove:Add(Connection)
        end))
        self.Trove:Add(Data.DragFrame.InputChanged:Connect(function(Input)
            if
                Input.UserInputType == Enum.UserInputType.MouseMovement
                or Input.UserInputType == Enum.UserInputType.Touch
            then
                Data.DragInput = Input
            end
        end))
        self.Trove:Add(UserInputService.InputChanged:Connect(function(Input)
            if not (Input == Data.DragInput and Data.Dragging and Data.MousePosition and Data.StartPosition) then
                return
            end

            local Delta = Input.Position - Data.MousePosition
            Data.SetPosition(
                UDim2.fromOffset(Data.StartPosition.X.Offset + Delta.X, Data.StartPosition.Y.Offset + Delta.Y)
            )
        end))
    end

    --[=[
        Create the resizer
    ]=]
    function DraggerResizer.CreateResizer(self: DraggerResizer)
        if self.Mode.Mode == "Drag" then
            return
        end
        local Data = self.Mode.Data

        self.Trove:Add(Data.ResizeFrame.InputBegan:Connect(function(Input)
            if
                Input.UserInputType == Enum.UserInputType.MouseMovement
                or Input.UserInputType == Enum.UserInputType.Touch
            then
                Data.Resizing = true
                Data.ResizePosition = Input.Position
            end
        end))
        self.Trove:Add(UserInputService.InputChanged:Connect(function(Input)
            if
                not (
                    (
                        Input.UserInputType == Enum.UserInputType.MouseMovement
                        or Input.UserInputType == Enum.UserInputType.Touch
                    ) and Data.Resizing
                )
            then
                return
            end

            local Delta = Input.Position - Data.ResizePosition
            local StartSize = Data.GetStartSize()

            local TargetSize = Vector3.new(StartSize.X.Offset, StartSize.Y.Offset, 0) + Vector3.new(1, 1, 0) * Delta
            local MinSize = Data.GetMinSize()
            local TargetSizeClamped =
                Vector2.new(math.clamp(TargetSize.X, MinSize.X, 2048), math.clamp(TargetSize.Y, MinSize.Y, 2048))
            Data.SizeMotor:setGoal({
                X = Flipper.Instant.new(TargetSizeClamped.X),
                Y = Flipper.Instant.new(TargetSizeClamped.Y),
            })
        end))
        self.Trove:Add(UserInputService.InputEnded:Connect(function(Input)
            if Data.Resizing or Input.UserInputType == Enum.UserInputType.Touch then
                Data.Resizing = false
                Data.SetSize(UDim2.fromOffset(Data.SizeMotor:getValue().X, Data.SizeMotor:getValue().Y))
            end
        end))
    end

    --[=[
        Create the connections
    ]=]
    function DraggerResizer.CreateConnections(self: DraggerResizer)
        self:CreateDragger()
        self:CreateResizer()
    end
end
return DraggerResizer
