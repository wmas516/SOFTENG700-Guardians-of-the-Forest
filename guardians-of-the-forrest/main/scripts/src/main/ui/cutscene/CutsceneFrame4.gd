extends CutsceneFrame

@onready var canvas: CanvasModulate = $CanvasModulate

func _process(delta: float) -> void:
	if (index >= 3):
		var growth := 1.0 + delta * 0.2
		zoom_canvas(growth)
	if (index >= 4):
		canvas.set_modulate(canvas.get_modulate().darkened(0.005))

func zoom_canvas(growth: float) -> void:
	var center := get_viewport_rect().size / 2.0
	var transform := canvas.get_transform()
	transform = Transform2D.IDENTITY.translated(center) * Transform2D.IDENTITY.scaled(Vector2(growth, growth)) * Transform2D.IDENTITY.translated(-center) * transform
	canvas.set_transform(transform)
