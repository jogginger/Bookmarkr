local Fusion = require "@pkg/fusion"

return function(PaddingConfig: { [number]: number })
	local Padding = Fusion.New "UIPadding" {
		PaddingLeft = UDim.new(0, PaddingConfig[1] or 0),
		PaddingRight = UDim.new(0, PaddingConfig[2] or 0),
		PaddingTop = UDim.new(0, PaddingConfig[3] or 0),
		PaddingBottom = UDim.new(0, PaddingConfig[4] or 0),

		Name = "Padding",
	} :: UIPadding

	return Padding
end
