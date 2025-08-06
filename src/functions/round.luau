-- // Dependencies
local Truncate = require("@functions/truncate")

--[=[
    @within free
    @private
    
    Rounds a number to a specified number of decimal places.
    
    Uses the [Truncate] function with rounding enabled to achieve proper
    mathematical rounding behavior.
]=]
local function Round(Value: number, DecimalPlaces: number): number
    return Truncate(Value, DecimalPlaces, true)
end
return Round
