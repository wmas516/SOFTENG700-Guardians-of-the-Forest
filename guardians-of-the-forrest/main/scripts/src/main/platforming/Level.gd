extends Node2D

@onready var player: PlatformPlayer = $Gameplay/Player
@onready var start_pos: Marker2D = $Markers/StartPos
@onready var defense_pos: Marker2D = $Markers/DefensePos
@onready var minigame_boot_pos: Marker2D = $Markers/MinigameBootPos
@onready var minigame_trim_pos: Marker2D = $Markers/MinigameTrimPos

@onready var defense_interactable: Interactable = $Gameplay/Interactables/DefenseInteractable
@onready var minigame_boot_interactable: Interactable = $Gameplay/Interactables/MinigameBootInteractable
@onready var minigame_trim_interactable: Interactable = $Gameplay/Interactables/MinigameTrimInteractable


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	defense_interactable.interacted.connect(go_to_defense)
	minigame_boot_interactable.interacted.connect(go_to_boot_clean)
	minigame_trim_interactable.interacted.connect(go_to_tree_trim)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _restore_player_position() -> void:
	if PlayerData.has_saved_platforming_position:
		player.global_position = PlayerData.saved_platforming_position
	else:
		player.global_position = start_pos.global_position

func go_to_defense(_source: Interactable) -> void:
	print("Go to defense")
	PlayerData.save_platforming_position(defense_pos.global_position)
	get_tree().change_scene_to_file.call_deferred("res://main/scenes/levels/defense/Defense.tscn")
	
func go_to_boot_clean(_source: Interactable) -> void:
	print("Go to boot clean")
	PlayerData.save_platforming_position(minigame_boot_pos.global_position)
	get_tree().change_scene_to_file.call_deferred("res://main/scenes/levels/minigames/CleaningBoot.tscn")
	
func go_to_tree_trim(_source: Interactable) -> void:
	print("Go to tree trim")
	PlayerData.save_platforming_position(minigame_trim_pos.global_position)
	get_tree().change_scene_to_file.call_deferred("res://main/scenes/levels/minigames/TreeTrim.tscn")

func _on_deathzone_body_entered(body: Node2D) -> void:
	_restore_player_position()
