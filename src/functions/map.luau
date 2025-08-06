--[=[
    @within free
    @private
    
    Maps a value from one range to another range using linear interpolation.
    
    Performs linear remapping/scaling of a value from an input range to an output range.
    Commonly used for converting between different coordinate systems, scaling values,
    or creating proportional relationships between different numeric ranges.
]=]
local function Remap(Value: number, InMin: number, InMax: number, OutMin: number, OutMax: number): number
    return (Value - InMin) * (OutMax - OutMin) / (InMax - InMin) + OutMin
end
return Remap
