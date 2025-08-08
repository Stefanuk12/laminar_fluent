-- // Dependencies

-- // Services

-- // Types
export type LibraryData = {}

-- //
local Library = {}
Library.__index = Library
export type Library = typeof(setmetatable({} :: LibraryData, Library))
do
    function Library.new(): Library
        -- // Create the object
        local self = setmetatable({}, Library)

        -- // Set

        -- // Return the object
        return self
    end
end
return Library
