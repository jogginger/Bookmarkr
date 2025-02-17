local Fusion = require "@pkg/fusion"

local CornerRadius = require "@components/Base/CornerRadius"
local Stroke = require "@components/Base/Stroke"
local Padding = require "@components/Base/Padding"

return function(Config)
	local EditPrompt = Fusion.New "CanvasGroup" {
		Name = "Edit",
		Visible = false,
		BackgroundTransparency = 0.4,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),

		[Fusion.Children] = {
			Fusion.New "TextButton" {
				Name = "Blocker",
				FontFace = Font.new "rbxasset://fonts/families/SourceSansPro.json",
				TextColor3 = Color3.fromRGB(0, 0, 0),
				Text = "",
				BackgroundTransparency = 1,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 14,
				Size = UDim2.new(1, 0, 1, 0),
			},

			Fusion.New "Frame" {
				Name = "Holder",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				ZIndex = 2,
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = Color3.fromRGB(46, 46, 46),

				[Fusion.Children] = {
					Stroke { Color = Color3.fromRGB(90, 90, 90) },
					Padding { 4, 4, 4, 4 },

					Fusion.New "UISizeConstraint" {
						Name = "UISizeConstraint",
						MinSize = Vector2.new(0, 50),
						MaxSize = Vector2.new(math.huge, 500),
					},

					Fusion.New "TextButton" {
						Name = "Confirm",
						LayoutOrder = 999,
						FontFace = Font.new(
							"rbxasset://fonts/families/Nunito.json",
							Enum.FontWeight.Bold,
							Enum.FontStyle.Normal
						),
						TextColor3 = Color3.fromRGB(204, 204, 204),
						Text = "Confirm",
						AutoButtonColor = false,
						AnchorPoint = Vector2.new(1, 0),
						BackgroundColor3 = Color3.fromRGB(46, 46, 46),
						Position = UDim2.new(0.0774, -4, 0, 4),
						TextScaled = true,
						Size = UDim2.new(0, 135, 0, 24),

						[Fusion.Children] = {
							Stroke {},
							Padding { 4, 0, 0, 0 },
							CornerRadius(),
						},
					},

					Fusion.New "TextBox" {
						Name = "NameField",
						LayoutOrder = 10,
						TextColor3 = Color3.fromRGB(204, 204, 204),
						Text = "",
						BackgroundColor3 = Color3.fromRGB(46, 46, 46),
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						PlaceholderColor3 = Color3.fromRGB(91, 91, 91),
						FontFace = Font.new "rbxasset://fonts/families/Nunito.json",
						PlaceholderText = "Name...",
						TextSize = 14,
						Size = UDim2.new(0, 180, 0, 24),

						[Fusion.Children] = {
							Stroke {},
							Padding { 4, 0, 0, 0 },
							CornerRadius(),
						},
					},

					Fusion.New "UICorner" {
						Name = "UICorner",
						CornerRadius = UDim.new(0, 2),
					},

					Fusion.New "TextBox" {
						Name = "LineField",
						LayoutOrder = 15,
						TextColor3 = Color3.fromRGB(204, 204, 204),
						Text = "",
						BackgroundColor3 = Color3.fromRGB(46, 46, 46),
						TextScaled = true,
						FontFace = Font.new "rbxasset://fonts/families/Nunito.json",
						PlaceholderColor3 = Color3.fromRGB(91, 91, 91),
						TextXAlignment = Enum.TextXAlignment.Left,
						PlaceholderText = "Line...",
						TextSize = 14,
						Size = UDim2.new(0, 180, 0, 24),

						[Fusion.Children] = {
							Stroke {},
							Padding { 4, 0, 0, 0 },
							CornerRadius(),
						},
					},

					Fusion.New "UIListLayout" {
						Name = "UIListLayout",
						Padding = UDim.new(0, 6),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
					},
				},
			},
		},
	} :: CanvasGroup

	return EditPrompt
end
