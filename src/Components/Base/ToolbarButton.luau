local Fusion = require "@pkg/fusion"

local CornerRadius = require "@components/Base/CornerRadius"
local Stroke = require "@components/Base/Stroke"
local _Padding = require "@components/Base/Padding"
local Icon = require "@components/Base/Icon"

type ButtonConfig = {
	Name: string?,
	LayoutOrder: number?,
    Icon: string?,
	IconColor: Color3?,
    Callback: ((...any) -> nil)?,
}

local Callback = function() end

return function(ButtonConfig: ButtonConfig)
	local ToolbarButton = Fusion.New "TextButton" {
		Name = ButtonConfig.Name or "Button",
		LayoutOrder = ButtonConfig.LayoutOrder or 1,
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0),
		--Image = ButtonConfig.Icon or "rbxassetid://10596127430",
		BackgroundColor3 = Color3.fromRGB(46, 46, 46),
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0.073, 0, 0, 24),
		Text = "",

		[Fusion.Children] = {
			CornerRadius(),
			Stroke {},
			
			if ButtonConfig.Icon then
				Fusion.Hydrate(Icon {
					Icon = ButtonConfig.Icon,
					Color = ButtonConfig.IconColor
				}) {
					AnchorPoint = Vector2.one * 0.5,
					Position = UDim2.fromScale(0.5, 0.5)
				}
			else 
				nil
		},

        [Fusion.OnEvent "MouseButton1Click"] = ButtonConfig.Callback or Callback
        
	} :: ImageButton

	return ToolbarButton
end
