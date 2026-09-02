extends CutsceneFrame

@onready var forest: TextureRect = $CanvasModulate/Forest
@onready var dirt: TextureRect = $CanvasModulate/Dirt
@onready var bush: TextureRect = $CanvasModulate/Bush
@onready var hills: TextureRect = $CanvasModulate/Hills
@onready var sky: TextureRect = $CanvasModulate/Sky

func parallax(dir: Vector2):
	forest.set_position(forest.position + 0.25 * dir * speed)
	dirt.set_position(dirt.position + 0.25 * dir * speed)
	bush.set_position(bush.position + 0.5 * dir * speed)
	sky.set_position(sky.position + dir * speed)
	hills.set_position(hills.position + dir * speed)
	return
	
