extends CutsceneFrame

@onready var dirt: TextureRect = $Dirt
@onready var bush: TextureRect = $Bush
@onready var kea: TextureRect = $Kea

func parallax(dir: Vector2):
	# forest.set_position(forest.position + 0.25 * dir)
	# dirt.set_position(dirt.position + 0.25 * dir)
	# bush.set_position(bush.position + 0.5 * dir)
	kea.set_position(kea.position + dir)
	return
