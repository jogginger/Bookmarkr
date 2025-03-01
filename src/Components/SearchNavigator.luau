local Fusion = require "@pkg/fusion"

local Store = require "@src/Library/Store"

local Padding = require "@components/Base/Padding"
local CornerRadius = require "@components/Base/CornerRadius"
local Stroke = require "@components/Base/Stroke"
local ToolbarButton = require "@components/Base/ToolbarButton"
local BaseButton = require "@components/Base/BaseButton"

return function(Config)
	local Active = Fusion.Computed(function()
		local ResultCount = Store.PluginStates.SearchResultCount:get()
		return ResultCount > 1
	end)

	local Transparency = Fusion.Spring(
		Fusion.Computed(function()
			return Active:get() and 0 or 1
		end),
		45,
		0.8
	)

	local Position = Fusion.Spring(
		Fusion.Computed(function()
			return (Active:get() and UDim2.new(0.5, 0, 1, 0) or UDim2.new(0.5, 0, 0, 0)) + UDim2.fromOffset(0, 2)
		end),
		45,
		0.8
	)

	local Navigator = Fusion.New "CanvasGroup" {
		Name = "Navigator",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 1) + UDim2.fromOffset(0, 2),
		ZIndex = 2,
		BackgroundTransparency = 1,

		Position = Position,
		GroupTransparency = Transparency,

		[Fusion.Children] = {
            Padding { 1, 1, 1, 1 },

            Fusion.New "Frame" {
                Name = "Holder",
                BackgroundColor3 = Color3.fromRGB(46, 46, 46),
                Size = UDim2.fromScale(1, 1),

                [Fusion.Children] = {
                    Stroke { Color = Color3.fromRGB(90, 90, 90) },
                    Padding { 4, 4, 4, 4 },
                    CornerRadius(),

                    Fusion.New "UIListLayout" {
                        Name = "UIListLayout",
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    },
        
                    Fusion.New "TextLabel" {
                        Name = "Label",
                        TextWrapped = true,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        TextColor3 = Color3.fromRGB(204, 204, 204),
        
                        Text = Fusion.Computed(function()
                            local ResultCount = Store.PluginStates.SearchResultCount:get()
                            local Index = Store.PluginStates.SearchIndex:get()
                            return ResultCount >= 1 and `{Index} / {ResultCount}` or `-`
                        end),
        
                        TextScaled = true,
                        RichText = true,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        BackgroundTransparency = 1,
                        LayoutOrder = 2,
                        FontFace = Font.new(
                            "rbxasset://fonts/families/Nunito.json",
                            Enum.FontWeight.Bold,
                            Enum.FontStyle.Normal
                        ),
        
                        Size = UDim2.new(0.5, 0, 1, 0),
        
                        [Fusion.Children] = {
                            Fusion.New "UITextSizeConstraint" {
                                Name = "UITextSizeConstraint",
                                MaxTextSize = 30,
                            },
                        },
                    },
        
                    BaseButton {
                        Button = Fusion.Hydrate(ToolbarButton {
                            Name = "Last",
                            LayoutOrder = 1,
                            Icon = "arrow-left",
                        }) {
                            AnchorPoint = Vector2.new(0.5, 0),
                            Position = UDim2.fromScale(0.25, 1) + UDim2.fromOffset(0, 4),
                            Size = UDim2.fromScale(0.25, 1),
                            Interactable = Active,
                        },
                        OnButtonClick = function()
                            Store.ToolbarCallbacks.OnSearchNavigate(-1)
                        end,
                    },
        
                    BaseButton {
                        Button = Fusion.Hydrate(ToolbarButton {
                            Name = "Next",
                            LayoutOrder = 3,
                            Icon = "arrow-Right",
                        }) {
                            AnchorPoint = Vector2.new(0.5, 0),
                            Position = UDim2.fromScale(0.75, 1) + UDim2.fromOffset(0, 4),
                            Size = UDim2.fromScale(0.25, 1),
                            Interactable = Active,
                        },
                        OnButtonClick = function()
                            Store.ToolbarCallbacks.OnSearchNavigate(1)
                        end,
                    },
                }
            },
		},
	} :: CanvasGroup

	print(Config.Callbacks)

	return Navigator
end
