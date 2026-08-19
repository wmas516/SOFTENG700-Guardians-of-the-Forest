extends CutsceneFrame

@onready var forest: TextureRect = $Forest
@onready var dirt: TextureRect = $Dirt
@onready var bush: TextureRect = $Bush
@onready var shoe: TextureRect = $Shoe


func parallax(dir: Vector2):
	forest.set_position(forest.position + 0.25 * dir)
	dirt.set_position(dirt.position + 0.25 * dir)
	bush.set_position(bush.position + 0.5 * dir)
	shoe.set_position(shoe.position + dir)
	return
