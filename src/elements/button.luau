-- // Dependencies
local Trove = require("@pkgs/trove")
local Create = require("@functions/create")
local Flipper = require("@pkgs/flipper")

-- // Types
export type ButtonDataInstances = {
    [string]: GuiObject,

    Title: TextLabel,
    HoverFrame: Frame,
    Frame: TextButton,
}
export type ButtonDataMotors = {
    [string]: typeof(Flipper.SpringMotor.new(1)),

    HoverFrame: typeof(Flipper.SpringMotor.new(1)),
}
export type ButtonConstructorData = {
    Container: GuiObject,
    DialogCheck: boolean,

    Title: string,
    Callback: (() -> ())?,
}
export type ButtonData = {
    Trove: Trove.Trove,
    Instances: ButtonDataInstances,
    Motors: ButtonDataMotors
}

-- //
local Button = {}
Button.__index = Button
export type Button = typeof(setmetatable({} :: ButtonData, Button))
do
    --[=[
        Create a new [Button] object.
    ]=]
    function Button.new(Data: ButtonConstructorData): Button
        -- // Create the object
        local self = setmetatable({}, Button)

        -- // Set
        self.Trove = Trove.new()
        self.Instances = self.CreateInstances(Data.Container, Data.Title)
        self.Motors = self.CreateMotors(self.Instances, Data.DialogCheck)

        -- // Return the object
        self:CreateConnections(Data.Callback)
        return self
    end

    --[=[
        Destroys this object.
    ]=]
    function Button.Destroy(self: Button)
        self.Trove:Destroy()
        for _, v in self.Instances do
            v:Destroy()
        end
        for _, v in self.Motors do
            v:Destroy()
        end
        setmetatable(self :: any, {})
    end

    --[=[
        Create all of the requires instances
    ]=]
    function Button.CreateInstances(Container: GuiObject, Text: string?): ButtonDataInstances
        local Title = Create("TextLabel", {
            Text = Text or "",
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 14,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            ThemeTag = {
                TextColor3 = "Text",
            },
        }) :: TextLabel

        local HoverFrame = Create("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            ThemeTag = {
                BackgroundColor3 = "Hover",
            },
        }, {
            Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
            }),
        }) :: Frame

        local Frame = Create("TextButton", {
            Size = UDim2.fromOffset(0, 32),
            Parent = Container,
            ThemeTag = {
                BackgroundColor3 = "DialogButton",
            },
        }, {
            Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
            }),
            Create("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Transparency = 0.65,
                ThemeTag = {
                    Color = "DialogButtonBorder",
                },
            }),
            HoverFrame,
            Title,
        }) :: TextButton

        return {
            Title = Title,
            HoverFrame = HoverFrame,
            Frame = Frame,
        }
    end

    --[=[
        Create the motors
    ]=]
    function Button.CreateMotors(Instances: ButtonDataInstances, DialogCheck: boolean): ButtonDataMotors
        local HoverFrame = Flipper.SpringMotor(1, Instances.HoverFrame, "BackgroundTransparency", DialogCheck)

        return {
            HoverFrame = HoverFrame,
        }
    end

    --[=[
        Create the connections
    ]=]
    function Button.CreateConnections(self: Button, Callback: (() -> ())?)
        local TroveObject = self.Trove
        local Frame = self.Instances.Frame
        local SetTransparency = self.Motors.HoverFrame[2]

        TroveObject:Add(Frame.MouseEnter:Connect(function()
            SetTransparency(0.97)
        end))
        TroveObject:Add(Frame.MouseLeave:Connect(function()
            SetTransparency(1)
        end))
        TroveObject:Add(Frame.MouseButton1Down:Connect(function()
            SetTransparency(1)
        end))
        TroveObject:Add(Frame.MouseButton1Up:Connect(function()
            SetTransparency(0.97)
        end))
        
        if Callback then
            TroveObject:Add(Frame.MouseButton1Click:Connect(function()
                Callback()
            end))
        end
    end
end
return Button
