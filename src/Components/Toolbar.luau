local Fusion = require "@pkg/fusion"

local Store = require "@src/Library/Store"
local Theme = require "@src/Library/Theme"

local Padding = require "@components/Base/Padding"
local ToolbarButton = require "@components/Base/ToolbarButton"
local TextField = require "@components/Base/TextField"
local SearchNavigator = require "@components/SearchNavigator"
local Icon = require "@components/Base/Icon"

return function(Config)
	local Toolbar = Fusion.New "Frame" {
		Name = "Toolbar",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Theme.Get("Color_Container_Secondary"),
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
                Icon = "corner-left-up"
            };

            ToolbarButton {
                Name = "Folder";
                LayoutOrder = 2;
                Icon = "folder-plus" 
            };

            ToolbarButton {
                Name = "Bookmark";
                LayoutOrder = 3;
                Icon = "bookmark-plus" 
            };

            ToolbarButton {
                Name = "Import";
                LayoutOrder = 4;
                Icon = "download" 
            };

            ToolbarButton {
                Name = "Export";
                LayoutOrder = 5;
                Icon = "upload"
            };

            ToolbarButton {
                Name = "Sort";
                LayoutOrder = 6;
                Icon = "arrow-down-a-z" 
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
				ClearTextOnFocus = true,

				[Fusion.Children] = {

					Fusion.Hydrate(Icon {
						Icon = "search",
					}) {
						AnchorPoint = Vector2.new(1, 0),
						Size = UDim2.new(0, 18, 0, 18),
						Position = UDim2.new(1, -3, 0, 3)
					},

					Fusion.Hydrate(SearchNavigator {
						Callbacks = Config.Callbacks
					}) {
						AnchorPoint = Vector2.new(0.5, 0);
						--Position = UDim2.fromScale(0.5, 1) + UDim2.fromOffset(0, 4)
					}
				},
			},
		},
	} :: Frame

	return Toolbar
end
