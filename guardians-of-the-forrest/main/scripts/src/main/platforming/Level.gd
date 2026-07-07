extends Node2D
@onready var start_position: Marker2D = $StartPosition
@onready var tree: Interactable = $Interactables/Tree
@onready var tree_2: Interactable = $Interactables/Tree2

func _on_deathzone_body_entered(body: Node2D) -> void:
	if body is not PlatformPlayer: return
	PlayerData.take_damage(10)
	body.velocity = Vector2.ZERO
	body.global_position = start_position.global_position
	print("Player Killed")

# In any parent node or level script
func _ready() -> void:
	tree.interacted.connect(heal_tree)
	tree_2.interacted.connect(go_to_defense)
	
func go_to_defense(_source: Interactable) -> void:
	print("Go to defense")
	get_tree().change_scene_to_file.call_deferred("res://main/scenes/levels/defense/Defense.tscn")

func heal_tree(source: Interactable) -> void:
	var sprite: Sprite2D = source.find_child("Sprite2D")
	sprite.texture = preload("uid://cofm40o8eagvr")
	source.interactable_enabled = false
	source._hide_label()
	print("Tree Healed!")
