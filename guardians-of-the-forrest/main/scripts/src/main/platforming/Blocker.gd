extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func disable_collision(disable: bool) -> void:
	collision_shape.set_deferred("disabled", disable)
