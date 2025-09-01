-- // Dependencies
local Trove = require("@pkgs/trove")
local Create = require("@functions/create")
local Flipper = require("@pkgs/flipper")
local Button = require("@elements/button")

-- // Types
export type DialogDataInstances = {
    TintFrame: TextButton,
    ButtonHolder: Frame,
    ButtonHolderFrame: Frame,
    Title: TextLabel,
    Scale: UIScale,
    RootStroke: UIStroke,
    Root: CanvasGroup,
}
export type DialogDataMotors = {
    Tint: typeof(Flipper.SpringMotor.new(1)),
    Scale: typeof(Flipper.SpringMotor.new(1)),
    Root: typeof(Flipper.SpringMotor.new(1))
}
export type DialogData = {
    Trove: Trove.Trove,
    Instances: DialogDataInstances,
    Motors: DialogDataMotors
}

-- //
local Dialog = {}
Dialog.__index = Dialog
export type Dialog = typeof(setmetatable({} :: DialogData, Dialog))
do
    --[=[
        Create a new [Dialog] object.
    ]=]
    function Dialog.new(Container: GuiObject): Dialog
        -- // Create the object
        local self = setmetatable({}, Dialog)

        -- // Set
        self.Trove = Trove.new()
        self.Instances = self.CreateInstances(Container)
        self.Motors = self.CreateMotors(self.Instances)

        -- // Return the object
        return self
    end

    --[=[
        Create all of the requires instances
    ]=]
    function Dialog.CreateInstances(Container: GuiObject): DialogDataInstances
        local TintFrame = Create("TextButton", {
            Text = "",
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            Parent = Container
        }, {
            Create("UICorner", {
                CornerRadius = UDim.new(0, 8),
            }),
        }) :: TextButton
        local ButtonHolder = Create("Frame", {
            Size = UDim2.new(1, -40, 1, -40),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            BackgroundTransparency = 1,
        }, {
            -- if you add more children, update the count at the next comment labelled `BUTTON_COUNT`
            Create("UIListLayout", {
                Padding = UDim.new(0, 10),
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        }) :: Frame
        local ButtonHolderFrame = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 70),
            Position = UDim2.new(0, 0, 1, -70),
            ThemeTag = {
                BackgroundColor3 = "DialogHolder",
            },
        }, {
            Create("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                ThemeTag = {
                    BackgroundColor3 = "DialogHolderLine",
                },
            }),
            ButtonHolder,
        }) :: Frame
        local Title = Create("TextLabel", {
            FontFace = Font.new(
                "rbxasset://fonts/families/GothamSSm.json",
                Enum.FontWeight.SemiBold,
                Enum.FontStyle.Normal
            ),
            Text = "Dialog",
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextSize = 22,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 0, 22),
            Position = UDim2.fromOffset(20, 25),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            ThemeTag = {
                TextColor3 = "Text",
            },
        }) :: TextLabel
        local Scale = Create("UIScale", {
            Scale = 1,
        }) :: UIScale
        local RootStroke =  Create("UIStroke", {
            Transparency = 0.5,
            ThemeTag = {
                Color = "DialogBorder",
            },
        }) :: UIStroke
        local Root = Create("CanvasGroup", {
            Size = UDim2.fromOffset(300, 165),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            GroupTransparency = 1,
            Parent = TintFrame,
            ThemeTag = {
                BackgroundColor3 = "Dialog",
            },
        }, {
            Create("UICorner", {
                CornerRadius = UDim.new(0, 8),
            }),
            RootStroke,
            Scale,
            Title,
            ButtonHolderFrame,
        }) :: CanvasGroup

        return {
            TintFrame = TintFrame,
            ButtonHolder = ButtonHolder,
            ButtonHolderFrame = ButtonHolderFrame,
            Title = Title,
            Scale = Scale,
            RootStroke = RootStroke,
            Root = Root,
        }
    end

    --[=[
        Create the motors
    ]=]
    function Dialog.CreateMotors(Instances: DialogDataInstances): DialogDataMotors
        local Tint = Flipper.SpringMotor(1, Instances.TintFrame, "BackgroundTransparency", true)
        local Scale = Flipper.SpringMotor(1.1, Instances.Scale, "Scale")
        local Root = Flipper.SpringMotor(1, Instances.Root, "GroupTransparency")

        return {
            Tint = Tint,
            Scale = Scale,
            Root = Root,
        }
    end

    --[=[
        Open the dialog
    ]=]
    function Dialog.Open(self: Dialog)
        self.Instances.Scale.Scale = 1.1
        self.Motors.Tint[2](0.75)
        self.Motors.Root[2](0)
        self.Motors.Scale[2](1)
    end

    --[=[
        Close the dialog, this is the same as destroying the object.
    ]=]
    function Dialog.Close(self: Dialog)
        self.Trove:Destroy()

        self.Motors.Tint[2](1)
        self.Motors.Root[2](1)
        self.Motors.Scale[2](1.1)
        self.Instances.RootStroke:Destroy()

        task.wait(0.15)
        self.Instances.TintFrame:Destroy()
        setmetatable(self :: any, nil)
    end
    Dialog.Destroy = Dialog.Close

    --[=[
        Add a button to the dialog.
    ]=]
    function Dialog.AddButton(self: Dialog, Title: string, Callback: () -> ())
        self.Trove:Add(Button.new({
            Container = self.Instances.ButtonHolder,
            DialogCheck = true,
            Title = Title,
            Callback = function()
                Callback()
                self:Close()
            end
        }))
        
        -- // Re-align things
        local ButtonHolderChildren = self.Instances.ButtonHolder:GetChildren()
        local Buttons = #ButtonHolderChildren - 1 -- BUTTON_COUNT
        for _, v in ButtonHolderChildren do
            if v:IsA("TextBox") then
                v.Size = UDim2.new(1 / Buttons, -((Buttons - 1) * 10 / Buttons), 0, 32)
            end
        end
    end
end
return Dialog
