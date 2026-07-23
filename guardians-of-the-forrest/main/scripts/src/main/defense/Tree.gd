extends StaticBody2D

signal clicked(tree_name: String)

@onready var healthySprite: Sprite2D = $Healthy
@onready var infectedSprite: Sprite2D = $Infected

@export var healthy = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_pickable = true
	setVisibleHealth()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not healthy:
			clicked.emit(name)
			get_viewport().set_input_as_handled()

func heal():
	healthy = true
	setVisibleHealth()

func damage():
	healthy = false
	setVisibleHealth()


func is_healthy() -> bool:
	return healthy


func setVisibleHealth():
	healthySprite.visible = healthy
	infectedSprite.visible = !healthy
