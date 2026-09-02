extends Control

@onready var master_slider: HSlider = $VBoxContainer/MasterSlider
@onready var music_slider: HSlider = $VBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $VBoxContainer/SFXSlider


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	master_slider.focus_mode = Control.FOCUS_NONE
	music_slider.focus_mode = Control.FOCUS_NONE
	sfx_slider.focus_mode = Control.FOCUS_NONE
	master_slider.release_focus()
	music_slider.release_focus()
	sfx_slider.release_focus()
	
	master_slider.set_value(db_to_linear(AudioServer.get_bus_volume_db(0)))
	sfx_slider.set_value(db_to_linear(AudioServer.get_bus_volume_db(1)))
	music_slider.set_value(db_to_linear(AudioServer.get_bus_volume_db(2)))

func _on_master_slider_drag_ended(value_changed: bool) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(master_slider.value))

func _on_sfx_slider_drag_ended(value_changed: bool) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(sfx_slider.value))

func _on_music_slider_drag_ended(value_changed: bool) -> void:
	AudioServer.set_bus_volume_db(2, linear_to_db(music_slider.value))
