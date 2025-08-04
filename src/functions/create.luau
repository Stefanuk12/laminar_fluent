-- // Dependencies
local InstanceTracker = require("@modules/instance_tracker")

--[=[
    @within free

    A standalone function for [InstanceTracker.Create].
]=]
local function Create(InstanceType: string, Properties: { [string]: any }?, Children: { Instance }?): Instance
    return InstanceTracker:Create(InstanceType, Properties, Children)
end
return Create
