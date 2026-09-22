extends Control

@onready var menuContainer: MarginContainer = $MenuContainer

signal help

func _on_help_button_pressed() -> void:
	help.emit()

func _on_menu_button_pressed() -> void:
	menuContainer.set_visible(!menuContainer.get_visible())
