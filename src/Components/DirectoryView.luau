local Fusion = require "@pkg/fusion"
local Theme = require "@src/Library/Theme"

local CornerRadius = require "@components/Base/CornerRadius"
local Stroke = require "@components/Base/Stroke"
local Padding = require "@components/Base/Padding"
local DirectoryItem = require "@components/Base/DirectoryItem"

return function(Data)
	local DirectoryView = Fusion.New "Frame" {
		Name = "DirectoryView",
		Position = UDim2.new(0, 0, 0, 30),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundColor3 = Theme.Get("Color_Container_Secondary"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 26),

		[Fusion.Children] = {
			Fusion.New "ScrollingFrame" {
				Name = "Directory",
				Active = true,
				AnchorPoint = Vector2.new(0.5, 0.5),
				ScrollingDirection = Enum.ScrollingDirection.X,
				BorderSizePixel = 0,
				CanvasSize = UDim2.new(),
				ScrollBarImageColor3 = Color3.fromRGB(67, 67, 67),
				MidImage = "rbxassetid://1195495135",
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				ScrollBarThickness = 2,
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
				TopImage = "rbxassetid://1195495135",
				Position = UDim2.new(0.5, 0, 0.5, 0),
				ScrollBarImageTransparency = 0.5,
				BottomImage = "rbxassetid://1195495135",
				AutomaticCanvasSize = Enum.AutomaticSize.X,
				BackgroundColor3 = Color3.fromRGB(47, 47, 47),

				[Fusion.Children] = {
					Fusion.New "UIListLayout" {
						Name = "UIListLayout",
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
					},

					Padding { 4, 2, 1, 1 },
				},
			},

			Fusion.New "Frame" {
				Name = "BG",
				Active = true,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundColor3 = Theme.Get("Color_Container_Base"),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BorderSizePixel = 0,
				Selectable = true,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				ZIndex = 0,
				SelectionGroup = true,
				Size = UDim2.new(1, 0, 0, 20),

				[Fusion.Children] = {
					CornerRadius(),
					Padding { 4, 0, 0, 0 },
					Stroke {},
				},
			},

			Padding { 4, 4, 0, 0 },
		},
	} :: Frame

	local ParentStack = Data.Stack
	local Directory = DirectoryView.Directory :: ScrollingFrame

	Fusion.Hydrate(Directory) {
		[Fusion.Children] = DirectoryItem {
			Name = "Root",
			Index = 0,

			ParentStack = ParentStack,
			OnDirectoryOpen = Data.Callbacks.OnDirectoryOpen,
		},
	}

	Fusion.Hydrate(Directory) {
		[Fusion.Children] = Fusion.ForPairs(ParentStack, function(Index: number, ParentEntry: { any })
			--local Parent = ParentEntry[1]
			local Name = ParentEntry[2]
			local Directory = ParentEntry[3]

			return Index,
				DirectoryItem {
					Name = Name,
					Index = Index,
					ParentStack = ParentStack,
					Directory = Directory,

					OnDirectoryOpen = Data.Callbacks.OnDirectoryOpen,
				}
		end, Fusion.cleanup),
	}

	local ListLayout = Directory:FindFirstChildOfClass "UIListLayout"
	if ListLayout then
		ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Directory.CanvasSize = UDim2.fromOffset(ListLayout.AbsoluteContentSize.X, 0)
			Directory.CanvasPosition = Vector2.new(ListLayout.AbsoluteContentSize.X, 0)
		end)
	end

	return Fusion.Hydrate(DirectoryView) {
		Visible = Data.Visible or true,
	}
end
