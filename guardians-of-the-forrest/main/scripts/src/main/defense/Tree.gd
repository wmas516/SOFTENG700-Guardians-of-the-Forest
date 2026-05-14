extends Node


@onready var healthySprite: Sprite2D = $Healthy
@onready var infectedSprite: Sprite2D = $Infected

@export var healthy = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setVisibleHealth()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func heal():
	healthy = true
	setVisibleHealth()

func damage():
	healthy = false
	setVisibleHealth()


func setVisibleHealth():
	healthySprite.visible = healthy
	infectedSprite.visible = !healthy