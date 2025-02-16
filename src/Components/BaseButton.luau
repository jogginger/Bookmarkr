local Fusion = require "@pkg/fusion"

local Color_Base = Color3.fromRGB(43, 43, 43)
local Color_Hover = Color3.fromRGB(35, 35, 35)

return function(Data)
	local Button = Data.Button
	local Color = Fusion.Value(Color_Base)
		
	return Fusion.Hydrate(Button) {
		[Fusion.OnEvent "MouseButton1Click"] = Data.OnButtonClick or function() end;
		[Fusion.OnEvent "MouseEnter"] = function() Color:set(Color_Hover) end,
		[Fusion.OnEvent "MouseLeave"] = function() Color:set(Color_Base) end,
		
		Visible = Data.Visible or true;
		BackgroundColor3 = Fusion.Spring(Color, 40, 0.75);
	}
end