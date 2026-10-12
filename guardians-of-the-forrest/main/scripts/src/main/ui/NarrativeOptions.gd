extends PanelContainer


func _ready() -> void:
	var button_group := ButtonGroup.new()
	for narrative_name in PlayerData.Narrative.keys():
		var narrative_value: PlayerData.Narrative = PlayerData.Narrative[narrative_name]
		var button := Button.new()
		button.name = narrative_name.capitalize()
		button.text = narrative_name.capitalize()
		button.custom_minimum_size.y = 44
		button.focus_mode = Control.FOCUS_NONE
		button.toggle_mode = true
		button.button_group = button_group
		button.button_pressed = PlayerData.narrative == narrative_value
		button.pressed.connect(PlayerData.set_narrative.bind(narrative_value))
		$MarginContainer/Buttons.add_child(button)
