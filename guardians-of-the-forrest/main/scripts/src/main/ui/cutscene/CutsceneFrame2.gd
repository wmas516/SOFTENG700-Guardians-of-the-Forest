extends CutsceneFrame

@onready var forest: TextureRect = $Forest
@onready var dirt: TextureRect = $Dirt
@onready var bush: TextureRect = $Bush
@onready var shoe: TextureRect = $Shoe

func _process(delta: float) -> void:
	parallaxRight()
	return

func parallax(dir: Vector2):
	forest.set_position(forest.position + 0.25 * dir * speed)
	dirt.set_position(dirt.position + 0.25 * dir * speed)
	bush.set_position(bush.position + 0.5 * dir * speed)
	shoe.set_position(shoe.position + dir * speed)
	return
