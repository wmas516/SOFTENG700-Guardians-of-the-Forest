extends Node

@onready var ending_frame: Control = $EndingFrame

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (PlayerData.narrative == PlayerData.Narrative.SKIP):
		done()
		return
	else:
		ending_frame.startFrame()

func _on_frame_done() -> void:
	done()

func done() -> void:
	$AudioStreamPlayer.stop()
	PlayerData.restart()
	get_tree().change_scene_to_file("res://main/scenes/Main.tscn")
