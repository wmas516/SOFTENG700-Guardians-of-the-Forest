extends Control

@onready var audio_options: Control = $AudioOptions


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_options.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_audio_toggle_pressed() -> void:
	audio_options.visible = not audio_options.visible
	release_focus()
