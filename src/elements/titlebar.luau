-- // Dependencies
local Create = require("@functions/create")
local BarButton = require("@elements/barbutton")

-- // Services

-- // Types
export type TitleBarDataWindow = {
    Maximised: boolean,
    ToggleMaximised: (self: any) -> (),
    Minimise: (self: any) -> (),
}
export type TitleBarConstructorData = {
    Parent: Instance,
    Title: string,
    SubTitle: string,

    Window: TitleBarDataWindow,
}
export type TitleBarDataInstances = {
    Frame: Frame,
    TitleHolder: Frame,
    Title: TextLabel,
    SubTitle: TextLabel,
}
export type TitleBarData = {
    Instances: TitleBarDataInstances,
    Window: TitleBarDataWindow,
    CloseButton: BarButton.BarButton,
    MaxButton: BarButton.BarButton,
    MinButton: BarButton.BarButton,
}

-- //
local TitleBar = {}
TitleBar.__index = TitleBar
export type TitleBar = typeof(setmetatable({} :: TitleBarData, TitleBar))
do
    --[=[
        Create a new [TitleBar] object.
    ]=]
    function TitleBar.new(Data: TitleBarConstructorData): TitleBar
        -- // Create the object
        local self = setmetatable({}, TitleBar)

        -- // Set
        self.Window = Data.Window
        self.Instances = TitleBar.CreateInstances(Data.Parent, Data.Title, Data.SubTitle)
        self.CloseButton = BarButton.new({
            Icon = "", -- TODO: Icons
            Position = UDim2.new(1, -4, 0, 4),
            Parent = self.Instances.Frame,
            DebounceTime = 0,
            Callback = function()
                -- TODO: https://github.com/ActualMasterOogway/Fluent-Renewed/blob/b224870c30ee1d6fa6fcd816e8c30256f86e1d20/Src/Components/TitleBar.luau#L144
            end,
        })
        self.MaxButton = BarButton.new({
            Icon = "", -- TODO: Icons
            Position = UDim2.new(1, -40, 0, 4),
            Parent = self.Instances.Frame,
            DebounceTime = 0,
            Callback = function()
                self.Window:ToggleMaximised()
            end,
        })
        self.MinButton = BarButton.new({
            Icon = "", -- TODO: Icons
            Position = UDim2.new(1, -80, 0, 4),
            Parent = self.Instances.Frame,
            DebounceTime = 0,
            Callback = function()
                self.Window:Minimise()
            end,
        })

        -- // Return the object
        return self
    end

    --[=[
        Destroy this instance and clean up.
    ]=]
    function TitleBar.Destroy(self: TitleBar)
        self.CloseButton:Destroy()
        self.MaxButton:Destroy()
        self.MaxButton:Destroy()
        setmetatable(self :: any, nil)
    end

    --[=[
        Create the instances
    ]=]
    function TitleBar.CreateInstances(Parent: Instance, TitleText: string, SubTitleText: string): TitleBarDataInstances
        local Frame = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundTransparency = 1,
            Parent = Parent,
        }, {
            Create("Frame", {
                BackgroundTransparency = 0.5,
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.fromScale(0, 1),
                ThemeTag = {
                    BackgroundColor3 = "TitleBarLine",
                },
            }),
        }) :: Frame

        local TitleHolder = Create("Frame", {
            Size = UDim2.new(1, -16, 1, 0),
            Parent = Frame,
            Position = UDim2.fromOffset(16, 0),
            BackgroundTransparency = 1,
        }, {
            Create("UIListLayout", {
                Padding = UDim.new(0, 5),
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        }) :: Frame

        local Title = Create("TextLabel", {
            RichText = true,
            Text = TitleText,
            Parent = TitleHolder,
            FontFace = Font.new(
                "rbxasset://fonts/families/GothamSSm.json",
                Enum.FontWeight.Regular,
                Enum.FontStyle.Normal
            ),
            TextSize = 12,
            TextXAlignment = "Left",
            TextYAlignment = "Center",
            Size = UDim2.fromScale(0, 1),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            ThemeTag = {
                TextColor3 = "Text",
            },
        }) :: TextLabel

        local SubTitle = Create("TextLabel", {
            RichText = true,
            Text = SubTitleText,
            Parent = TitleHolder,
            TextTransparency = 0.4,
            FontFace = Font.new(
                "rbxasset://fonts/families/GothamSSm.json",
                Enum.FontWeight.Regular,
                Enum.FontStyle.Normal
            ),
            TextSize = 12,
            TextXAlignment = "Left",
            TextYAlignment = "Center",
            Size = UDim2.fromScale(0, 1),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            ThemeTag = {
                TextColor3 = "Text",
            },
        }) :: TextLabel

        return {
            Frame = Frame,
            TitleHolder = TitleHolder,
            Title = Title,
            SubTitle = SubTitle,
        }
    end
end
return TitleBar
