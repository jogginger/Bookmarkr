
local Fusion = require("@pkg/fusion")
local Store = require "@src/Library/Store"

local Stroke = require("@components/Base/Stroke")
local DirectoryView = require("@components/DirectoryView")
local ItemList = require("@components/ItemList")
local Toolbar = require("@components/Toolbar")
local Tooltip = require ("@components/Tooltip")

return function(Data)
    Store.TooltipStates = {
        Adornee = Fusion.Value(nil),
        Text = Fusion.Value("")
    }

    local Widget = Fusion.New "Frame" {
        BackgroundColor3 = Color3.fromRGB(46, 46, 46);
        BackgroundTransparency = 1;
        Size = UDim2.new(1, 0, 1, 0);
        ClipsDescendants = false;

        Name = "Widget";

        [Fusion.Children] = {
            Stroke {
                StrokeMode = Enum.ApplyStrokeMode.Contextual;
                JoinMode = Enum.LineJoinMode.Miter
            };

            DirectoryView {
                Stack = Data.Stack;
                Callbacks = Data.Callbacks;
                Visible = true;
            };
            ItemList();
            Toolbar();
            Tooltip {
                Adornee = Store.TooltipStates.Adornee,
                Text = Store.TooltipStates.Text
            }
        }
    } :: Frame

    return Widget
end
