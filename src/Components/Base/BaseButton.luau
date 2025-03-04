local Fusion = require "@pkg/fusion"
local Store = require "@src/Library/Store"
local Theme = require "@src/Library/Theme"

return function(Data)
	local Button = Data.Button :: GuiButton
	local OverwriteState = Data.OverwriteState

	local ButtonState = Fusion.Value(1) -- 1: Base 2: Hover 3: Press
	local Hovering = Fusion.Value(false)

	local TooltipStates = Store.TooltipStates

	Fusion.Hydrate(Button) {
		[Fusion.OnEvent "MouseButton1Click"] = function()
			if Data.OnButtonClick then
				Data.OnButtonClick()
			end
		end,
		[Fusion.OnEvent "MouseButton1Down"] = function()
			ButtonState:set(3)

			--Color:set(Theme.Get("Color_Button_Press"):get())
		end,
		[Fusion.OnEvent "MouseButton1Up"] = function()
			ButtonState:set(Hovering:get() and 2 or 1)

			--Color:set(Hovering:get() and Theme.Get("Color_Button_Hover"):get() or Theme.Get("Color_Button_Base"):get())
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
						TooltipStates.HideTask = task.delay(0.45, function()
							TooltipStates.Text:set(Data.Tooltip)
							task.defer(function()
								TooltipStates.Adornee:set(Button)
							end)
						end)
					end)
				end

				Hovering:set(true)
				ButtonState:set(2)

				--Color:set(Theme.Get("Color_Button_Hover"):get())
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

				Hovering:set(false)
				ButtonState:set(1)

				--Color:set(Theme.Get("Color_Button_Base"):get())
			end
		end,
		[Fusion.Cleanup] = function(...)
			if Data.Tooltip then
				task.delay(1 / 30, function()
					if TooltipStates.HideTask then
						task.cancel(TooltipStates.HideTask)
						TooltipStates.HideTask = nil
					end
					TooltipStates.Text:set ""
					TooltipStates.Adornee:set(nil)
				end)
			end
		end,

		Visible = Data.Visible or true,
	}

	local ButtonColor = Fusion.Computed(function()
		--Theme.Get("Color_Button_Base"):get(true)

		if OverwriteState and OverwriteState:get() then
			return (if Data.Mask then Data.Mask else Button).BackgroundColor3
		else
			local State = ButtonState:get()
			return (
				if State == 1 then Theme.Get("Color_Button_Base"):get()
				elseif State == 2 then Theme.Get("Color_Button_Hover"):get()
				elseif State == 3 then Theme.Get("Color_Button_Press"):get()
				else Theme.Get("Color_Button_Base"):get()
			)
		end
	end)

	if Button:IsA("TextButton") then 
		Fusion.Hydrate(Button) { 
			TextColor3 = Theme.Get("Color_Text_Base")
		}
	end

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
