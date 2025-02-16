local Fusion = require "@pkg/fusion"

type StrokeConfig = {
	StrokeMode: Enum.ApplyStrokeMode?,
	JoinMode: Enum.LineJoinMode?,
	Color: Color3?,
}

return function(StrokeConfig: StrokeConfig)
	local Stroke = Fusion.New "UIStroke" {
		ApplyStrokeMode = StrokeConfig.StrokeMode or Enum.ApplyStrokeMode.Border,
		LineJoinMode = StrokeConfig.JoinMode or Enum.LineJoinMode.Round,
		Color = StrokeConfig.Color or Color3.fromRGB(34, 34, 34),

		Name = "Stroke",
	} :: UIStroke

	return Stroke
end
