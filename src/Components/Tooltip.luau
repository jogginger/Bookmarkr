local Fusion = require "@pkg/fusion"
local Lucide = require "@pkg/Lucide"
local Ref = Fusion.Ref

local Theme = require "@src/Library/Theme"

local Padding = require "@components/Base/Padding"
local CornerRadius = require "@components/Base/CornerRadius"
local Stroke = require "@components/Base/Stroke"

type TooltipConfig = {
	Icon: string?,
	Color: Color3?,
}

local Tooltip = nil

return function(Config)
	-- Only want to create one
	if Tooltip == nil then
		local TooltipObject = Fusion.Value(nil)
		local Transparency = Fusion.Spring(
			Fusion.Computed(function()
				local Adornee = Config.Adornee:get()
				return Adornee ~= nil and 0 or 1
			end),
			15,
			1
		)

		Tooltip = Fusion.New "TextLabel" {
			[Ref] = TooltipObject,

			Name = "Tooltip",
			AnchorPoint = Vector2.new(0.5, 0),
			Size = UDim2.fromOffset(25, 5),
			ZIndex = 25,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = Theme.Get("Color_Tooltip_Base"),
			BackgroundTransparency = Transparency,
			TextTransparency = Transparency,
			TextColor3 = Theme.Get("Color_Text_Base"),
			FontFace = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.Bold),
			Text = Config.Text,
			Visible = true,
			Position = Fusion.Computed(function()
				local Adornee = Config.Adornee:get() :: GuiBase2d
				local Label = TooltipObject:get() :: TextLabel
				if not Adornee or not Label then
					return UDim2.new(0.5, 0, 1, 4)
				end
				local Dock = Label.Parent :: Frame

				local Relative = Vector2.new(
					Adornee.AbsolutePosition.X - Dock.AbsolutePosition.X,
					Adornee.AbsolutePosition.Y - Dock.AbsolutePosition.Y
				)
				local RelativeAdjusted =
					Vector2.new(Relative.X + Adornee.AbsoluteSize.X / 2, Relative.Y + Adornee.AbsoluteSize.Y + 4)

				local Absolute = Adornee.AbsolutePosition + Vector2.new(Adornee.AbsoluteSize.X / 2, 0)

				if Absolute.X - Label.AbsoluteSize.X / 2 < Dock.AbsolutePosition.X then
					local Adjustment = (Dock.AbsolutePosition.X - (Absolute.X - Label.AbsoluteSize.X / 2)) + 4
					return UDim2.fromOffset(RelativeAdjusted.X + Adjustment, RelativeAdjusted.Y)
				elseif Absolute.X + Label.AbsoluteSize.X / 2 > Dock.AbsolutePosition.X + Dock.AbsoluteSize.X then
					local Adjustment = (Absolute.X - (Dock.AbsolutePosition.X + Dock.AbsoluteSize.X)) - 4
					return UDim2.fromOffset(RelativeAdjusted.X + Adjustment, RelativeAdjusted.Y)
				else
					return UDim2.fromOffset(RelativeAdjusted.X, RelativeAdjusted.Y)
				end
			end),

			[Fusion.Children] = {
				CornerRadius(),
				Stroke { Color = Color3.fromRGB(90, 90, 90), Transparency = Transparency },
				Padding { 4, 4, 4, 4 },
			},
		}
	end

	return Tooltip
end
