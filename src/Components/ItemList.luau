local Fusion = require "@pkg/fusion"
local Theme = require "@src/Library/Theme"

local CornerRadius = require "@components/Base/CornerRadius"
local Stroke = require "@components/Base/Stroke"
local Padding = require "@components/Base/Padding"

return function(Config)
	local ItemList = Fusion.New "Frame" {
		Name = "Items",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 60),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Theme.Get("Color_Container_Tertiary"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, -8, 1, -64),

		[Fusion.Children] = {
			CornerRadius(),
			Stroke {},

			Fusion.New "ScrollingFrame" {
				Name = "List",
				ScrollBarImageColor3 = Color3.fromRGB(86, 86, 86),
				MidImage = "rbxassetid://1195495135",
				Active = true,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 5,
				CanvasSize = UDim2.new(),
				VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
				TopImage = "rbxassetid://1195495135",
				Size = UDim2.new(1, 0, 1, 0),
				BottomImage = "rbxassetid://1195495135",
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),

				[Fusion.Children] = {
					Fusion.New "UIListLayout" {
						Name = "UIListLayout",
						Padding = UDim.new(0, 4),
						SortOrder = Enum.SortOrder.LayoutOrder,
					},

					Padding { 4, 4, 4, 4 },
				},
			},
		},
	} :: Frame

	return ItemList
end
