extends Node2D

@onready var player: PlatformPlayer = $Gameplay/Player
@onready var start_pos: Marker2D = $Markers/StartPos
@onready var defense_pos: Marker2D = $Markers/DefensePos
@onready var minigame_boot_pos: Marker2D = $Markers/MinigameBootPos
@onready var minigame_trim_pos: Marker2D = $Markers/MinigameTrimPos

@onready var defense_interactable: Interactable = $Gameplay/Interactables/DefenseInteractable
@onready var minigame_boot_interactable: Interactable = $Gameplay/Interactables/MinigameBootInteractable
@onready var minigame_trim_interactable: Interactable = $Gameplay/Interactables/MinigameTrimInteractable
@onready var boss_interactable: Interactable = $Gameplay/Interactables/BossInteractable

@onready var defense_blocker: StaticBody2D = $Gameplay/Blockers/DefenseBlocker
@onready var minigame_boot_blocker: StaticBody2D = $Gameplay/Blockers/MinigameBootBlocker
@onready var minigame_trim_blocker: StaticBody2D = $Gameplay/Blockers/MinigameTrimBlocker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_restore_player_position()
	_update_interactables()
	defense_interactable.interacted.connect(go_to_defense)
	minigame_boot_interactable.interacted.connect(go_to_boot_clean)
	minigame_trim_interactable.interacted.connect(go_to_tree_trim)
	boss_interactable.interacted.connect(go_to_boss)
	
func _update_interactables() -> void:
	var progress: int = PlayerData.game_progress_stage
	# Defense has been finished
	if progress >= 1:
		defense_interactable.interactable_enabled = false
		defense_blocker.disable_collision(true)
	
	# Boot Minigame has been finished
	if progress >= 2:
		minigame_boot_interactable.interactable_enabled = false
		minigame_boot_blocker.disable_collision(true)
		
	# Boot Minigame has been finished
	if progress >= 3:
		minigame_trim_interactable.interactable_enabled = false
		minigame_trim_blocker.disable_collision(true)

func _restore_player_position() -> void:
	if PlayerData.has_saved_platforming_position:
		player.global_position = PlayerData.saved_platforming_position
	else:
		player.global_position = start_pos.global_position

func go_to_defense(_source: Interactable) -> void:
	PlayerData.save_platforming_position(defense_pos.global_position)
	PlayerData.update_progress_stage(1)
	get_tree().change_scene_to_file.call_deferred("res://main/scenes/levels/defense/Defense.tscn")
	
func go_to_boot_clean(_source: Interactable) -> void:
	PlayerData.save_platforming_position(minigame_boot_pos.global_position)
	PlayerData.update_progress_stage(2)
	get_tree().change_scene_to_file.call_deferred("res://main/scenes/levels/minigames/CleaningBoot.tscn")
	
func go_to_tree_trim(_source: Interactable) -> void:
	PlayerData.save_platforming_position(minigame_trim_pos.global_position)
	PlayerData.update_progress_stage(3)
	get_tree().change_scene_to_file.call_deferred("res://main/scenes/levels/minigames/TreeTrim.tscn")
	
func go_to_boss(_source: Interactable) -> void:
	get_tree().change_scene_to_file.call_deferred("res://main/scenes/levels/defense/Boss.tscn")

func _on_deathzone_body_entered(body: Node2D) -> void:
	print("death")
	_restore_player_position()
