extends CharacterBody2D

@export var gravity = 400
@export var speed = 125

var direction: int = 1

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var wall_ray: RayCast2D = $WallRay
@onready var floor_ray: RayCast2D = $FloorRay

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if wall_ray.is_colliding() or not floor_ray.is_colliding():
		_turn()
	
	velocity.x = direction * speed
	move_and_slide()
	
func _turn() -> void:
	direction *= -1
	sprite_2d.flip_h = direction == -1
	_update_rays()
	
func _update_rays() -> void:
	wall_ray.target_position.x = abs(wall_ray.target_position.x) * direction
	floor_ray.target_position.x = abs(floor_ray.target_position.x) * direction
