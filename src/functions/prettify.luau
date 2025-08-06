-- // Dependencies
local Round = require("@functions/round")

--[=[
    @within free
    @private
    
    Formats different types of values into human-readable strings.
    
    Handles [EnumItem]s and strings by converting camelCase/PascalCase to spaced text
    (e.g., "CamelCase" becomes "Camel Case"). Numbers are rounded to 2 decimal places.
    Other types are converted to strings using tostring().
]=]
local function Prettify(Value: EnumItem & string & number): string | number
    local ValueType = typeof(Value)

    if ValueType == "EnumItem" then
        return ({ Value.Name:gsub("(%l)(%u)", "%1 %2") })[1]
    elseif ValueType == "string" then
        return ({ Value:gsub("(%l)(%u)", "%1 %2") })[1]
    elseif ValueType == "number" then
        return Round(Value, 2)
    else
        return tostring(Value)
    end
end
return Prettify
