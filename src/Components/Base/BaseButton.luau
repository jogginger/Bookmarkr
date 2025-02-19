local fusion = require(script.Parent.Parent.Parent.Packages.fusion)
local Fusion = require "@pkg/fusion"
local Store = require "@src/Library/Store"
local Ref = Fusion.Ref

local Tooltip = require "@components/Tooltip"

local Color_Base = Color3.fromRGB(43, 43, 43)
local Color_Hover = Color3.fromRGB(35, 35, 35)
local Color_Pressed = Color3.fromRGB(60, 60, 60)

return function(Data)
	local Button = Data.Button :: GuiButton
	local OverwriteState = Data.OverwriteState

	local Color = Fusion.Value(Color_Base)
	local Hovering = Fusion.Value(false)

	local TooltipStates = Store.TooltipStates

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
		[Fusion.OnEvent "InputBegan"] = function(Input: InputObject)
			if Input.UserInputType == Enum.UserInputType.MouseMovement then
				if Data.Tooltip then
					task.delay(1 / 45, function()
						if not Hovering:get() then
							return
						end
						if TooltipStates.HideTask then
							task.cancel(TooltipStates.HideTask)
							TooltipStates.HideTask = nil
						end
						TooltipStates.HideTask = task.delay(0.3, function()
							TooltipStates.Text:set(Data.Tooltip)
							task.defer(function()
								TooltipStates.Adornee:set(Button)
							end)
						end)
					end)
				end

				Color:set(Color_Hover)
				Hovering:set(true)
			end
		end,
		[Fusion.OnEvent "InputEnded"] = function(Input: InputObject)
			if Input.UserInputType == Enum.UserInputType.MouseMovement then
				if Data.Tooltip then
					if TooltipStates.HideTask then
						task.cancel(TooltipStates.HideTask)
						TooltipStates.HideTask = nil
					end
					local Adornee = TooltipStates.Adornee:get()
					if Adornee == Button then
						-- Buffering
						task.defer(function()
							TooltipStates.Text:set ""
							TooltipStates.Adornee:set(nil)
						end)
					end
				end
				Color:set(Color_Base)
				Hovering:set(false)
			end
		end,
		[Fusion.Cleanup] = function(...)
			if Data.Tooltip then
				task.delay(1 / 40, function()
					local Adornee = TooltipStates.Adornee:get()
					if Adornee == Button then
						if TooltipStates.HideTask then
							task.cancel(TooltipStates.HideTask)
							TooltipStates.HideTask = nil
						end
						TooltipStates.Text:set ""
						TooltipStates.Adornee:set(nil)
					end
				end)
			end
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
