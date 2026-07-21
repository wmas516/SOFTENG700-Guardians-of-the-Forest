extends Node2D
@onready var start_position: Marker2D = $StartPosition
@onready var tree: Interactable = $Interactables/Tree
@onready var tree_2: Interactable = $Interactables/Tree2
@onready var player: PlatformPlayer = $Player
@onready var current_hp_label: Label = $UI/HUD/MarginContainer/HBoxContainer/Wave/HBoxContainer/MarginContainer2/CurrentHP

var player_dead: bool = false

# In any parent node or level script
func _ready() -> void:
	PlayerData.set_health(100)
	tree.interacted.connect(heal_tree)
	tree_2.interacted.connect(go_to_defense)
	PlayerData.health_changed.connect(_on_player_health_changed)
	PlayerData.player_died.connect(_on_player_died)
	_update_current_hp(PlayerData.current_health, PlayerData.max_health)
	
func go_to_defense(_source: Interactable) -> void:
	print("Go to defense")
	get_tree().change_scene_to_file.call_deferred("res://main/scenes/levels/defense/Defense.tscn")

func heal_tree(source: Interactable) -> void:
	var sprite: Sprite2D = source.find_child("Sprite2D")
	sprite.texture = preload("uid://cofm40o8eagvr")
	source.interactable_enabled = false
	source._hide_label()
	print("Tree Healed!")

func _on_player_health_changed(new_health: int, _max_health: int) -> void:
	if player_dead:
		current_hp_label.text = "0"
		return

	_update_current_hp(new_health, _max_health)

func _on_player_died() -> void:
	player_dead = true
	current_hp_label.text = "0"

func _update_current_hp(new_health: int, _max_health: int) -> void:
	current_hp_label.text = str(maxi(new_health, 0))
