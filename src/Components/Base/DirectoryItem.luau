local Fusion = require "@pkg/fusion"

return function(Config)
	local DirectoryItem = Fusion.New "TextButton" {
		Name = "DirectoryItem",
		Visible = false,
		FontFace = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
		Active = false,
		Selectable = false,
		ZIndex = 2,
		Size = UDim2.new(0, 0, 1, 0),
		RichText = true,
		TextColor3 = Color3.fromRGB(158, 158, 158),
		Text = "Root",
		TextSize = 14,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.X,
		TextScaled = true,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),

		[Fusion.Children] = {
			Fusion.New "ImageLabel" {
				Name = "Pointer",
				Visible = false,
				ScaleType = Enum.ScaleType.Fit,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				ImageColor3 = Color3.fromRGB(158, 158, 158),
				Image = "rbxassetid://4726772330",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, 0, 0, 0),
				ZIndex = 2,
				Size = UDim2.new(0, 20, 1, 0),
			},
		},
	} :: Frame

	return DirectoryItem
end
