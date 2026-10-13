extends Control

@export var hideHelp: bool = false

@onready var menuContainer: MarginContainer = $MenuContainer
@onready var helpButton: Button = $HBoxContainer/HelpButton


signal help

func _ready() -> void:
	helpButton.visible = !hideHelp
	

func _on_help_button_pressed() -> void:
	help.emit()

func _on_menu_button_pressed() -> void:
	menuContainer.set_visible(!menuContainer.visible)
