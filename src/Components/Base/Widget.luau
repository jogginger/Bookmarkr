
local Fusion = require("@pkg/fusion")

local Stroke = require("@components/Base/Stroke")
local DirectoryView = require("@components/Base/DirectoryView")
local ItemList = require("@components/Base/ItemList")
local Toolbar = require("@components/Base/Toolbar")

return function(Properties)
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

            DirectoryView();
            ItemList();
            Toolbar();
        }
    } :: Frame

    return Widget
end
