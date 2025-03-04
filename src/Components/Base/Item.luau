local StudioService = game:GetService "StudioService"

local Fusion = require "@pkg/fusion"
local Icons = require "@src/Library/Icons"
local Theme = require "@src/Library/Theme"

local CornerRadius = require "@components/Base/CornerRadius"
local Stroke = require "@components/Base/Stroke"
local Padding = require "@components/Base/Padding"
local ItemActionButton = require "@components/Base/ItemActionButton"
local BaseButton = require "@components/Base/BaseButton"
local Icon = require "@components/Base/Icon"

local Color_Server = Color3.fromRGB(38, 217, 100)
local Color_Client = Color3.fromRGB(76, 188, 255)
local Color_Line = Color3.fromRGB(177, 150, 188)

local function GetNameWeight(Name)
	return string.byte(string.lower(string.sub(Name, 1, 1)))
end

return function(Data)
	local NewItem = Fusion.New "Frame" {
		Name = "Item",
		Visible = false,
		BackgroundColor3 = Color3.fromRGB(43, 43, 43),
		Size = UDim2.new(1, 0, 0, 30),
		ZIndex = 0,

		[Fusion.Children] = {
			Stroke {},

			Fusion.New "Frame" {
				Name = "Actions",
				AnchorPoint = Vector2.new(1, 0),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, 1, 0, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Size = UDim2.new(0.3, 0, 1, 0),
				ZIndex = 5,

				[Fusion.Children] = {
					Fusion.New "UIListLayout" {
						Name = "UIListLayout",
						VerticalAlignment = Enum.VerticalAlignment.Center,
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						Padding = UDim.new(0, 4),
						SortOrder = Enum.SortOrder.LayoutOrder,
					},

					ItemActionButton {
						Name = "Edit",
						Icon = "pencil-line",
						LayoutOrder = 1,
					},

					ItemActionButton {
						Name = "Delete",
						Icon = "trash-2",
						IconColor = Color3.fromRGB(216, 80, 80),
						LayoutOrder = 2,
					},
				},
			},

			-- Fusion.New "ImageLabel" {
			-- 	Name = "Icon",
			-- 	ImageColor3 = Color3.fromRGB(216, 216, 216),
			-- 	ScaleType = Enum.ScaleType.Fit,
			-- 	AnchorPoint = Vector2.new(0, 0.5),
			-- 	Image = "rbxassetid://11570895459",
			-- 	BackgroundTransparency = 1,
			-- 	Position = UDim2.new(0, 0, 0.5, 0),
			-- 	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			-- 	Size = UDim2.new(0, 26, 1.36, 0),
			-- },

			Fusion.Hydrate(Icon { 
				Icon = Icons["ITEM_" .. Data.Type or "Script"],
				Color = if Data.RunContext then (if Data.RunContext == 1 then Color_Server else Color_Client) else nil,
			 }) {
				Position = UDim2.new(0, 2, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
			},

			Fusion.New "TextButton" {
				Name = "Button",
				TextWrapped = true,
				Active = false,
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0.7, 0, 1, 8),
				TextColor3 = Color3.fromRGB(204, 204, 204),
				Text = "",
				Selectable = false,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0.5, 0),
			},

			Fusion.New "TextLabel" {
				Name = "Title",
				TextWrapped = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				TextColor3 = Theme.Get("Color_Text_Base"),
				Text = "ModuleScript",
				TextScaled = true,
				RichText = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 28, 0, 0),
				FontFace = Font.new(
					"rbxasset://fonts/families/Nunito.json",
					Enum.FontWeight.Bold,
					Enum.FontStyle.Normal
				),
				TextSize = 14,
				Size = UDim2.new(0.63, 0, 1, 0),

				[Fusion.Children] = {
					Fusion.New "UITextSizeConstraint" {
						Name = "UITextSizeConstraint",
						MaxTextSize = 21,
					},
				},
			},

			CornerRadius(),
			Padding { 4, 4, 4, 4 },
		},
	} :: Frame

	--local Color = Fusion.Value(Color_Base)
	local SearchTerm = Data.SearchTerm
	local SortOrder = Data.SortOrder

	local IsSearched = Fusion.Computed(function()
		if SearchTerm:get() and string.find((Data.Name or "?"):lower(), SearchTerm:get():lower()) then
			return true
		end

		return false
	end)

	BaseButton { Button = NewItem.Button, OnButtonClick = Data.OnOpen, Mask = NewItem, OverwriteState = IsSearched }
	for _, v: GuiBase2d in NewItem.Actions:GetChildren() do
		if v:IsA("GuiButton") then
			local Name = v.Name

			BaseButton { Button = v, OnButtonClick = Data["On" .. Name], Tooltip = Name }
		end
	end

	if Data.Type == "Object" and Data.InstanceType then
		local IconData = StudioService:GetClassIcon(Data.InstanceType)
		if IconData then
			NewItem.Icon.Image = IconData.Image
			NewItem.Icon.Size = UDim2.new(0, (IconData.ImageRectSize.X or 16), 1.364, 0)
			NewItem.Icon.Position = UDim2.new(0, (IconData.ImageRectSize.X or 16) // 4, 0.5, 0)
			NewItem.Icon.ImageRectSize = IconData.ImageRectSize
			NewItem.Icon.ImageRectOffset = IconData.ImageRectOffset
			NewItem.Icon.ImageColor3 = Color3.new(1, 1, 1)
		end
	end

	local LineNumber = Data.LineNumber
	Fusion.Hydrate(NewItem.Title) {
		Text = (Data.Name or "?") .. if LineNumber and LineNumber > 1
			then `  <font color="#{Color_Line:ToHex()}">L. {LineNumber}</font>`
			else "",
	}

	return Fusion.Hydrate(NewItem) {
		Visible = Data.Visible or true,
		BackgroundColor3 = Fusion.Spring(
			Fusion.Computed(function()
				return IsSearched:get() and Theme.Get("Color_Item_Search"):get() or Theme.Get("Color_Item_Base"):get()
			end),
			40,
			0.75
		),
		LayoutOrder = Fusion.Computed(function()
			if SearchTerm:get() and string.find((Data.Name or "?"):lower(), SearchTerm:get():lower()) then
				return -1000
			else
				local Weight = GetNameWeight(Data.Name or "?") or 250
				local IsFolder = Data.Type == "Folder"
				local IsObject = Data.Type == "Object"
				local Order = SortOrder:get() == 1 and Weight or -Weight

				if IsObject then
					Order += 87
				end

				return IsFolder and Order - 150 or Order
			end
		end),
	}
end
