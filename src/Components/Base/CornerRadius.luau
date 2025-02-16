
local Fusion = require("@pkg/fusion")

return function(Radius: UDim?)
    local CornerRadius = Fusion.New "UICorner" {
        CornerRadius = Radius or UDim.new(0, 2);

        Name = "CornerRadius"
    } :: UICorner

    return CornerRadius
end
