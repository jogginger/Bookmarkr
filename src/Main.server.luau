local ScriptEditorService = game:GetService "ScriptEditorService"
local StudioService = game:GetService "StudioService"
local Selection = game:GetService "Selection"

local Fusion = require "@pkg/fusion"
local MockData = require "@src/Library/MockData"

local WidgetComp = require "@components/Base/Widget"
local ItemComp = require "@components/Base/Item"
local InputComp = require "@components/InputPrompt"
local EditComp = require "@components/EditPrompt"
local BaseButtonComp = require "@components/Base/BaseButton"

local Directory = Fusion.Value {}
local ParentStack = Fusion.Value {}
local TempParentStack = Fusion.Value {}
local OpenName = Fusion.Value "Root"
local Editing = Fusion.Value(nil)
local SearchTerm = Fusion.Value(nil)
local SortOrder = Fusion.Value(1)
local InputPromptState = Fusion.Value(nil)

--local Edit = Widget.Edit

-- Plugin data
local SETTING_KEY = "BOOKMARKR_SETTING"
local Data

--[[
	DATA FORMAT:
	
	l = line number
	c = content
	s = source
	i = instance type/class name
	
	{
		{"NAME", {c = {{"NAME2"}}}}
	}
]]

-- Sets the current directory to a new directory
local function SetDirectory(NewDirectory, Parent)
	if Parent then
		local CurrentParentStack = ParentStack:get()
		table.insert(CurrentParentStack, { Directory:get(), OpenName:get(), NewDirectory })

		ParentStack:set(CurrentParentStack)
	end
	Directory:set(NewDirectory)
end

-- Steps to the upper directory
local function StepUpDirectory()
	if #ParentStack:get() > 0 then
		local CurrentParentStack = ParentStack:get()
		local LastParent = table.remove(CurrentParentStack)

		ParentStack:set(CurrentParentStack)

		OpenName:set(LastParent[2])
		Directory:set(LastParent[1])
	else
		warn "Cannot step up from the root directory."
	end
end

-- Gets the root directory
local function GetRootDirectory()
	return #ParentStack:get() > 0 and ParentStack:get()[1][1] or Directory:get()
end

-- Saves parent directory
local function Save()
	local JSON = game:GetService("HttpService"):JSONEncode(GetRootDirectory())

	if not script.Name:find "Local" then
		task.defer(function()
			plugin:SetSetting(SETTING_KEY, JSON)
			--print(JSON)
		end)
	end
end

-- Gets an object from a path string
function GetObject(Path)
	local Parents = Path:split "."
	local Root = game

	for i, Next in Parents do
		Root = Root:FindFirstChild(Next)
		if Root == nil then
			warn(
				`Bookmarkr:\nFailed to resolve path "{Path}": \nCouldn't find "{Next}" under "{Parents[i - 1] or "game"}"`
			)
			break
		end
	end

	return Root
end

-- Determines an object's type
function GetType(Element)
	--local Name = Element[1]
	local Metadata = Element[2]

	local Type = "Script"

	-- Content found
	if Metadata and Metadata.c then
		Type = "Folder"
	end

	if Metadata and Metadata.i then
		Type = "Object"
	end

	return Type
end

-- Edit an element
function EditElement(ElementData)
	Editing:set(ElementData)
end

-- Commit edits
local function CommitEdits(ElementData, Data)
	local CurrentDirectory = Directory:get()

	local Index = ElementData.Index
	local Name = CurrentDirectory[Index][1]

	CurrentDirectory[Index][1] = Data.NameValue or Name
	if ElementData.Type == "Script" and tonumber(Data.LineValue) then
		if not CurrentDirectory[Index][2] then
			CurrentDirectory[Index][2] = {}
		end
		CurrentDirectory[Index][2].l = tonumber(Data.LineValue)
	end

	task.defer(function()
		Directory:set {}
		Directory:set(CurrentDirectory, true)
		Save()
	end)
end

-- Jumps to a specific directory and pops parent stack elements according to the index provided
local function JumpToDirectory(NewDirectory, StackIndex)
	local Stack = ParentStack:get()
	local StackSize = #Stack

	if StackSize < 1 then
		warn "Stack empty"
		return
	end

	if StackIndex > StackSize then
		warn("Invalid target index:", StackIndex)
		return
	end

	if StackIndex == 0 then
		NewDirectory = Stack[1][1]
		table.clear(Stack)
	else
		-- Remove all entries beyond the target index
		for i = StackSize, StackIndex + 1, -1 do
			table.remove(Stack, i)
		end
	end

	ParentStack:set(Stack)
	Directory:set(NewDirectory)
end

local function BuildTreeAndFindPath(TargetDirectory, Name)
	local resultNode = nil

	local function CreateNode(name, metadata, parent)
		return {
			Name = name,
			Metadata = metadata,
			Parent = parent,
			Children = {},
		}
	end

	local function BuildTree(CurrentDirectory, ParentNode)
		for _, entry in ipairs(CurrentDirectory) do
			local name = entry[1]
			local metadata = entry[2]

			local node = CreateNode(name, metadata, ParentNode)

			if ParentNode then
				table.insert(ParentNode.Children, node)
			end

			if name:lower():find(Name:lower()) then
				resultNode = node
			end

			if metadata and metadata.c then
				BuildTree(metadata.c, node)
			end
		end
	end

	local rootNode = CreateNode("Root", { c = TargetDirectory }, nil)
	BuildTree(TargetDirectory, rootNode)

	return resultNode, rootNode
end

local function TracePathToNode(TargetNode)
	local path = {}
	local currentNode = TargetNode

	while currentNode do
		local directory = (currentNode and currentNode.Metadata) and currentNode.Metadata.c or nil
		table.insert(
			path,
			1,
			{
				directory,
				currentNode.Name,
				(currentNode.Parent and currentNode.Parent.Metadata) and currentNode.Parent.Metadata.c or nil,
			}
		)
		currentNode = currentNode.Parent
	end

	return path
end

local function SearchElement(TargetDirectory, Name)
	local targetNode = BuildTreeAndFindPath(TargetDirectory, Name)

	if targetNode then
		local pathToTarget = TracePathToNode(targetNode)
		local Temp = {}

		for I = 1, #pathToTarget - 1 do
			local Entry = pathToTarget[I]
			local Directory = Entry[1]
			local DirectoryName = Entry[2]
			local Parent = Entry[3]

			if pathToTarget[I][1] ~= TargetDirectory then
				table.insert(Temp, { Parent, DirectoryName, Directory })
			end

			if I == #pathToTarget - 1 then
				SetDirectory(Directory)
			end
		end

		ParentStack:set(Temp)
	else
		print "Not found"
	end
end

local function CreateScriptBookmark(Directory: { [number]: {} }, Script: LuaSourceContainer & Script)
	local Source = Script:GetFullName()
	local ScriptType = Script:IsA "LocalScript" and "Client" or "Server"

	local Document = ScriptEditorService:FindScriptDocument(Script)
	local Line = Document and ({ Document:GetSelection() })[1] or nil

	if not Script:IsA "ModuleScript" then
		if Script.RunContext ~= Enum.RunContext.Legacy then
			ScriptType = Script.RunContext == Enum.RunContext.Server and "Server" or "Client"
		end
	else
		ScriptType = "Module"
	end

	table.insert(
		Directory,
		{
			Script.Name,
			{ l = Line or 1, s = Source, t = if ScriptType == "Module"
				then nil
				else (if ScriptType == "Server" then 1 else 2) },
		}
	)
end

local function CreateInstanceBookmark(Directory: { [number]: {} }, Object: Instance)
	local Path = Object:GetFullName()
	table.insert(Directory, { Object.Name, { s = Path, i = Object.ClassName } })
end

local Callbacks = {
	OnOpen = function(Type, Metadata, self)
		return function()
			if Type == "Folder" then
				OpenName:set(self[1])
				SetDirectory(Metadata.c, Directory:get())
			elseif Type == "Script" then
				if Metadata.s then
					local Script = GetObject(Metadata.s)
					if Script then
						plugin:OpenScript(Script, Metadata.l or nil)
					end
				end
			elseif Type == "Object" then
				if Metadata.s then
					local Object = GetObject(Metadata.s)
					if Object then
						Selection:set { Object }
					end
				end
			end
		end
	end,
	OnEdit = function(Type, Metadata, self)
		return function()
			EditElement {
				Index = table.find(Directory:get(), self),
				Type = Type,
				Metadata = Metadata,
			}
		end
	end,
	OnDelete = function(Type, Metadata, self)
		return function()
			local Current = Directory:get()
			local Index = table.find(Current, self)
			if Index then
				table.remove(Current, Index)
				Directory:set(Current)
			end

			Save()
		end
	end,

	-- For the directory breadcrumbs (jumps to a given directory)
	OnDirectoryOpen = function(Index, NewDirectory)
		JumpToDirectory(NewDirectory, Index)
	end,
}

local ToolbarCallbacks = {
	OnDirectoryUp = function()
		StepUpDirectory()
	end,
	OnFolder = function()
		local Current = Directory:get()
		table.insert(Current, { "New Folder", { c = {} } })

		Directory:set(Current)

		Save()
	end,
	OnBookmark = function()
		local Current = Directory:get()
		local ActiveScript = StudioService.ActiveScript :: LuaSourceContainer?
		local Selection = Selection:get()

		if not ActiveScript and #Selection == 0 then 
			warn(
				`Bookmarkr:\nMust select an instance or open a script first!"`
			)
			return
		end

		-- Will prioritize the active script for bookmarking
		if ActiveScript then
			CreateScriptBookmark(Current, ActiveScript)
			Directory:set(Current)
			Save()
		else
			for I = 1, #Selection do
				local Inst = Selection[I] :: Instance
				if Inst:IsA "LuaSourceContainer" then
					CreateScriptBookmark(Current, Inst)
				else
					CreateInstanceBookmark(Current, Inst)
				end
			end

			Directory:set(Current)
			Save()
		end
	end,
	OnExport = function()
		local Root = Directory:get() -- GetRootDirectory()
		InputPromptState:set { "Export", game:GetService("HttpService"):JSONEncode(Root) }
	end,
	OnImport = function()
		InputPromptState:set { "Import" }
	end,
	OnSearch = function(Text)
		if string.gsub(Text, "%s", "") == "" then
			SearchTerm:set(nil)
			return
		end
		SearchTerm:set(Text)
		local Current = GetRootDirectory()
		SearchElement(Current, Text)
	end,
	OnSort = function()
		local Current = SortOrder:get()
		if Current == 1 then
			SortOrder:set(2)
		else
			SortOrder:set(1)
		end
	end,
}

local Widget = WidgetComp {
	Stack = Fusion.Computed(function()
		local Temp = TempParentStack:get()
		if #Temp > 0 then
			return Temp
		else
			return ParentStack:get()
		end
	end),

	Callbacks = Callbacks,
}

local Items = Widget.Items

Fusion.Hydrate(Items.List) {
	[Fusion.Children] = Fusion.ForPairs(Directory, function(Index: number, Data: { any })
		if not Data[1] then
			return
		end

		if typeof(Data[1]) == "table" and typeof(Data[1][1]) == "string" then
			Data = Data[1]
		end

		local Name = Data[1]
		local Metadata = Data[2]

		local Type = GetType(Data)
		local Tuple = { Type, Metadata, Data }

		--print(Metadata.l)
		return Index, ItemComp {
			Name = Name,
			Type = Type,
			RunContext = if Metadata then Metadata.t else nil,
			LineNumber = if Metadata then Metadata.l else nil,
			InstanceType = if Metadata then Metadata.i else nil,
			Index = Index,

			SearchTerm = SearchTerm,
			SortOrder = SortOrder,

			OnOpen = Callbacks.OnOpen(unpack(Tuple)),
			OnEdit = Callbacks.OnEdit(unpack(Tuple)),
			OnDelete = Callbacks.OnDelete(unpack(Tuple)),
		}
	end, Fusion.cleanup),
}

Fusion.Hydrate(Widget) {
	[Fusion.Children] = {
		EditComp {
			Editing = Editing,
			Visible = true,
			OnEditComplete = function(Data)
				CommitEdits(Editing:get(), Data)
				Editing:set(nil)
			end,
		},
		InputComp {
			InputPrompting = InputPromptState,
			Visible = true,
			OnConfirm = function(Data)
				InputPromptState:set(nil)
				if not Data or not Data.Action then
					return
				end
				if Data.Action == "Import" and Data.InputValue then
					local Input = Data.InputValue

					local Raw
					local Success, Err = pcall(function()
						Raw = game:GetService("HttpService"):JSONDecode(Input)
					end)

					if not Success then
						warn(Err)
						return
					end

					local Current = Directory:get()
					for I = 1, #Raw do
						table.insert(Current, Raw[I])
					end

					Directory:set(Current)
					Save()
				end
			end,
		},
	},
}

Fusion.Hydrate(Widget.Toolbar.Search) {
	[Fusion.OnEvent "FocusLost"] = function()
		local Text = Widget.Toolbar.Search.Text
		ToolbarCallbacks.OnSearch(Text)
	end,
}

local Actions = {
	DirectoryUp = "Step up directory",
	Folder = "Create Folder",
	Bookmark = "Create Bookmark",
}

for _, v in Widget.Toolbar:GetChildren() do
	if v:IsA "GuiButton" then
		local Name = v.Name
		BaseButtonComp { Button = v, OnButtonClick = ToolbarCallbacks["On" .. Name], Tooltip = Actions[Name] or Name }
	end
end

if not script.Name:find "Local" then
	local IsLocal: boolean = if string.find(plugin.Name, ".rbxm") or string.find(plugin.Name, ".lua")
		then true
		else false
	local Icon = IsLocal and "rbxassetid://4627151481" or "rbxassetid://4627151481"

	local PluginToolbar = plugin:CreateToolbar "Bookmarkr [BUILT]"
	local ToolbarButton = PluginToolbar:CreateButton("Toggle", "Toogles the Bookmarkr UI", Icon)
	ToolbarButton.ClickableWhenViewportHidden = true

	local WidgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 512, 512, 256, 256)

	local WidgetDock = plugin:CreateDockWidgetPluginGui("SuiteWidget", WidgetInfo) :: DockWidgetPluginGui
	WidgetDock.Title = "Bookmarkr"
	WidgetDock.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	WidgetDock:BindToClose(function()
		ToolbarButton.Enabled = false
		ToolbarButton:SetActive(false)
		ToolbarButton.Enabled = true
	end)

	ToolbarButton.Click:Connect(function()
		WidgetDock.Enabled = not WidgetDock.Enabled
	end)

	print "Running as plugin"
	Widget.Parent = WidgetDock

	local Saved = plugin:GetSetting(SETTING_KEY)
	Data = Saved and game:GetService("HttpService"):JSONDecode(Saved) or {}
else
	print "Running locally"
	Widget.Parent = script.Parent.Frame
	Widget.Visible = true

	Data = MockData
end

print "Loaded"
SetDirectory(Data)
