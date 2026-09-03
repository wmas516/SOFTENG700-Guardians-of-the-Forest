extends Node2D

@onready var player: PlatformPlayer = $Gameplay/Player
@onready var start: Marker2D = $Markers/StartPos
@onready var defense_interactable: Interactable = $Gameplay/Interactables/DefenseInteractable


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	defense_interactable.interacted.connect(go_to_defense)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _restore_player_position() -> void:
	if PlayerData.has_saved_platforming_position:
		player.global_position = PlayerData.saved_platforming_position
	else:
		player.global_position = start.global_position

func go_to_defense(_source: Interactable) -> void:
	print("Go to defense")
	PlayerData.save_platforming_position(player.global_position)
	get_tree().change_scene_to_file.call_deferred("res://main/scenes/levels/defense/Defense.tscn")

func _on_deathzone_body_entered(body: Node2D) -> void:
	_restore_player_position()
