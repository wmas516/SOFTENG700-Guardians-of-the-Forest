extends StaticBody2D

signal clicked(tree_name: String)

@onready var healthySprite: Node2D = $Healthy
@onready var infectedLowSprite: Node2D = $Infected_Low
@onready var infectedMediumSprite: Node2D = $Infected_Medium
@onready var infectedFullSprite: Node2D = $Infected_Full

@export var healthy = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_pickable = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not healthy:
			clicked.emit(name)
			get_viewport().set_input_as_handled()

func is_healthy() -> bool:
	return healthy
	
func heal():
	healthy = true

func damage():
	healthy = false

func setVisibleHealth(health: int):
	healthySprite.visible = health >= 5
	infectedLowSprite.visible = (health <= 4) and (health >= 3)
	infectedMediumSprite.visible = health == 2
	infectedFullSprite.visible = health < 2
