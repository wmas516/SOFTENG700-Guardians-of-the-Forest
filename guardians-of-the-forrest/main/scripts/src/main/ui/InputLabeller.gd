extends Label

@export var action: String
@export var action_caption: String = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if action:
		var keys = InputMap.action_get_events(action)
		var newText: Array[String] = []
		for key in keys:
			newText.append(OS.get_keycode_string(key.physical_keycode).strip_edges().to_lower())

		var options := newText
		if not action_caption.is_empty():
			options.append(action_caption)
		set_text(_join_options(options))


func _join_options(options: Array[String]) -> String:
	if options.size() < 2:
		return "" if options.is_empty() else options[0]
	if options.size() == 2:
		return "%s or %s" % [options[0], options[1]]
	var earlier_options: Array[String] = []
	for index in range(options.size() - 1):
		earlier_options.append(options[index])
	return "%s or %s" % [", ".join(earlier_options), options[-1]]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
