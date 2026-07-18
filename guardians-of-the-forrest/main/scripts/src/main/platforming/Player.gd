class_name PlatformPlayer
extends CharacterBody2D

@export var gravity = 400
@export var speed = 125
@export var jump_force = 200
@export var damage_on_hit = 10
@export var knockback_force: float = 300
@export var knockback_duration: float = 0.2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var active: bool = true
var direction: int = 0
var health: int = 100
var invincible: bool = false

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
	handle_collisions()

func handle_collisions() -> void:
	if invincible: return
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider() 
		
		if collider.is_in_group("Enemies"):
			take_damage(get_slide_collision(i))

func take_damage(collision: KinematicCollision2D) -> void:
	PlayerData.take_damage(10)
	apply_knockback(collision.get_normal())
	start_invincibility(1)

func update_animation(direction):
	if direction == 0:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("run")
	
func jump(force):
	velocity.y = -force
	
func start_invincibility(duration: float) -> void:
	invincible = true
	await get_tree().create_timer(duration).timeout
	invincible = false
	
func apply_knockback(normal: Vector2) -> void:
	velocity = normal * knockback_force
	active = false
	await get_tree().create_timer(knockback_duration).timeout
	active = true
