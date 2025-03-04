local Fusion = require "@pkg/fusion"
local Theme = require "@src/Library/Theme"

local Stroke = require "@components/Base/Stroke"
local Padding = require "@components/Base/Padding"
local CornerRadius = require "@components/Base/CornerRadius"

return function(Config)
	local Editing = Fusion.Value(false)

	local TextField = Fusion.New "TextBox" {
		Name = "TextField",
		TextColor3 = Theme.Get("Color_Text_Base"),
		Text = "",
		BackgroundColor3 = Fusion.Spring(
            Fusion.Computed(function()
                return Editing:get() and Theme.Get("Color_TextField_Active"):get() or Theme.Get("Color_TextField_Base"):get()
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
						return Editing:get() and Theme.Get("Color_Stroke_Active"):get() or Theme.Get("Color_Stroke_Base"):get()
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
