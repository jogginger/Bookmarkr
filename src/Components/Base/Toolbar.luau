local Fusion = require "@pkg/fusion"

local CornerRadius = require "@components/Base/CornerRadius"
local Stroke = require "@components/Base/Stroke"
local Padding = require "@components/Base/Padding"
local ToolbarButton = require "@components/Base/ToolbarButton"

return function(Config)
	local Toolbar = Fusion.New "Frame" {
		Name = "Toolbar",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(64, 64, 64),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 32),

		[Fusion.Children] = {
			Fusion.New "UIListLayout" {
				Name = "UIListLayout",
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},

			Padding {4, 4, 0, 0};

            ToolbarButton {
                Name = "DirectoryUp";
                LayoutOrder = 1;
                Icon = "rbxassetid://153287141"
            };

            ToolbarButton {
                Name = "Folder";
                LayoutOrder = 2;
                Icon = "rbxassetid://10596127430"
            };

            ToolbarButton {
                Name = "Bookmark";
                LayoutOrder = 3;
                Icon = "rbxassetid://4627140512"
            };

            ToolbarButton {
                Name = "Import";
                LayoutOrder = 4;
                Icon = "rbxassetid://86229867714970"
            };

            ToolbarButton {
                Name = "Export";
                LayoutOrder = 5;
                Icon = "rbxassetid://78689563976440"
            };

            ToolbarButton {
                Name = "Sort";
                LayoutOrder = 6;
                Icon = "rbxassetid://8456591132"
            };

			Fusion.New "TextBox" {
				Name = "Search",
				LayoutOrder = 10,
				TextWrapped = true,
				AnchorPoint = Vector2.new(1, 0),
				PlaceholderColor3 = Color3.fromRGB(91, 91, 91),
				PlaceholderText = "...",
				BorderSizePixel = 0,
				Size = UDim2.new(0.5, 0, 0, 24),
				TextColor3 = Color3.fromRGB(204, 204, 204),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Text = "",
				Position = UDim2.new(1, -4, 0, 4),
				TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = Font.new "rbxasset://fonts/families/Nunito.json",
				TextSize = 14,
				TextScaled = true,
				BackgroundColor3 = Color3.fromRGB(46, 46, 46),

				[Fusion.Children] = {
					Fusion.New "UIPadding" {
						Name = "UIPadding",
						PaddingLeft = UDim.new(0, 4),
					},

					Fusion.New "UICorner" {
						Name = "UICorner",
						CornerRadius = UDim.new(0, 2),
					},

					Fusion.New "ImageLabel" {
						Name = "ImageLabel",
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						AnchorPoint = Vector2.new(1, 0),
						Image = "rbxassetid://11496279085",
						BackgroundTransparency = 1,
						Position = UDim2.new(1, -3, 0, 3),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0,
						Size = UDim2.new(0, 18, 0, 18),
					},

					Fusion.New "UIStroke" {
						Name = "UIStroke",
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = Color3.fromRGB(34, 34, 34),
					},
				},
			},
		},
	} :: Frame

	return Toolbar
end
