-- Just used to access certain data across components

local Fusion = require "@pkg/fusion"

local Store = {
    PluginStates = {
        Directory = Fusion.Value {};
        ParentStack = Fusion.Value {};
        TempParentStack = Fusion.Value {};
        OpenName = Fusion.Value "Root";
        Editing = Fusion.Value(nil);
        SortOrder = Fusion.Value(1);
        InputPromptState = Fusion.Value(nil);

        SearchTerm = Fusion.Value(nil);
        SearchIndex = Fusion.Value(1);
        SearchResultCount = Fusion.Value(0);

        CurrentTheme = Fusion.Value("Dark");
    };
    TooltipStates = {
        Adornee = Fusion.Value(nil),
        Text = Fusion.Value("")
    };

    PluginCallbacks = {};
    ToolbarCallbacks = {} :: {
        OnDirectoryUp: () -> (),
        OnFolder: () -> (),
        OnBookmark: () -> (),
        OnExport: () -> (),
        OnImport: () -> (),
        OnSearch: (text: string) -> (),
        OnSearchNavigate: (direction: number) -> (),
        OnSort: () -> ()
    }
}

return Store 