
local Fusion = require("@pkg/fusion")

local Stroke = require("@components/Base/Stroke")
local DirectoryView = require("@components/DirectoryView")
local ItemList = require("@components/ItemList")
local Toolbar = require("@components/Toolbar")

return function(Data)
    local Widget = Fusion.New "Frame" {
        BackgroundColor3 = Color3.fromRGB(46, 46, 46);
        BackgroundTransparency = 1;
        Size = UDim2.new(1, 0, 1, 0);

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
        }
    } :: Frame

    return Widget
end
