local Fusion = require "@pkg/fusion"

local Padding = require "@components/Base/Padding"
local ToolbarButton = require "@components/Base/ToolbarButton"
local TextField = require "@components/Base/TextField"

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
                Icon = "corner-left-up" --"rbxassetid://153287141"
            };

            ToolbarButton {
                Name = "Folder";
                LayoutOrder = 2;
                Icon = "folder-plus" --"rbxassetid://10596127430"
            };

            ToolbarButton {
                Name = "Bookmark";
                LayoutOrder = 3;
                Icon = "bookmark-plus" --"rbxassetid://4627140512"
            };

            ToolbarButton {
                Name = "Import";
                LayoutOrder = 4;
                Icon = "download" --"rbxassetid://86229867714970"
            };

            ToolbarButton {
                Name = "Export";
                LayoutOrder = 5;
                Icon = "upload" --"rbxassetid://78689563976440"
            };

            ToolbarButton {
                Name = "Sort";
                LayoutOrder = 6;
                Icon = "arrow-down-a-z" --"rbxassetid://8456591132"
            };

			Fusion.Hydrate (TextField {}) {
				Name = "Search",
				LayoutOrder = 10,
				Text = "",
				TextScaled = true,
				PlaceholderText = "...",
				Size = UDim2.new(0.5, 0, 0, 24),
				TextWrapped = true,
				AnchorPoint = Vector2.new(1, 0),

				[Fusion.Children] = {
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
				},
			},
		},
	} :: Frame

	return Toolbar
end
