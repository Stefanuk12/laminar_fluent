--[=[
    @within free
    @private
    
    Truncates or rounds a number to a specified number of decimal places.
    
    Provides precise control over decimal precision with optional rounding.
    When rounding is disabled, simply truncates the decimal places.
    When enabled, performs proper mathematical rounding.
]=]
local function Truncate(Value: number, DecimalPlaces: number, Round: boolean?): number
    local Shift = 10 ^ (typeof(DecimalPlaces) == "number" and math.max(DecimalPlaces, 0) or 0)

    if Round then
        return math.round(Value * Shift) // 1 / Shift
    else
        return Value * Shift // 1 / Shift
    end
end
return Truncate
