local Fusion = require "@pkg/fusion"

local CornerRadius = require "@components/Base/CornerRadius"
local Stroke = require "@components/Base/Stroke"
local Padding = require "@components/Base/Padding"
local BaseButton = require "@components/Base/BaseButton"
local TextField = require "@components/Base/TextField"

return function(Data)
	local EditPrompt = Fusion.New "CanvasGroup" {
		Name = "EditPrompt",
		Visible = false,
		BackgroundTransparency = 0.4,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),

		[Fusion.Children] = {
			Fusion.New "TextButton" {
				Name = "Blocker",
				FontFace = Font.new "rbxasset://fonts/families/SourceSansPro.json",
				TextColor3 = Color3.fromRGB(0, 0, 0),
				Text = "",
				BackgroundTransparency = 1,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 14,
				Size = UDim2.new(1, 0, 1, 0),
			},

			Fusion.New "Frame" {
				Name = "Holder",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				ZIndex = 2,
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = Color3.fromRGB(46, 46, 46),

				[Fusion.Children] = {
					Stroke { Color = Color3.fromRGB(90, 90, 90) },
					Padding { 4, 4, 4, 4 },

					Fusion.New "UISizeConstraint" {
						Name = "UISizeConstraint",
						MinSize = Vector2.new(0, 50),
						MaxSize = Vector2.new(math.huge, 500),
					},

					Fusion.New "TextButton" {
						Name = "Confirm",
						LayoutOrder = 999,
						FontFace = Font.new(
							"rbxasset://fonts/families/Nunito.json",
							Enum.FontWeight.Bold,
							Enum.FontStyle.Normal
						),
						TextColor3 = Color3.fromRGB(204, 204, 204),
						Text = "Confirm",
						AutoButtonColor = false,
						AnchorPoint = Vector2.new(1, 0),
						BackgroundColor3 = Color3.fromRGB(46, 46, 46),
						Position = UDim2.new(0.0774, -4, 0, 4),
						TextScaled = true,
						Size = UDim2.new(0, 135, 0, 24),

						[Fusion.Children] = {
							Stroke {},
							Padding { 4, 0, 0, 0 },
							CornerRadius(),
						},
					},

					Fusion.Hydrate (TextField {}) {
						Name = "NameField",
						LayoutOrder = 10,
						Text = "",
						TextScaled = true,
						PlaceholderText = "Name...",
						Size = UDim2.new(0, 180, 0, 24),
					},

					Fusion.Hydrate (TextField {}) {
						Name = "LineField",
						LayoutOrder = 15,
						Text = "",
						TextScaled = true,
						PlaceholderText = "Line...",
						Size = UDim2.new(0, 180, 0, 24),
					},
				
					Fusion.New "UICorner" {
						Name = "UICorner",
						CornerRadius = UDim.new(0, 2),
					},

					Fusion.New "UIListLayout" {
						Name = "UIListLayout",
						Padding = UDim.new(0, 6),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
					},
				},
			},
		},
	} :: CanvasGroup

	local Holder = EditPrompt.Holder
	local NameField, LineField = Holder.NameField, Holder.LineField
	local Confirm = Holder.Confirm

	local ObjectState = Data.Editing --:: Fusion.Value<string>

	for _, v in EditPrompt.Holder:GetChildren() do
		if v:IsA "GuiButton" then
			local Name = v.Name

			BaseButton { Button = v, OnButtonClick = Data["On" .. Name] }
		end
	end

	local LineFieldVisible = Fusion.Computed(function()
		local State = ObjectState:get()
		return (State and State.Type == "Script") and true or false
	end)

	local Transparency = Fusion.Spring(
		Fusion.Computed(function()
			return ObjectState:get() ~= nil and 0 or 1
		end),
		30,
		1
	)

	local Interactable = Fusion.Computed(function()
		local State = ObjectState:get()
		return State and true or false
	end)

	local Current = 1
	local Order = {
		"NameField",
		"LineField",
	}

	local function Evaluate()
		local Result = {}
		for J = 1, #Order do
			local Field = Holder:FindFirstChild(Order[J])
			if not Field then
				continue
			end

			local Type = Field.Name:match "(.+)Field"

			if #Field.Text:gsub("%s", "") > 0 then
				Result[Type .. "Value"] = Field.Text
			end
		end
		return Result
	end

	Fusion.Hydrate(LineField) {
		Visible = LineFieldVisible,
	}

	for J = 1, #Order do
		local Field = Holder:FindFirstChild(Order[J])
		if not Field then
			continue
		end

		Fusion.Hydrate(Field) {
			Interactable = Interactable,
		}
	end

	Fusion.Hydrate(EditPrompt.Blocker) {
		Interactable = Fusion.Computed(function()
			return ObjectState:get() ~= nil
		end),
		[Fusion.OnEvent "MouseButton1Click"] = function()
			Data.OnEditComplete {
				NameValue = nil,
				LineValue = nil,
			}
		end,
	}

	Fusion.Hydrate(Confirm) {
		[Fusion.OnEvent "MouseButton1Click"] = function()
			local Result = Evaluate()
			Data.OnEditComplete(Result)

			NameField.Text = ""
			LineField.Text = ""
		end,

		Interactable = Interactable,
	}

	Fusion.Observer(ObjectState):onChange(function()
		if ObjectState:get() then
			Current = 1
			NameField:CaptureFocus()
		end
	end)

	for I = 1, #Order do
		local Object = Holder:FindFirstChild(Order[I])
		if not Object then
			continue
		end

		Fusion.Hydrate(Object) {
			[Fusion.OnEvent "FocusLost"] = function(EnterPressed: boolean)
				if not EnterPressed then
					return
				end

				Current += 1

				local Next = Order[Current]
				if not Next then
					Current = 1

					local Result = Evaluate()
					Data.OnEditComplete(Result)
				else
					local NextObject = Holder:FindFirstChild(Next)
					if not NextObject.Visible then
						Current = 1

						local Result = Evaluate()
						Data.OnEditComplete(Result)
						return
					end

					NextObject:CaptureFocus()
					task.defer(function()
						task.wait()
						NextObject.Text = ""
					end)
				end
			end,
		}
	end

	return Fusion.Hydrate(EditPrompt) {
		Visible = if Data.Visible ~= nil then Data.Visible else true,
		GroupTransparency = Transparency,
	} :: CanvasGroup
end
