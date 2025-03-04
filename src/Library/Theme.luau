local Fusion = require "@pkg/fusion"
local Store = require "@src/Library/Store"

local Theme = {}

Theme._ThemeInfo = {
	Dark = {
		Color_Stroke_Base = Color3.fromRGB(34, 34, 34),
		Color_Stroke_Active = Color3.fromRGB(60, 60, 60),

		Color_Container_Base = Color3.fromRGB(46, 46, 46),
		Color_Container_Secondary = Color3.fromRGB(64, 64, 64),
		Color_Container_Tertiary = Color3.fromRGB(52, 52, 52),

		Color_Button_Base = Color3.fromRGB(43, 43, 43),
		Color_Button_Hover = Color3.fromRGB(35, 35, 35),
		Color_Button_Press = Color3.fromRGB(60, 60, 60),

		Color_Item_Base = Color3.fromRGB(43, 43, 43),
		Color_Item_Search = Color3.fromRGB(43, 70, 56),

		Color_Icon = Color3.fromRGB(255, 255, 255),

		Color_Text_Base = Color3.fromRGB(204, 204, 204),
        Color_Text_Secondary = Color3.fromRGB(158, 158, 158),
        Color_Text_Hover = Color3.fromRGB(103, 103, 103),
        Color_Text_Accent1 = Color3.fromRGB(255, 188, 155),

		Color_TextField_Base = Color3.fromRGB(46, 46, 46),
		Color_TextField_Active = Color3.fromRGB(37, 37, 37),

        Color_Tooltip_Base = Color3.fromRGB(30, 30, 30)
	},

	Light = {
		Color_Stroke_Base = Color3.fromRGB(89, 89, 89),
		Color_Stroke_Active = Color3.fromRGB(147, 147, 147),

		Color_Container_Base = Color3.fromRGB(243, 243, 243),
		Color_Container_Secondary = Color3.fromRGB(243, 243, 243),
		Color_Container_Tertiary = Color3.fromRGB(243, 243, 243),

		Color_Button_Base = Color3.fromRGB(255, 255, 255),
		Color_Button_Hover = Color3.fromRGB(193, 193, 193),
		Color_Button_Press = Color3.fromRGB(150, 150, 150),

		Color_Item_Base = Color3.fromRGB(255, 255, 255),
		Color_Item_Search = Color3.fromRGB(134, 202, 169),

		Color_Icon = Color3.fromRGB(40, 40, 40),

		Color_Text_Base = Color3.fromRGB(47, 47, 47),
        Color_Text_Secondary = Color3.fromRGB(75, 75, 75),
        Color_Text_Hover = Color3.fromRGB(110, 110, 110),
        Color_Text_Accent1 = Color3.fromRGB(163, 105, 76),

		Color_TextField_Base = Color3.fromRGB(226, 226, 226),
		Color_TextField_Active = Color3.fromRGB(193, 193, 193),

        Color_Tooltip_Base = Color3.fromRGB(220, 220, 220)
	},
}

Theme._ThemeStates = {}

for Style: string, Value: Color3 | any? in Theme._ThemeInfo.Dark do
	-- Only creating the values for each state once
	if not Theme._ThemeStates[Style] then
		local NewState = Fusion.Computed(function()
			local CurrentTheme = Store.PluginStates.CurrentTheme:get()
			if Theme._ThemeInfo[CurrentTheme] then
				return Theme._ThemeInfo[CurrentTheme][Style]
			else
				return Theme._ThemeInfo["Dark"][Style]
			end
		end)

		Theme._ThemeStates[Style] = NewState
	end
end

export type ThemeStyles =
	"Color_Stroke_Base"
	| "Color_Stroke_Active"

	| "Color_Container_Base"
	| "Color_Container_Secondary"
	| "Color_Container_Tertiary"

	| "Color_Button_Base"
	| "Color_Button_Hover"
	| "Color_Button_Press"

	| "Color_Item_Base"
	| "Color_Item_Search"

	| "Color_Icon"

	| "Color_Text_Base"
    | "Color_Text_Secondary"
    | "Color_Text_Hover"
    | "Color_Text_Accent1"

	| "Color_TextField_Base"
	| "Color_TextField_Active"

    | "Color_Tooltip_Base"


function Theme.Get(Style: ThemeStyles)
	assert(Theme._ThemeStates[Style], `{Style} is not a valid theme style`)
	return Theme._ThemeStates[Style]
end

return Theme
