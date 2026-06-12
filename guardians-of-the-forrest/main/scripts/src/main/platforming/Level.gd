extends Node2D

@onready var start_position: Marker2D = $StartPosition


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_deathzone_body_entered(body: Node2D) -> void:
	body.velocity = Vector2.ZERO
	body.global_position = start_position.global_position
