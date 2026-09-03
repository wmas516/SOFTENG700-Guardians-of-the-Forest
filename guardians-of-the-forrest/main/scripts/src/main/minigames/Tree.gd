extends StaticBody2D
class_name TreeTrim

@export var infected: bool = false
	
@onready var healthSprite : Node2D = get_node_or_null("Healthy") as Node2D
@onready var infectedLowSprite: Node2D = get_node_or_null("Infected_Low") as Node2D
@onready var infectedMediumSprite: Node2D = get_node_or_null("infected_Medium") as Node2D
@onready var infectedFullSprite : Node2D = get_node_or_null("Infected_Full") as Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	healthSprite.visible = !infected
	infectedFullSprite.visible = infected
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
