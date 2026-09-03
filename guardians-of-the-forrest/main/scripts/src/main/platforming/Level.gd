extends Node2D

@onready var player: PlatformPlayer = $Gameplay/Player
@onready var start: Marker2D = $Markers/Start


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _restore_player_position() -> void:
	if PlayerData.has_saved_platforming_position:
		player.global_position = PlayerData.saved_platforming_position
	else:
		player.global_position = start.global_position


func _on_deathzone_body_entered(body: Node2D) -> void:
	_restore_player_position()
