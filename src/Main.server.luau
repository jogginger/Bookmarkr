local _PluginGuiService = game:GetService "PluginGuiService"
local ScriptEditorService = game:GetService "ScriptEditorService"
local StudioService = game:GetService "StudioService"
local Selection = game:GetService "Selection"

local Fusion = require "@pkg/fusion"
local MockData = require "@src/Library/MockData"
local Store = require "@src/Library/Store"

local WidgetComp = require "@components/Widget"
local ItemComp = require "@components/Base/Item"
local InputComp = require "@components/InputPrompt"
local EditComp = require "@components/EditPrompt"
local BaseButtonComp = require "@components/Base/BaseButton"

local PluginStates = Store.PluginStates

local Directory = PluginStates.Directory
local ParentStack = PluginStates.ParentStack
local TempParentStack = PluginStates.TempParentStack
local OpenName = PluginStates.OpenName
local Editing = PluginStates.Editing
local SortOrder = PluginStates.SortOrder
local InputPromptState = PluginStates.InputPromptState
local SearchTerm = PluginStates.SearchTerm

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

--- Sets the current directory to a new directory
local function SetDirectory(NewDirectory, Parent)
	if Parent then
		local CurrentParentStack = ParentStack:get()
		table.insert(CurrentParentStack, { Directory:get(), OpenName:get(), NewDirectory })

		ParentStack:set(CurrentParentStack)
	end
	Directory:set(NewDirectory)
end

--- Steps to the upper directory
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

--- Gets the root directory
local function GetRootDirectory()
	return #ParentStack:get() > 0 and ParentStack:get()[1][1] or Directory:get()
end

--- Saves parent directory
local function Save()
	local JSON = game:GetService("HttpService"):JSONEncode(GetRootDirectory())

	if not script.Name:find "Local" then
		task.defer(function()
			plugin:SetSetting(SETTING_KEY, JSON)
			--print(JSON)
		end)
	end
end

--- Gets an object from a path string
function GetObject(Path): Instance
	local Parents = Path:split "."
	local Root = game

	-- Currently lacks the ability to discern same-name instances, might figure out a way around that

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

--- Determines an object's type
function GetType(Element): string
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

--- Starts editing an element
function EditElement(ElementData)
	Editing:set(ElementData)
end

--- Commits edits to an element's data
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

--- Jumps to a specific directory and pops parent stack elements according to the index provided
local function JumpToDirectory(NewDirectory, StackIndex)
	local Stack = ParentStack:get()
	local StackSize = #Stack

	if StackSize < 1 then
		warn "Bookmarkr:\nStack empty"
		return
	end

	if StackIndex > StackSize then
		warn("Bookmarkr:\nInvalid target index:", StackIndex)
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

type Node = {
	Name: string,
	Metadata: { [string]: string | number | boolean | { any } },
	Parent: Node?,
	Children: { [number?]: Node? },
}

--- Creates a tree structure and searches for nodes where the name contains the searched term (case-insensitive)
local function TreeSearch(TargetDirectory, SearchedName: string)
	local Result = {} :: { [number?]: Node? }
	local Results = 0

	local function CreateNode(Name, Metadata, Parent): Node
		return {
			Name = Name,
			Metadata = Metadata,
			Parent = Parent,
			Children = {},
		}
	end

	local function BuildTree(CurrentDirectory, ParentNode)
		for _, Entry in ipairs(CurrentDirectory) do
			local Name = Entry[1]
			local Metadata = Entry[2]

			local Node = CreateNode(Name, Metadata, ParentNode)

			if ParentNode then
				table.insert(ParentNode.Children, Node)
			end

			if Name:lower():find(SearchedName:lower()) then
				--ResultNode = Node
				table.insert(Result, Node)
				Results += 1
			end

			if Metadata and Metadata.c then
				BuildTree(Metadata.c, Node)
			end
		end
	end

	local RootNode = CreateNode("Root", { c = TargetDirectory }, nil)
	BuildTree(TargetDirectory, RootNode)

	return Result, RootNode, Results
end

--- Given a node, traces parents upwards to construct a path leading to TargetNode
local function TracePathToNode(TargetNode: Node)
	local Path = {}
	local CurrentNode = TargetNode

	while CurrentNode do
		local Directory = (CurrentNode and CurrentNode.Metadata) and CurrentNode.Metadata.c or nil
		table.insert(Path, 1, {
			Directory,
			CurrentNode.Name,
			(CurrentNode.Parent and CurrentNode.Parent.Metadata) and CurrentNode.Parent.Metadata.c or nil,
		})
		CurrentNode = CurrentNode.Parent
	end

	return Path
end

--- Given a directory, searches through elements of that directory by creating a node-tree structure and generating paths to elements with a matching name
local function SearchElement(TargetDirectory, Name: string, SearchIndex: number?)
	local TargetNodes, _, Results = TreeSearch(TargetDirectory, Name)
	if not TargetNodes or Results <= 0 then
		PluginStates.SearchResultCount:set(0)
		return
	end

	local TargetNode = TargetNodes[math.clamp(if SearchIndex then SearchIndex else 1, 1, #TargetNodes)]
	PluginStates.SearchResultCount:set(Results)

	if TargetNode then
		local Path = TracePathToNode(TargetNode)
		local Temp = {}

		for I = 1, #Path - 1 do
			local Entry = Path[I]
			local Directory = Entry[1]
			local DirectoryName = Entry[2]
			local Parent = Entry[3]

			if Path[I][1] ~= TargetDirectory then
				table.insert(Temp, { Parent, DirectoryName, Directory })
			end

			if I == #Path - 1 then
				SetDirectory(Directory)
			end
		end

		ParentStack:set(Temp)
	else
		print "Not found"
	end
end

--- Creates a bookmark for a script
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

	table.insert(Directory, {
		Script.Name,
		{
			l = Line or 1,
			s = Source,
			t = if ScriptType == "Module" then nil else (if ScriptType == "Server" then 1 else 2),
		},
	})
end

--- Creates a bookmark for an instance
local function CreateInstanceBookmark(Directory: { [number]: {} }, Object: Instance)
	local Path = Object:GetFullName()
	table.insert(Directory, { Object.Name, { s = Path, i = Object.ClassName } })
end

--- Validates an input table for importing
local function ValidateInput(InputTable): boolean
	if typeof(InputTable) ~= "table" then
		return false
	end

	if (not InputTable[1]) or (#InputTable <= 0) then
		return false
	end

	return true
end

local function ImportString(JSON: string)
	local Raw
	local Success, Err = pcall(function()
		Raw = game:GetService("HttpService"):JSONDecode(JSON)
	end)

	if not Success then
		warn(`Bookmarkr:\n`, Err)
		return
	end

	local Current = Directory:get()

	-- Format migration
	if Raw and Raw[2] and typeof(Raw[2]) == "string" then
		Raw = Raw[1]
	end

	-- Imported raw object/script bookmark
	if Raw and typeof(Raw[1]) == "string" then
		Raw = { Raw }
	end

	-- Preventing over-nested tables from being imported (would confuse the directory system)
	if Raw and Raw[1] and Raw[1][1] and typeof(Raw[1][1]) ~= "string" then
		warn(`Bookmarkr:\nMalformed input data detected for table:`, { Raw[1] }, `skipping import`)
		return
	end

	for I = 1, #Raw do
		if not ValidateInput(Raw[I]) then
			warn(`Bookmarkr:\nMalformed input data detected for table:`, { Raw[I] }, `skipping import`)
			continue
		end
		table.insert(Current, Raw[I])
	end

	Directory:set(Current)
	Save()
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
			warn(`Bookmarkr:\nMust select an instance or open a script first!"`)
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
		PluginStates.SearchIndex:set(1)

		if string.gsub(Text, "%s", "") == "" then
			PluginStates.SearchResultCount:set(0)
			SearchTerm:set(nil)
			return
		end

		SearchTerm:set(Text)
		local Current = GetRootDirectory()
		SearchElement(Current, Text, PluginStates.SearchIndex:get())
	end,
	OnSearchNavigate = function(Direction)
		local Count = PluginStates.SearchResultCount:get()

		if not SearchTerm:get() or Count <= 1 then
			return
		end

		local Index = PluginStates.SearchIndex:get()
		local NewIndex = Index + Direction
		if NewIndex > Count then
			NewIndex = 1
		elseif NewIndex <= 0 then
			NewIndex = Count
		end

		PluginStates.SearchIndex:set(NewIndex)

		local Current = GetRootDirectory()
		SearchElement(Current, SearchTerm:get(), NewIndex)
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

-- Theme handling
local StudioTheme = settings().Studio.Theme.Name
PluginStates.CurrentTheme:set(StudioTheme)

settings().Studio.ThemeChanged:Connect(function(...)
	task.defer(function()
		local NewTheme = settings().Studio.Theme.Name
		PluginStates.CurrentTheme:set(NewTheme)
	end)
end)

Store.PluginCallbacks = Callbacks
Store.ToolbarCallbacks = ToolbarCallbacks

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

		-- Migration
		if typeof(Data[1]) == "table" and typeof(Data[1][1]) == "string" then
			Data = Data[1]
		end

		local Name = Data[1]
		local Metadata = Data[2]

		local Type = GetType(Data)
		local Tuple = { Type, Metadata, Data }

		--print(Metadata.l)
		return Index,
			ItemComp {
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

					ImportString(Input)
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
	Import = "Import from string",
	Export = "Export directory as string",
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

	--print "Running as plugin"
	Widget.Parent = WidgetDock

	local Saved = plugin:GetSetting(SETTING_KEY)
	Data = Saved and game:GetService("HttpService"):JSONDecode(Saved) or {}

	if Data and Data[2] and typeof(Data[2]) == "string" then
		Data = Data[1]
	end
else
	--print "Running locally"
	Widget.Parent = script.Parent.Frame
	Widget.Visible = true

	Data = MockData
end

--print "Loaded"
SetDirectory(Data)
