local Fusion = require "@pkg/fusion"

local CornerRadius = require "@components/Base/CornerRadius"
local Stroke = require "@components/Base/Stroke"
local Padding = require "@components/Base/Padding"
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
		AnchorPoint = Vector2.new(1, 0.5),
		--Image = ButtonConfig.Icon or "rbxassetid://10596127430",
		BackgroundColor3 = Color3.fromRGB(46, 46, 46),
		Position = UDim2.new(0, 0, 0, 0),
		--ImageColor3 = ButtonConfig.IconColor or Color3.fromRGB(216, 216, 216),
		Size = UDim2.new(0, 34, 0, 24),

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
