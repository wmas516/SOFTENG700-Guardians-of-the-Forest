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
@export var dash_cooldown: float = 1

@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.12

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_indicator: MeshInstance2D = $MeshInstance2D

@onready var dash_audio_player: AudioStreamPlayer = $DashSound
@onready var step_audio_player: AudioStreamPlayer = $FootstepSound
@onready var jump_audio_player: AudioStreamPlayer = $JumpSound
@onready var damage_audio_player: AudioStreamPlayer = $DamageSound

var active: bool = true
var direction: int = 0
var health: int = 100
var invincible: bool = false
var can_dash: bool = true
var dashing: bool = false

# Animation Assistance Variables
var is_hurt: bool = false
var was_on_floor: bool = false
var is_landing: bool = false

# Jump Assistance Variables
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

func _physics_process(delta: float) -> void:
	if dashing:
		spawn_ghost()
	
	if is_on_floor() == false:
		# Gravity
		velocity.y += gravity*delta
		if velocity.y > 500:
			velocity.y = 500
	
	# Coyote time
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta
		
	# Jump buffer
	if Input.is_action_just_pressed("Jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta
	
	if active:
		if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
			velocity.y = -jump_force
			jump_audio_player.play()
			coyote_timer = 0.0
			jump_buffer_timer = 0.0
		
		if Input.is_action_just_pressed("Dash") && can_dash:
			start_dash()
			
		direction = Input.get_axis("Left", "Right")
		if direction != 0:
			animated_sprite.flip_h = (direction == -1)
		
		if not dashing:
			velocity.x = direction * speed
		
	move_and_slide()
	check_landing()
	update_animation(direction)
	handle_collisions()

func handle_collisions() -> void:
	if invincible: return
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider() 
		
		if collider.is_in_group("Enemies"):
			take_damage(get_slide_collision(i))
		elif collider.is_in_group("Bounce"):
			bounce_up(collider.bounce_force)

func take_damage(collision: KinematicCollision2D) -> void:
	is_hurt = true
	PlayerData.take_damage(10)
	bounce_up(knockback_force)
	start_invincibility(1)
	animated_sprite.play("hurt")
	damage_audio_player.play()
	await animated_sprite.animation_finished
	is_hurt = false

func update_animation(direction):
	if is_hurt or is_landing: return
	
	if dashing:
		animated_sprite.play("dash")
		return
	
	if not is_on_floor():
		if velocity.y < -25: 
			if animated_sprite.animation != "jump-up":
				animated_sprite.play("jump-up")
		elif -25 <= velocity.y and velocity.y < 25: 
			if animated_sprite.animation != "jump-top":
				animated_sprite.play("jump-top")
		else: 
			if animated_sprite.animation != "jump-down":
				animated_sprite.play("jump-down")
		return
		
	if direction == 0:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("run")
		if (animated_sprite.get_frame() % 3 == 0):
			step_audio_player.play()

func check_landing() -> void:
	if not was_on_floor and is_on_floor() and not is_landing:
		is_landing = true
		animated_sprite.play("land")
		await animated_sprite.animation_finished
		is_landing = false
	was_on_floor = is_on_floor()

func start_invincibility(duration: float) -> void:
	invincible = true
	await get_tree().create_timer(duration).timeout
	invincible = false

func bounce_up(force: int) -> void:
	velocity.y = -force
	active = false
	await get_tree().create_timer(knockback_duration).timeout
	active = true
	
func start_dash() -> void:
	print("dashing (direction: ", direction, ")")
	dashing = true
	can_dash = false
	dash_indicator.visible = false
	dash_audio_player.play()
	
	var dash_direction := -1 if animated_sprite.flip_h else 1
	velocity.x = dash_direction * dash_force
	
	await get_tree().create_timer(dash_duration).timeout
	dashing = false
	
	await get_tree().create_timer(dash_cooldown).timeout
	dash_indicator.visible = true
	can_dash = true
	
func spawn_ghost() -> void:
	var ghost := Sprite2D.new()
	ghost.texture = animated_sprite.sprite_frames.get_frame_texture(
		animated_sprite.animation, animated_sprite.get_frame()
	)
	ghost.global_position = global_position
	ghost.flip_h = animated_sprite.flip_h
	ghost.scale = animated_sprite.scale
	ghost.modulate = Color(1,1,1,0.4)
	get_parent().add_child(ghost)
	
	var tween := ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.2)
	tween.tween_callback(ghost.queue_free)
