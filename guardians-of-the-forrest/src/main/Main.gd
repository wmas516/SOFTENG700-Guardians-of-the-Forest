extends Node

var level: Node2D

func _ready():
	# Searching specifically for a node named "Level" is much more "secure"
	level = find_child("Level", true, false) as Node2D


func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("CameraSwitch"):
		print("Switching cameras!")
		if level:
			level.run()
		else:
			push_error("Main: Could not find the Level node!")
