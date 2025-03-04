local Fusion = require "@pkg/fusion"
local Theme = require "@src/Library/Theme"

type StrokeConfig = {
	StrokeMode: Enum.ApplyStrokeMode?,
	JoinMode: Enum.LineJoinMode?,
	Color: Color3?,
	Transparency: number?,
}

return function(StrokeConfig: StrokeConfig)
	local Stroke = Fusion.New "UIStroke" {
		ApplyStrokeMode = StrokeConfig.StrokeMode or Enum.ApplyStrokeMode.Border,
		LineJoinMode = StrokeConfig.JoinMode or Enum.LineJoinMode.Round,
		Color = StrokeConfig.Color or Theme.Get("Color_Stroke_Base"),
		Transparency = StrokeConfig.Transparency or 0,

		Name = "Stroke",
	} :: UIStroke

	return Stroke
end
