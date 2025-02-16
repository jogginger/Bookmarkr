
local Fusion = require("@pkg/fusion")

-- local Padding = require("@components/Base/Padding")

return function(Properties)
    local Widget = Fusion.New "Frame" {
        BackgroundColor3 = Color3.fromRGB(46, 46, 46);
        BackgroundTransparency = 1;
        Size = UDim2.new(1, 0, 1, 0);

        Name = "Widget";

        [Fusion.Children] = {

        }
    } :: Frame

    return Widget
end
