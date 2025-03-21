local Fusion = require "@pkg/fusion"

local Theme = require "@src/Library/Theme"

local Icon = require "@components/Base/Icon"

return function(Data)
	local DirectoryItem = Fusion.New "TextButton" {
		Name = "DirectoryItem",
		Visible = true,
		FontFace = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
		Active = false,
		Selectable = false,
		ZIndex = 2,
		Size = UDim2.new(0, 0, 1, 0),
		RichText = true,
		--TextColor3 = Theme.Get("Color_Text_Secondary"),
		Text = "Root",
		TextSize = 14,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.X,
		TextScaled = true,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),

		[Fusion.Children] = {
			-- Fusion.New "ImageLabel" {
			-- 	Name = "Pointer",
			-- 	Visible = false,
			-- 	ScaleType = Enum.ScaleType.Fit,
			-- 	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			-- 	ImageColor3 = Theme.Get("Color_Text_Secondary"),
			-- 	Image = "rbxassetid://4726772330",
			-- 	BackgroundTransparency = 1,
			-- 	Position = UDim2.new(1, 0, 0, 0),
			-- 	ZIndex = 2,
			-- 	Size = UDim2.new(0, 20, 1, 0),
			-- },

			Fusion.Hydrate(Icon { 
				Icon = "chevron-right", 
				Color = Theme.Get("Color_Text_Secondary") 
			}) {
				Name = "Pointer",
				Size = UDim2.new(0, 22, 1, 0),
				ZIndex = 2,
				Position = UDim2.new(1, 0, 0, 0),
			}
		},
	} :: Frame

	local PositionValue = Fusion.Value(UDim2.fromScale(0.5, 0))
	local Position = Fusion.Spring(PositionValue, 40, 1)

	local TransparentValue = Fusion.Value(1)
	local Transparency = Fusion.Spring(TransparentValue, 40, 0.75)

	Fusion.Hydrate(DirectoryItem.Pointer) {
		Visible = true,
		ImageTransparency = Transparency,
		Position = Position,
	}

	PositionValue:set(UDim2.fromScale(1, 0))
	TransparentValue:set(0)

	local Index = Data.Index
	local ParentStack = Data.ParentStack

	local Hovering = Fusion.Value(false)
	local Color = Fusion.Computed(function()
		local Length = #ParentStack:get()
		if Index == Length then
			return Theme.Get("Color_Text_Accent1"):get()
		else
			return Hovering:get() and Theme.Get("Color_Text_Hover"):get() or Theme.Get("Color_Text_Secondary"):get()
		end
	end)

	return Fusion.Hydrate(DirectoryItem) {
		Text = Data.Name,
		Visible = Data.Visible or true,
		TextTransparency = Transparency,
		[Fusion.OnEvent "MouseButton1Click"] = function()
			local Index = Data.Index
			local Directory = Data.Directory

			local Length = #ParentStack:get()
			if Index == Length then
				return
			end

			if Data.OnDirectoryOpen then
				Data.OnDirectoryOpen(Index, Directory)
			end
		end,
		[Fusion.OnEvent "MouseEnter"] = function()
			local Length = #ParentStack:get()
			if Index == Length then
				return
			end

			Hovering:set(true)
		end,
		[Fusion.OnEvent "MouseLeave"] = function()
			Hovering:set(false)
		end,
		TextColor3 = Fusion.Spring(Color, 40, 0.75),
	}
end
