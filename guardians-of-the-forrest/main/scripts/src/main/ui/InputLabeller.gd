extends Label

@export var action: String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if action:
		var keys = InputMap.action_get_events(action)
		var newText: Array[String] = []
		for key in keys:
			newText.append(OS.get_keycode_string(key.physical_keycode))

		set_text(" or ".join(newText))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
