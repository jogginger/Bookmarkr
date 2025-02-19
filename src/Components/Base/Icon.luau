local Fusion = require "@pkg/fusion"
local Lucide = require "@pkg/Lucide"

local Padding = require "@components/Base/Padding"

type IconConfig = {
    Icon: string?;
    Color: Color3?
}

return function(Config)
    local Asset = Lucide.GetAsset(Config.Icon, 24)
    
	local Icon = Fusion.New "ImageLabel" {
		Name = "Icon",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 20, 0, 20),
        Image = Asset.Url,
        ImageRectOffset = Asset.ImageRectOffset,
        ImageRectSize = Asset.ImageRectSize,
        ImageColor3 = Config.Color or Color3.fromRGB(255, 255, 255),
        ScaleType = Enum.ScaleType.Fit,

        [Fusion.Children] = {
            Padding { 4, 4, 4, 4 }
        },
	} :: ImageLabel

	return Icon
end
