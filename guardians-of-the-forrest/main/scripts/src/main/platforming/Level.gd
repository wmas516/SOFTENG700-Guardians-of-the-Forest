extends Node2D

@onready var player: PlatformPlayer = $Gameplay/Player
@onready var screen_fade: CanvasLayer = $ScreenFade

@onready var start_pos: Marker2D = $Markers/StartPos
@onready var defense_pos: Marker2D = $Markers/DefensePos
@onready var minigame_boot_pos: Marker2D = $Markers/MinigameBootPos
@onready var minigame_trim_pos: Marker2D = $Markers/MinigameTrimPos
@onready var forest_floor_pos: Marker2D = $Markers/ForestFloorPos
@onready var cave_pos: Marker2D = $Markers/CavePos

@onready var defense_interactable: Interactable = $Gameplay/Interactables/DefenseInteractable
@onready var minigame_boot_interactable: Interactable = $Gameplay/Interactables/MinigameBootInteractable
@onready var minigame_trim_interactable: Interactable = $Gameplay/Interactables/MinigameTrimInteractable
@onready var boss_interactable: Interactable = $Gameplay/Interactables/BossInteractable
@onready var dialog_interactable: DialogInteractable = $Gameplay/Interactables/DialogInteractable
@onready var dialog_interactable_2: DialogInteractable = $Gameplay/Interactables/DialogInteractable2
@onready var dialog_interactable_3: DialogInteractable = $Gameplay/Interactables/DialogInteractable3
@onready var dialog_interactable_4: DialogInteractable = $Gameplay/Interactables/DialogInteractable4
@onready var dialog_interactable_5: DialogInteractable = $Gameplay/Interactables/DialogInteractable5
@onready var dialog_interactable_6: DialogInteractable = $Gameplay/Interactables/DialogInteractable6
@onready var dialog_interactable_7: DialogInteractable = $Gameplay/Interactables/DialogInteractable7

@onready var defense_blocker: StaticBody2D = $Gameplay/Blockers/DefenseBlocker
@onready var minigame_boot_blocker: StaticBody2D = $Gameplay/Blockers/MinigameBootBlocker
@onready var minigame_trim_blocker: StaticBody2D = $Gameplay/Blockers/MinigameTrimBlocker

var frozen: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	restore_player_position()
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
		dialog_interactable.interactable_enabled = false
		dialog_interactable_2.interactable_enabled = false
	
	# Boot Minigame has been finished
	if progress >= 2:
		minigame_boot_interactable.interactable_enabled = false
		minigame_boot_blocker.disable_collision(true)
		dialog_interactable_3.interactable_enabled = false
		dialog_interactable_4.interactable_enabled = false
		
	# Trimming Minigame has been finished
	if progress >= 3:
		minigame_trim_interactable.interactable_enabled = false
		minigame_trim_blocker.disable_collision(true)
		minigame_trim_blocker.visible = false
		dialog_interactable_5.interactable_enabled = false
		dialog_interactable_6.interactable_enabled = false

func restore_player_position() -> void:
	if PlayerData.has_saved_platforming_position:
		player.global_position = PlayerData.saved_platforming_position
	else:
		player.global_position = start_pos.global_position
	player.play_particle_effect()

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

func _apply_frozen_state(should_freeze: bool) -> void:
	print("freeze")
	for child in get_children():
		if !(child is CanvasLayer || child is AudioStreamPlayer):
			child.set_physics_process(!should_freeze)
			if should_freeze:
				child.process_mode = Node.PROCESS_MODE_DISABLED
			else:
				child.process_mode = Node.PROCESS_MODE_INHERIT

func _on_player_player_died() -> void:
	print("death")
	PlayerData.player_active = false
	await screen_fade.fade_out(0.1)
	restore_player_position()
	await screen_fade.fade_in(0.2)
	PlayerData.player_active = true

func _on_cave_spawn_body_entered(body: Node2D) -> void:
	PlayerData.save_platforming_position(cave_pos.global_position)

func _on_forest_spawn_body_entered(body: Node2D) -> void:
	PlayerData.save_platforming_position(forest_floor_pos.global_position)
