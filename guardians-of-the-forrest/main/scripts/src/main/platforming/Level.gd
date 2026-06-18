extends Node2D

@onready var start_position: Marker2D = $StartPosition
@onready var portal: Interactable = $Portal

func _on_deathzone_body_entered(body: Node2D) -> void:
	body.velocity = Vector2.ZERO
	body.global_position = start_position.global_position

# In any parent node or level script
func _ready() -> void:
	portal.interacted.connect(_on_interacted)

func _on_interacted(source: Interactable) -> void:
	print("Portal Interacted")
