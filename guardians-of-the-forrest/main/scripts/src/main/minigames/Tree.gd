extends StaticBody2D
class_name TreeTrim

@export var infected: bool = false
	
@onready var healthSprite : Node2D = $Healthy
@onready var infectedSprite : Node2D = $Infected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	healthSprite.visible = !infected
	infectedSprite.visible = infected
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
