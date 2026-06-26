extends Node2D

@onready var start_position: Marker2D = $StartPosition
@onready var tree: Interactable = $Interactables/Tree

func _on_deathzone_body_entered(body: Node2D) -> void:
	if body is TileMapLayer: return
	print("Player Killed")
	body.velocity = Vector2.ZERO
	body.global_position = start_position.global_position

# In any parent node or level script
func _ready() -> void:
	tree.interacted.connect(heal_tree)

func heal_tree(source: Interactable) -> void:
	var sprite: Sprite2D = source.find_child("Sprite2D")
	sprite.texture = preload("uid://cofm40o8eagvr")
	source.interactable_enabled = false
	source._hide_label()
	print("Tree Healed!")
