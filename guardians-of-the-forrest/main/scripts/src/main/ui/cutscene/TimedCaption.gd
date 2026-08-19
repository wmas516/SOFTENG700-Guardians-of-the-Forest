class_name TimedCaption
extends Resource

@export var caption: String
@export var displayTime: int

func _init(text: String = "", time: int = 0) -> void:
	caption = text
	displayTime = time
