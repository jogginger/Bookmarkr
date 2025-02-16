
local Fusion = require("@pkg/fusion")

return function(PaddingConfig: {[number]: number})
    local Padding = Fusion.New "UIPadding" {
        PaddingLeft = PaddingConfig[1] or 0;
        PaddingRight = PaddingConfig[2] or 0;
        PaddingTop = PaddingConfig[3] or 0;
        PaddingBottom = PaddingConfig[4] or 0;
        
        Name = "Padding"
    } :: UIPadding

    return Padding
end
