extends StaticBody2D
class_name TreeTrim

@export var infected: bool = false
	
@onready var healthSprite : Node2D = $Healthy
@onready var infectedLowSprite: Node2D = $Infected_Low
@onready var infectedMediumSprite: Node2D = $infected_Medium
@onready var infectedFullSprite : Node2D = $Infected_Full

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	healthSprite.visible = !infected
	infectedFullSprite.visible = infected
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
