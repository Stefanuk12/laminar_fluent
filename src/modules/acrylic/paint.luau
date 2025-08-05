-- // Dependencies
local AcrylicBlur = require("@modules/acrylic/blur")
local Create = require("@functions/create")

-- // Types
export type AcrylicPaintData = {
    Frame: Frame,
    Blur: AcrylicBlur.AcrylicBlur,
}

--[=[
    @class AcrylicPaint
    
    Creates an acrylic glass-like visual effect with layered backgrounds, gradients, noise textures,
    and optional blur effects. This provides a modern, translucent appearance commonly used in
    modern UI design systems.
    
    The paint effect includes:
    - Semi-transparent background with theme support
    - Drop shadow effect
    - Gradient overlay
    - Noise texture layers for realistic glass appearance
    - Border stroke
    - Optional blur effect integration
]=]
local AcrylicPaint = {}
AcrylicPaint.__index = AcrylicPaint
export type AcrylicPaint = typeof(setmetatable({} :: AcrylicPaintData, AcrylicPaint))
do
    --[=[
        Creates a new [AcrylicPaint] instance with layered visual effects.
        
        @param Acrylic -- Whether to enable the blur effect (optional)
    ]=]
    function AcrylicPaint.new(Acrylic: boolean?): AcrylicPaint
        -- // Create the object
        local self = setmetatable({}, AcrylicPaint)

        -- // Set
        self.Frame = Create("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 0.9,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
        }, {
            Create("ImageLabel", {
                Image = "rbxassetid://8992230677",
                ScaleType = "Slice",
                SliceCenter = Rect.new(Vector2.new(99, 99), Vector2.new(99, 99)),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(1, 120, 1, 116),
                Position = UDim2.fromScale(0.5, 0.5),
                BackgroundTransparency = 1,
                ImageColor3 = Color3.fromRGB(0, 0, 0),
                ImageTransparency = 0.7,
            }),

            Create("UICorner", {
                CornerRadius = UDim.new(0, 8),
            }),

            Create("Frame", {
                BackgroundTransparency = 0.45,
                Size = UDim2.fromScale(1, 1),
                Name = "Background",
                ThemeTag = {
                    BackgroundColor3 = "AcrylicMain",
                },
            }, {
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                }),
            }),

            Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.4,
                Size = UDim2.fromScale(1, 1),
            }, {
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                }),

                Create("UIGradient", {
                    Rotation = 90,
                    ThemeTag = {
                        Color = "AcrylicGradient",
                    },
                }),
            }),

            Create("ImageLabel", {
                Image = "rbxassetid://9968344105",
                ImageTransparency = 0.98,
                ScaleType = Enum.ScaleType.Tile,
                TileSize = UDim2.fromOffset(128, 128),
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
            }, {
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                }),
            }),

            Create("ImageLabel", {
                Image = "rbxassetid://9968344227",
                ImageTransparency = 0.9,
                ScaleType = Enum.ScaleType.Tile,
                TileSize = UDim2.fromOffset(128, 128),
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                ThemeTag = {
                    ImageTransparency = "AcrylicNoise",
                },
            }, {
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                }),
            }),

            Create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 2,
            }, {
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                }),
                Create("UIStroke", {
                    Transparency = 0.5,
                    Thickness = 1,
                    ThemeTag = {
                        Color = "AcrylicBorder",
                    },
                }),
            }),
        }) :: Frame

        if Acrylic then
            self.Blur = AcrylicBlur.new()
            self.Blur.Frame.Parent = self.Frame
        end

        -- // Return the object
        return self
    end

    --[=[
        Destroys the [AcrylicPaint] instance and cleans up all resources.
        
        If a blur effect was created, it will be properly destroyed to prevent memory leaks.
        
        @param self AcrylicPaint -- The paint instance to destroy
    ]=]
    function AcrylicPaint.Destroy(self: AcrylicPaint)
        if self.Blur then
            self.Blur:Destroy()
        end
    end
end
return AcrylicPaint
