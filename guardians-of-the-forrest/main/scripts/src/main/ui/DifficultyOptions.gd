extends PanelContainer

const MENU_ACTION_BUTTON: PackedScene = preload("res://main/scenes/ui/MenuActionButton.tscn")


func _ready() -> void:
	var button_group := ButtonGroup.new()
	for difficulty_name in PlayerData.Difficulty.keys():
		var difficulty_value: PlayerData.Difficulty = PlayerData.Difficulty[difficulty_name]
		var button := MENU_ACTION_BUTTON.instantiate() as Button
		button.name = difficulty_name.capitalize()
		button.set("button_text", difficulty_name.capitalize())
		button.focus_mode = Control.FOCUS_NONE
		button.toggle_mode = true
		button.button_group = button_group
		button.button_pressed = PlayerData.difficulty == difficulty_value
		button.pressed.connect(PlayerData.set_difficulty.bind(difficulty_value))
		$MarginContainer/Buttons.add_child(button)
