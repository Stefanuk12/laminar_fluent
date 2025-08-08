-- // Dependencies
local Trove = require("@pkgs/trove")
local Create = require("@functions/create")
local InstanceTracker = require("@modules/instance_tracker")

-- // Types
export type BarButtonConstructorData = {
    Icon: string,
    Position: UDim2,
    Parent: Instance,
    DebounceTime: number,
    Callback: ((...any) -> ())?,
}
export type BarButtonDataInstances = {
    Frame: Frame,
}
export type BarButtonDataMotors = {
    FrameTransparency: typeof(InstanceTracker:CreateMotor(false :: any, false :: any, false :: any)),
}
export type BarButtonData = {
    Trove: Trove.Trove,
    Instances: BarButtonDataInstances,
    Motors: BarButtonDataMotors,
    Debounce: boolean,
    Callback: (...any) -> (),
}

-- //
local BarButton = {}
BarButton.__index = BarButton
export type BarButton = typeof(setmetatable({} :: BarButtonData, BarButton))
do
    --[=[
        Create a new [BarButton] object.
    ]=]
    function BarButton.new(Data: BarButtonConstructorData): BarButton
        -- // Create the object
        local self = setmetatable({}, BarButton)

        -- // Set
        self.Trove = Trove.new()
        self.Debounce = false
        self.Callback = Data.Callback or function() end
        self.Instances = self.CreateInstances(Data.Parent, Data.Position, Data.Icon)
        self.Motors = {
            FrameTransparency = self.CreateMotors(self.Instances.Frame),
        }

        -- // Return the object
        self:CreateConnections(Data.DebounceTime)
        return self
    end

    --[=[
        Destroy this object and cleanup
    ]=]
    function BarButton.Destroy(self: BarButton)
        self.Trove:Destroy()
        setmetatable(self :: any, nil)
    end

    --[=[
        Create the instances
    ]=]
    function BarButton.CreateInstances(Parent: Instance, Position: UDim2, Icon: string): BarButtonDataInstances
        local Frame = Create("TextButton", {
            Size = UDim2.new(0, 34, 1, -8),
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Parent = Parent,
            Position = Position,
            Text = "",
            ThemeTag = {
                BackgroundColor3 = "Text",
            },
        }, {
            Create("UICorner", {
                CornerRadius = UDim.new(0, 7),
            }),
            Create("ImageLabel", {
                Image = Icon,
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.fromScale(0.5, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Name = "Icon",
                ThemeTag = {
                    ImageColor3 = "Text",
                },
            }),
        }) :: Frame

        return {
            Frame = Frame,
        }
    end

    --[=[
        Create the motors.
    ]=]
    function BarButton.CreateMotors(Frame: Frame)
        return InstanceTracker:CreateMotor(Frame, "BackgroundTransparency", 1)
    end

    --[=[
        Create the connections.
    ]=]
    function BarButton.CreateConnections(self: BarButton, DebounceTime: number)
        local SetTransparency = self.Motors.FrameTransparency.Setter

        self.Trove:Add(self.Instances.Frame.MouseEnter:Connect(function()
            SetTransparency(0.94)
        end))
        self.Trove:Add(self.Instances.Frame.MouseLeave:Connect(function()
            SetTransparency(1, true)
        end))
        self.Trove:Add((self.Instances.Frame :: any).MouseButton1Down:Connect(function()
            SetTransparency(0.96)
        end))
        self.Trove:Add((self.Instances.Frame :: any).MouseButton1Up:Connect(function()
            SetTransparency(0.94)
        end))
        self.Trove:Add((self.Instances.Frame :: any).MouseButton1Click:Connect(function(...)
            if self.Debounce then
                return
            end
            self.Debounce = true
            task.delay(DebounceTime, function()
                self.Debounce = false
            end)
            self.Callback(...)
        end))
    end
end
return BarButton
