extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if PlayerData.open_credits_on_main_menu:
		PlayerData.open_credits_on_main_menu = false
		$Control/MarginContainer/Menu.open_credits()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main/scenes/ui/cutscene/CutScene.tscn")
