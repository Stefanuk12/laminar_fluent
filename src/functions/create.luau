-- // Dependencies
local InstanceTracker = require("@modules/instance_tracker")

--[=[
    @within free
    @private

    A standalone function for [InstanceTracker.Create].
    
    Provides a convenient wrapper around the [InstanceTracker]'s create functionality
    for creating and tracking Roblox instances with automatic cleanup management.
]=]
local function Create(InstanceType: string, Properties: { [string]: any }?, Children: { Instance }?): Instance
    return InstanceTracker:Create(InstanceType, Properties, Children)
end
return Create
