-- // Dependencies

-- // Services

-- // Types
export type CLASSData = {}

-- //
local CLASS = {}
CLASS.__index = CLASS
export type CLASS = typeof(setmetatable({} :: CLASSData, CLASS))
do
    --[=[
        Create a new [CLASS] object.
    ]=]
    function CLASS.new(): CLASS
        -- // Create the object
        local self = setmetatable({}, CLASS)

        -- // Set

        -- // Return the object
        return self
    end
end
return CLASS
