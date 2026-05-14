extends Node2D

var view: Camera2D

func run():
	# Use "" or "*" for name, but specify "Camera2D" as the type (2nd arg)
	view = find_child("Camera2D", true, false) as Camera2D
	
	if view:
		view.make_current()
		# Toggle enabled to ensure the viewport updates
		view.enabled = true 
		view.zoom = Vector2(0.5,0.5);
		print("Level: Camera found and activated: ", view.name)
	else:
		# Debug: list children to see what is actually there
		print("Level children are: ", get_children())
		push_error("Level: No Camera2D found under Level.")
