local Fusion = require "@pkg/fusion"
local Ref = Fusion.Ref 

local CornerRadius = require "@components/Base/CornerRadius"
local Stroke = require "@components/Base/Stroke"
local Padding = require "@components/Base/Padding"

local Color_Base = Color3.fromRGB(43, 43, 43)
local Color_Hover = Color3.fromRGB(35, 35, 35)
local Color_Pressed = Color3.fromRGB(60, 60, 60)

return function(Data)
	local Button = Data.Button :: GuiButton
	local OverwriteState = Data.OverwriteState 

	local Color = Fusion.Value(Color_Base)
	local Hovering = Fusion.Value(false)
	local Tooltip = Fusion.Value(nil)

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
		[Fusion.Children] = if Data.Tooltip then {
			Fusion.New "TextLabel" {
				[Ref] = Tooltip,

				Name = "Tooltip",
				AnchorPoint = Vector2.new(0.5, 0),
				--Position = UDim2.new(0.5, 0, 1, 0),
				Size = UDim2.fromOffset(25, 5),
				ZIndex = 999,
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				BackgroundTransparency = 0.3,
				TextColor3 = Color3.fromRGB(204, 204, 204),
				FontFace = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.Bold),
				Text = Data.Tooltip,
				Visible = Hovering,
				Position = Fusion.Computed(function()
					local IsHover = Hovering:get()
					local Label = Tooltip:get() :: TextLabel
					if not Label then return UDim2.new(0.5, 0, 1, 4) end

					local Dock = Label:FindFirstAncestorWhichIsA("DockWidgetPluginGui")
					
					if IsHover and Label.AbsolutePosition.X < Dock.AbsolutePosition.X then 
						return UDim2.new(0.5, (Dock.AbsolutePosition.X - Label.AbsolutePosition.X) + 4, 1, 4)
					elseif IsHover and Label.AbsolutePosition.X + Label.AbsoluteSize.X > Dock.AbsolutePosition.X + Dock.AbsoluteSize.X then 
						return UDim2.new(0.5, ((Dock.AbsolutePosition.X + Dock.AbsoluteSize.X) - (Label.AbsolutePosition.X + Label.AbsoluteSize.X)) - 8, 1, 4)
					else 
						return UDim2.new(0.5, 0, 1, 4)
					end
				end),

				[Fusion.Children] = {
					CornerRadius(),
					Stroke { Color = Color3.fromRGB(90, 90, 90) },
					Padding { 4, 4, 4, 4}
				}
			}
		} else {},

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
