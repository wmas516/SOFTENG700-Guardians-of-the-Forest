class_name PlatformPlayer
extends CharacterBody2D

@export var gravity = 400
@export var speed = 125
@export var jump_force = 200
@export var damage_on_hit = 10

@export var knockback_force: float = 300
@export var knockback_duration: float = 0.2

@export var dash_force: int = 1000
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.5

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var active: bool = true
var direction: int = 0
var health: int = 100
var invincible: bool = false
var can_dash: bool = true
var dashing: bool = false

func _physics_process(delta: float) -> void:
	if is_on_floor() == false:
		# Gravity
		velocity.y += gravity*delta
		if velocity.y > 500:
			velocity.y = 500
		
	if active:
		if Input.is_action_just_pressed("Up") && is_on_floor():
			velocity.y = -jump_force
		
		if Input.is_action_just_pressed("Damage") && can_dash:
			start_dash()
			
		direction = Input.get_axis("Left", "Right")
		if direction != 0:
			animated_sprite.flip_h = (direction == -1)
		
		if not dashing:
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
	
func start_invincibility(duration: float) -> void:
	invincible = true
	await get_tree().create_timer(duration).timeout
	invincible = false
	
func apply_knockback(normal: Vector2) -> void:
	velocity = normal * knockback_force
	active = false
	await get_tree().create_timer(knockback_duration).timeout
	active = true
	
func start_dash() -> void:
	print("start dash")
	dashing = true
	can_dash = false
	
	var dash_direction := direction if direction != 0 else (-1 if animated_sprite.flip_h else 1)
	velocity.x = direction * dash_force
	
	await get_tree().create_timer(dash_duration).timeout
	dashing = false
	
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true
	
