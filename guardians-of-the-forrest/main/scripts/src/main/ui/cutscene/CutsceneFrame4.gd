extends CutsceneFrame

@onready var forest: TextureRect = $Forest
@onready var dirt: TextureRect = $Dirt
@onready var bush: TextureRect = $Bush
@onready var hills: TextureRect = $Hills
@onready var sky: TextureRect = $Sky

func parallax(dir: Vector2):
	forest.set_position(forest.position + 0.25 * dir)
	dirt.set_position(dirt.position + 0.25 * dir)
	bush.set_position(bush.position + 0.5 * dir)
	sky.set_position(sky.position + dir)
	hills.set_position(hills.position + dir)
	return
