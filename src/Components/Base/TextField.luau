local Fusion = require "@pkg/fusion"
local Stroke = require "@components/Base/Stroke"
local Padding = require "@components/Base/Padding"
local CornerRadius = require "@components/Base/CornerRadius"

local Color_Base = Color3.fromRGB(46, 46, 46)
local Color_Editing = Color3.fromRGB(37, 37, 37)

local StrokeColor_Base = Color3.fromRGB(34, 34, 34)
local StrokeColor_Editing = Color3.fromRGB(60, 60, 60)

return function(Config)
	local Editing = Fusion.Value(false)

	local TextField = Fusion.New "TextBox" {
		Name = "TextField",
		TextColor3 = Color3.fromRGB(204, 204, 204),
		Text = "",
		BackgroundColor3 = Fusion.Spring(
            Fusion.Computed(function()
                return Editing:get() and Color_Editing or Color_Base
            end),
            30,
            0.75
        ),
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		PlaceholderColor3 = Color3.fromRGB(91, 91, 91),
		FontFace = Font.new "rbxasset://fonts/families/Nunito.json",
		PlaceholderText = "Placeholder",
		TextSize = 14,
		Size = UDim2.new(0, 50, 0, 50),

		[Fusion.Children] = {
			Stroke {
				Color = Fusion.Spring(
					Fusion.Computed(function()
						return Editing:get() and StrokeColor_Editing or StrokeColor_Base
					end),
					30,
					0.75
				),
			},
			Padding { 4, 0, 0, 0 },
			CornerRadius(),
		},

		[Fusion.OnEvent "Focused"] = function()
			Editing:set(true)
		end,

		[Fusion.OnEvent "FocusLost"] = function()
			Editing:set(false)
		end,
	} :: TextBox

	return TextField
end
