extends Control

@onready var forest: TextureRect = $Forest
@onready var dirt: TextureRect = $Dirt
@onready var bush: TextureRect = $Bush
@onready var kea: TextureRect = $Kea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if (Input.is_action_pressed("Left")):
		parallaxLeft()
	
	elif (Input.is_action_pressed("Right")):
		parallaxRight()
	
	pass

func parallaxLeft():
	parallax(Vector2(-0.5, 0))
	return

func parallaxRight():
	parallax(Vector2(0.5, 0))
	return
	

func parallax(dir: Vector2):
	forest.set_position(forest.position + 0.25 * dir)
	dirt.set_position(dirt.position + 0.25 * dir)
	bush.set_position(bush.position + 0.5 * dir)
	kea.set_position(kea.position + dir)
	return
