extends CharacterBody2D
class_name Player

@export var gravity = 400
@export var speed = 125
@export var jump_force = 200

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var active: bool = true
var direction: int = 0
var health: int = 100

func _physics_process(delta: float) -> void:
	if is_on_floor() == false:
		# Gravity
		velocity.y += gravity*delta
		if velocity.y > 500:
			velocity.y = 500
		
	if active:
		if Input.is_action_just_pressed("ui_up") && is_on_floor():
			jump(jump_force)
			
		direction = Input.get_axis("ui_left", "ui_right")
		if direction != 0:
			animated_sprite.flip_h = (direction == -1)
		velocity.x = direction * speed
		
	move_and_slide()
	update_animation(direction)

func update_animation(direction):
	if direction == 0:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("run")
			
func jump(force):
	velocity.y = -force
