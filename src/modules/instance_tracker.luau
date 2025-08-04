-- // Dependencies
local DefaultProperties = require("@config/default_properties")
local Themes = require("@config/themes")
local Flipper = require("@pkgs/flipper")
local SharedState = require("@shared/state")

-- // Types
export type ThemedInstanceProperties = {
    -- Property: Identifier
    [string]: string,
}
export type InstanceTrackerData = {
    Motors: { typeof(Flipper.SingleMotor.new(1)) },
    Theme: Themes.Theme,
    ThemedInstances: { [Instance]: ThemedInstanceProperties },
}

--[=[
    @class InstanceTracker

    Tracks UI instances, handling cleanup of elements and updating.
]=]
local InstanceTracker = {}
InstanceTracker.__index = InstanceTracker
export type InstanceTracker = typeof(setmetatable({} :: InstanceTrackerData, InstanceTracker))
do
    --[=[
        Create a new [InstanceTracker]
    ]=]
    function InstanceTracker.new(): InstanceTracker
        -- // Create the object
        local self = setmetatable({}, InstanceTracker)

        -- // Set
        self.Motors = {}
        self.Theme = "Dark"
        self.ThemedInstances = {}

        -- // Return the object
        return self
    end

    --[=[
        Destroy this object.
    ]=]
    function InstanceTracker.Destory(self: InstanceTracker)
        table.clear(self.Motors)
        table.clear(self.ThemedInstances)
        setmetatable(self :: any, nil)
    end

    --[=[
        Grab a themed property value
        
        @param Property -- The themed property name, **not** the actual instance property name
    ]=]
    function InstanceTracker.GetThemeProperty(self: InstanceTracker, Property: string)
        return Themes[self.Theme][Property] or Themes.Dark[Property]
    end

    --[=[
        Sets all themed properties of the `Instance`.
        View [InstanceTracker.GetThemeProperty] for more information on what a themed property is.
    ]=]
    function InstanceTracker.SetThemedInstanceProperties(
        self: InstanceTracker,
        Instance: Instance,
        Properties: ThemedInstanceProperties
    )
        for property, identitfier in Properties do
            (Instance :: any)[property] = self:GetThemeProperty(identitfier)
        end
    end

    --[=[
        Start tracking an instance with themed properties.
        View [InstanceTracker.GetThemeProperty] for more information on what a themed property is.
    ]=]
    function InstanceTracker.TrackThemedInstance(
        self: InstanceTracker,
        Instance: Instance,
        Properties: ThemedInstanceProperties
    )
        self.ThemedInstances[Instance] = Properties
        self:SetThemedInstanceProperties(Instance, Properties)
    end

    --[=[
        Update all tracked themed instances and motors.
    ]=]
    function InstanceTracker.UpdateThemedInstances(self: InstanceTracker)
        for object, properties in self.ThemedInstances do
            self:SetThemedInstanceProperties(object, properties)
        end

        for _, motor in self.Motors do
            motor:setGoal(Flipper.Instant.new(self:GetThemeProperty("ElementTransparency")))
        end
    end

    --[=[
        Create a new motor, and track it.
        A motor is used to help tween certain properties like transparency.
    ]=]
    function InstanceTracker.CreateMotor(
        self: InstanceTracker,
        Instance: Instance,
        Property: string,
        InitialValue: any,
        IgnoreDialogCheck: boolean?,
        ResetOnThemeChange: boolean?
    )
        Instance = Instance :: any
        IgnoreDialogCheck = IgnoreDialogCheck or false
        ResetOnThemeChange = ResetOnThemeChange or false
        local Motor = Flipper.SingleMotor.new(InitialValue)
        Motor:onStep(function(value)
            Instance[Property] = value
        end)

        if ResetOnThemeChange then
            table.insert(self.Motors, Motor)
        end

        local function SetValue(Value, Ignore: boolean?)
            Ignore = Ignore or false
            if
                not IgnoreDialogCheck
                and not Ignore
                and Property == "BackgroundTransparency"
                and SharedState.DialogOpen
            then
                return
            end
            Motor:setGoal(Flipper.Spring.new(Value, { frequency = 8 }))
        end

        return Motor, SetValue
    end

    --[=[
        Create a new UI element.
    ]=]
    function InstanceTracker.Create(
        self: InstanceTracker,
        InstanceType: string,
        Properties: { [string]: any }?,
        Children: { Instance }?
    ): Instance
        local Object = Instance.new(InstanceType) :: any

        for i, v in (DefaultProperties[InstanceType] or {}) do
            Object[i] = v
        end

        Properties = Properties or {}
        for i, v in (Properties or {}) do
            if i ~= "ThemeTag" then
                Object[i] = v
            else
                self:TrackThemedInstance(Object, Properties)
            end
        end

        for _, v in (Children or {}) do
            v.Parent = Object
        end

        return Object
    end
end
return InstanceTracker.new()
