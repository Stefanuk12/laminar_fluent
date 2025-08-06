-- // Dependencies

-- // Services

-- // Types
export type LibraryData = {}

-- //
local Library = {}
Library.__index = Library
export type Library = typeof(setmetatable({} :: LibraryData, Library))
do
    
end
return Library
