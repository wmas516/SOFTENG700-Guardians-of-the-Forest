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
	_update_current_hp(PlayerData.current_health, PlayerData.max_health)
	_restore_player_position()
	
func go_to_defense(_source: Interactable) -> void:
	print("Go to defense")
	PlayerData.save_platforming_position(player.global_position)
	get_tree().change_scene_to_file.call_deferred("res://main/scenes/levels/defense/Defense.tscn")

func go_to_boot_clean(_source: Interactable) -> void:
	print("Go to boot clean")
	PlayerData.save_platforming_position(player.global_position)
	get_tree().change_scene_to_file.call_deferred("res://main/scenes/levels/minigames/CleaningBoot.tscn")

func go_to_tree_trim(_source: Interactable) -> void:
	print("Go to tree trim")
	PlayerData.save_platforming_position(player.global_position)
	get_tree().change_scene_to_file.call_deferred("res://main/scenes/levels/minigames/TreeTrim.tscn")

func go_to_boss(_source: Interactable) -> void:
	print("Go to tree trim")
	PlayerData.save_platforming_position(player.global_position)
	get_tree().change_scene_to_file.call_deferred("res://main/scenes/levels/defense/Boss.tscn")

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

func _restore_player_position() -> void:
	if PlayerData.has_saved_platforming_position:
		player.global_position = PlayerData.saved_platforming_position
	else:
		player.global_position = start_position.global_position
