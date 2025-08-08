-- // Dependencies
local Flipper = require("@pkgs/flipper")
local Signal = require("@pkgs/signal")
local Trove = require("@pkgs/trove")
local AcrylicPaint = require("@modules/acrylic/paint")
local TitleBar = require("@elements/titlebar")
local Create = require("@functions/create")
local GetOS = require("@functions/get_os")

-- // Services
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- // Types
type Signal<T...> = Signal.Signal<T...>
export type WindowDataMobile = {
    Size: UDim2,
    GetIcon: (
        Name: string?
    ) -> {
        Image: string,
        ImageRectSize: Vector2,
        ImageRectOffset: Vector2,
    },
}
export type WindowConstructorData = {
    Parent: Instance,
    MinSize: UDim2,
    Size: UDim2,
    TabWidth: number,
    Mobile: WindowDataMobile,
}
export type WindowDataInstances = {
    Selector: Frame,
    ResizeStartFrame: Frame,
    TabHolder: ScrollingFrame,
    TabHolderUIListLayout: UIListLayout,
    TabFrame: Frame,
    TabDisplay: TextLabel,
    ContainerHolder: Frame,
    ContainerAnim: CanvasGroup,
    ContainerCanvas: Frame,
    Root: Frame,
    HideButton: ImageButton,
    TitleBar: TitleBar.TitleBar,
}
export type WindowDataMotors = {
    Size: typeof(Flipper.GroupMotor.new({ X = 0, Y = 0 })),
    Position: typeof(Flipper.GroupMotor.new({ X = 0, Y = 0 })),
    SelectorPosition: typeof(Flipper.SingleMotor.new(1)),
    SelectorSize: typeof(Flipper.SingleMotor.new(1)),
    ContainerBack: typeof(Flipper.SingleMotor.new(1)),
    ContainerPosition: typeof(Flipper.SingleMotor.new(1)),
}
export type WindowData = {
    Trove: Trove.Trove,

    MinimiseNotif: boolean,
    Minimised: boolean,
    Maximised: boolean,

    OldSize: Vector2,

    MinSize: UDim2,
    Size: UDim2,

    Position: UDim2,
    CurrentPosition: UDim2,

    TabWidth: number,

    AcrylicPaint: AcrylicPaint.AcrylicPaint,
    Instances: WindowDataInstances,
    Motors: WindowDataMotors,
    Mobile: WindowDataMobile,

    OnMinimised: Signal<number, boolean>,
    PostMinimised: Signal<number, boolean>,
    OnMaximised: Signal<number>,
    PostMaximised: Signal<number>,
}

-- //
local Window = {}
Window.__index = Window
export type Window = typeof(setmetatable({} :: WindowData, Window))
do
    --[=[
        Create a new [Window] object.
    ]=]
    function Window.new(Data: WindowConstructorData): Window
        -- // Create the object
        local self = setmetatable({}, Window)

        -- // Set
        self.Trove = Trove.new()
        self.MinimiseNotif = false
        self.Minimised = false
        self.Maximised = false

        self.MinSize = Data.MinSize
        self.Size = Data.Size

        local CurrentCamera = Workspace.CurrentCamera
        local HalfViewportSize = CurrentCamera.ViewportSize / 2
        self.Position =
            UDim2.fromOffset(HalfViewportSize.X - self.Size.X.Offset / 2, HalfViewportSize.Y - self.Size.Y.Offset)
        self.CurrentPosition = UDim2.new()

        self.TabWidth = Data.TabWidth
        self.AcrylicPaint = AcrylicPaint.new()
        self.Instances =
            self:CreateInstances(self.TabWidth, self.Size, self.Position, Data.Parent, Data.Mobile, self.AcrylicPaint)
        self.Motors = self.CreateMotors(self.Size, self.Position)
        self.Mobile = Data.Mobile

        self.OldSize = Vector2.new(self.Size.X.Offset, self.Size.Y.Offset)

        self.OnMinimised = Signal.new()
        self.PostMinimised = Signal.new()
        self.OnMaximised = Signal.new()
        self.PostMaximised = Signal.new()

        -- // Return the object
        self:CreateConnections()
        return self
    end

    --[=[
        Create all of the required instances
    ]=]
    function Window.CreateInstances(
        self: any,
        TabWidth: number,
        Size: UDim2,
        Position: UDim2,
        Parent: Instance,
        Mobile: WindowDataMobile,
        AcrylicPaintObject: AcrylicPaint.AcrylicPaint
    ): WindowDataInstances
        local Selector = Create("Frame", {
            Size = UDim2.fromOffset(4, 0),
            BackgroundColor3 = Color3.fromRGB(76, 194, 255),
            Position = UDim2.fromOffset(0, 17),
            AnchorPoint = Vector2.new(0, 0.5),
            ThemeTag = {
                BackgroundColor3 = "Accent",
            },
        }, {
            Create("UICorner", {
                CornerRadius = UDim.new(0, 2),
            }),
        }) :: Frame

        local ResizeStartFrame = Create("Frame", {
            Size = UDim2.fromOffset(20, 20),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -20, 1, -20),
        }) :: Frame

        local TabHolderUIListLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 4),
        }) :: UIListLayout
        local TabHolder = Create("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            ScrollBarImageTransparency = 1,
            ScrollBarThickness = 0,
            BorderSizePixel = 0,
            CanvasSize = UDim2.fromScale(0, 0),
            ScrollingDirection = Enum.ScrollingDirection.Y,
        }, { TabHolderUIListLayout }) :: ScrollingFrame

        local TabFrame = Create("Frame", {
            Size = UDim2.new(0, TabWidth, 1, -66),
            Position = UDim2.fromOffset(12, 54),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
        }, {
            TabHolder,
            Selector,
        }) :: Frame

        local TabDisplay = Create("TextLabel", {
            RichText = true,
            Text = "Tab",
            TextTransparency = 0,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            TextSize = 28,
            TextXAlignment = "Left",
            TextYAlignment = "Center",
            Size = UDim2.new(1, -16, 0, 28),
            Position = UDim2.fromOffset(TabWidth + 26, 56),
            BackgroundTransparency = 1,
            ThemeTag = {
                TextColor3 = "Text",
            },
        }) :: TextLabel

        local ContainerHolder = Create("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
        }) :: Frame

        local ContainerAnim = Create("CanvasGroup", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
        }) :: CanvasGroup

        local ContainerCanvas = Create("Frame", {
            Size = UDim2.new(1, -TabWidth - 32, 1, -102),
            Position = UDim2.fromOffset(TabWidth + 26, 90),
            BackgroundTransparency = 1,
        }, {
            ContainerAnim,
            ContainerHolder,
        }) :: Frame

        local Root = Create("Frame", {
            BackgroundTransparency = 1,
            Size = Size,
            Position = Position,
            Parent = Parent,
        }, {
            AcrylicPaintObject.Frame,
            TabDisplay,
            ContainerCanvas,
            TabFrame,
            ResizeStartFrame,
        }) :: Frame

        local HideButton = Create("ImageButton", {
            Visible = GetOS() == "Mobile",
            Size = Mobile.Size,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -Mobile.Size.X.Offset - 25, 0.5, -Mobile.Size.Y.Offset / 2),
            Parent = Parent,
            Image = Mobile.GetIcon().Image,
            ImageRectOffset = Mobile.GetIcon().ImageRectOffset,
            ImageRectSize = Mobile.GetIcon().ImageRectSize,
        }) :: ImageButton

        local TitleBarInstance = TitleBar.new({
            Title = "",
            SubTitle = "",
            Parent = Root,
            Window = self,
        })

        -- //
        return {
            Selector = Selector,
            ResizeStartFrame = ResizeStartFrame,
            TabHolder = TabHolder,
            TabHolderUIListLayout = TabHolderUIListLayout,
            TabFrame = TabFrame,
            TabDisplay = TabDisplay,
            ContainerHolder = ContainerHolder,
            ContainerAnim = ContainerAnim,
            ContainerCanvas = ContainerCanvas,
            Root = Root,
            HideButton = HideButton,
            TitleBar = TitleBarInstance,
        }
    end

    --[=[
        Create the motors
    ]=]
    function Window.CreateMotors(Size: UDim2, Position: UDim2): WindowDataMotors
        return {
            Size = Flipper.GroupMotor.new({
                X = Size.X.Offset,
                Y = Size.Y.Offset,
            }),
            Position = Flipper.GroupMotor.new({
                X = Position.X.Offset,
                Y = Position.Y.Offset,
            }),
            SelectorPosition = Flipper.SingleMotor.new(17),
            SelectorSize = Flipper.SingleMotor.new(0),
            ContainerBack = Flipper.SingleMotor.new(0),
            ContainerPosition = Flipper.SingleMotor.new(94),
        }
    end

    --[=[
        Initialise all of the connections
    ]=]
    function Window.CreateConnections(self: Window)
        self.Trove:Add(self.Motors.Size:onStep(function(Values: Vector2)
            self.Instances.Root.Size = UDim2.fromOffset(Values.X, Values.Y)
        end))
        self.Trove:Add(self.Motors.Position:onStep(function(Values: Vector2)
            self.Instances.Root.Position = UDim2.fromOffset(Values.X, Values.Y)
        end))
        self.Trove:Add(self.Motors.SelectorSize:onStep(function(Value: number)
            self.Instances.Selector.Size = UDim2.fromOffset(4, Value)
        end))
        self.Trove:Add(self.Motors.ContainerBack:onStep(function(Value: number)
            self.Instances.ContainerAnim.GroupTransparency = Value
        end))
        self.Trove:Add(self.Motors.ContainerPosition:onStep(function(Value: number)
            self.Instances.ContainerAnim.Position = UDim2.fromOffset(0, Value)
        end))
        self.Trove:Add(
            self.Instances.TabHolderUIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                local TabHolder = self.Instances.TabHolder
                local TabHolderUIListLayout = self.Instances.TabHolderUIListLayout
                if TabHolder.CanvasSize ~= UDim2.fromOffset(0, TabHolderUIListLayout.AbsoluteContentSize.Y) then
                    TabHolder.CanvasSize = UDim2.fromOffset(0, TabHolderUIListLayout.AbsoluteContentSize.Y)
                end
            end)
        )
        self.Trove:Add(UserInputService.InputBegan:Connect(function(Input)
            -- if
            --     type(Library.MinimizeKeybind) == "table"
            --     and Library.MinimizeKeybind.Type == "Keybind"
            --     and not UserInputService:GetFocusedTextBox()
            -- then
            --     if Input.KeyCode.Name == Library.MinimizeKeybind.Value or Input.KeyCode.Name == Library.MinimizeKeybind.Value.Name then
            --         Window:Minimize()
            --     end
            -- elseif (Input.KeyCode == Library.MinimizeKey or Input.KeyCode.Name == Library.MinimizeKey) and not UserInputService:GetFocusedTextBox() then
            --     Window:Minimize()
            -- end
        end))

        if GetOS() == "Mobile" then
            local HideButton = self.Instances.HideButton
            Trove:Add(HideButton.TouchTap:Connect(function()
                self.Minimised = not self.Minimised
                self.Instances.Root.Visible = self.Minimised

                local Icon = self.Mobile.GetIcon(self.Minimised)
                HideButton.Image = Icon.Image
                HideButton.ImageRectOffset = Icon.ImageRectOffset
                HideButton.ImageRectSize = Icon.ImageRectSize
            end))
        else
            Trove:Add(self.Instances.HideButton.MouseButton1Click:Connect(function()
                self.Minimised = not self.Minimised
                self.Instances.Root.Visible = self.Minimised
            end))
        end

        do
            local LastValue = 0
            local LastTime = 0

            self.Trove:Add(self.Motors.SelectorPosition:onStep(function(Value: number)
                self.Instances.Selector.Position = UDim2.fromOffset(0, Value + 17)
                local Now = tick()
                local DeltaTime = Now - LastTime

                self.Motors.SelectorSize:setGoal(
                    Flipper.Spring.new((math.abs(Value - LastValue) / (DeltaTime * 60)) + 16)
                )
                LastValue = Value
                LastTime = Now
            end))
        end
    end

    --[=[
        Set the maximised state
    ]=]
    function Window.Maximise(self: Window, Value: boolean, NoPos: boolean?, Instant: boolean?)
        self.OnMaximised:fire(tick())

        self.Maximised = Value
        -- self.Instances.TitleBar.MaxButton.Instances.Frame.Icon.Image

        if Value then
            self.OldSize = Vector2.new(self.Size.X.Offset, self.Size.Y.Offset)
        end

        local CurrentCamera = Workspace.CurrentCamera
        local SizeX = Value and CurrentCamera.ViewportSize.X or self.OldSize.X
        local SizeY = Value and CurrentCamera.ViewportSize.Y or self.OldSize.Y

        local FlipperType = Flipper[Instant and "Instant" or "Spring"]
        self.Motors.Size:setGoal({
            X = FlipperType.new(SizeX, { frequency = 6 }),
            Y = FlipperType.new(SizeY, { frequency = 6 }),
        })
        self.Size = UDim2.fromOffset(SizeX, SizeY)

        if NoPos then
            self.Motors.Position:setGoal({
                X = Flipper.Spring.new(Value and 0 or self.Position.X.Offset, { frequency = 6 }),
                Y = Flipper.Spring.new(Value and 0 or self.Position.Y.Offset, { frequency = 6 }),
            })
        end

        self.PostMaximised:fire(tick())
    end

    --[=[
        Toggle the maximised state
    ]=]
    function Window.ToggleMaximised(self: Window, NoPos: boolean?, Instant: boolean?)
        self:Maximise(not self.Maximised, NoPos, Instant)
    end

    --[=[
        Minimise the window
    ]=]
    function Window.Minimise(self: Window)
        self.Minimised = not self.Minimised
        self.Instances.Root.Visible = not self.Minimised

        self.OnMinimised:fire(tick(), self.Instances.Root.Visible)

        if not self.MinimiseNotif then
            -- TODO: the commented out stuff
            -- local Key = Library.MinimizeKeybind and Library.MinimizeKeybind.Value or typeof(Library.MinimizeKey) == "string" and Library.MinimizeKey or Library.MinimizeKey.Name
            self.MinimiseNotif = true

            -- Library:Notify({
            -- 	Title = "Interface",
            -- 	Content = `Press {Library.Utilities:Prettify(Key)} to toggle the interface.`,
            -- 	Duration = 6
            -- })
        end

        if GetOS() == "Mobile" then
            local Icon = self.Mobile:GetIcon(tostring(self.Minimised)) -- TODO: fix this
            self.Instances.HideButton.Image = Icon.Image
            self.Instances.HideButton.ImageRectOffset = Icon.ImageRectOffset
            self.Instances.HideButton.ImageRectSize = Icon.ImageRectSize
        end

        self.PostMinimised:fire(tick(), self.Instances.Root.Visible)
    end
end

return Window
