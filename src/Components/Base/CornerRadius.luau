
local Fusion = require("@pkg/fusion")

return function(Radius: UDim)
    local CornerRadius = Fusion.New "Frame" {
        CornerRadius = Radius or UDim.new(0, 2);

        Name = "CornerRadius"
    } :: Frame

    return CornerRadius
end
