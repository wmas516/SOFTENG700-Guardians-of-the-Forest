extends Control

@onready var right: PlayerTutorial = $"Panel/HBoxContainer/Right/VBoxContainer/Right Jumping Wrap/CenterContainer/Bounds/Right"
@onready var rightBox: VBoxContainer = $Panel/HBoxContainer/Right
@onready var leftBox: VBoxContainer = $Panel/HBoxContainer/Left
@onready var jumpBox: VBoxContainer = $Panel/HBoxContainer/Jump
@onready var rightLabel: Label = $Panel/HBoxContainer/Right/VBoxContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	leftBox.visible = false
	jumpBox.visible = false
	right.attacking = true
	rightLabel.action = "Damage"
	rightLabel._ready()
	right.update_animation(-1)
