local Fusion = require "@pkg/fusion"

local Color_Base = Color3.fromRGB(43, 43, 43)
local Color_Hover = Color3.fromRGB(35, 35, 35)
local Color_Pressed = Color3.fromRGB(60, 60, 60)

return function(Data)
	local Button = Data.Button :: GuiButton
	local OverwriteState = Data.OverwriteState 

	local Color = Fusion.Value(Color_Base)
	local Hovering = Fusion.Value(false)

	Fusion.Hydrate(Button) {
		[Fusion.OnEvent "MouseButton1Click"] = function()
			if Data.OnButtonClick then
				Data.OnButtonClick()
			end
		end,
		[Fusion.OnEvent "MouseButton1Down"] = function()
			Color:set(Color_Pressed)
		end,
		[Fusion.OnEvent "MouseButton1Up"] = function()
			Color:set(Hovering:get() and Color_Hover or Color_Base)
		end,
		[Fusion.OnEvent "MouseEnter"] = function()
			Color:set(Color_Hover)
			Hovering:set(true)
		end,
		[Fusion.OnEvent "MouseLeave"] = function()
			Color:set(Color_Base)
			Hovering:set(false)
		end,

		Visible = Data.Visible or true,
	}

	local ButtonColor = Fusion.Computed(function()
		if OverwriteState and OverwriteState:get() then
			return (if Data.Mask then Data.Mask else Button).BackgroundColor3
		else 
			return Color:get()
		end
	end)

	if not Data.Mask then
		Fusion.Hydrate(Button) {
			BackgroundColor3 = Fusion.Spring(ButtonColor, 40, 0.75),
		}
	else			
		Fusion.Hydrate(Data.Mask) {
			BackgroundColor3 = Fusion.Spring(ButtonColor, 40, 0.75),
			Visible = Data.Visible or true,
		}
	end

	return Button
end
