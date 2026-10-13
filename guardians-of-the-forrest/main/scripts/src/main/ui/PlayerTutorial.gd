class_name PlayerTutorial
extends CharacterBody2D

enum Direction {FORWARD, LEFT, RIGHT}

@export var jump_force = 200
@export var gravity = 400

@export var direction: Direction = Direction.FORWARD
@export var jumping: bool
@export var attacking: bool
@export var switch: bool
@export var switchTime: int
@export var preview_animation: String = ""
@export var DASH_PREVIEW_WAIT := 0.5
@export var DASH_PREVIEW_FORCE := 800.0
@export var DASH_PREVIEW_DURATION := 0.15

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bounds: Control = get_parent() as Control

var ground
var xFlip = 1
var timer: Timer
var last_bounds_size: Vector2 = Vector2.ZERO
var preview_cycle_id: int = 0
var preview_dash_elapsed: float = 0.0
var preview_start_x: float = 0.0
var preview_dashing: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_bounds()
	ground = position
	velocity = Vector2.ZERO

	if jumping:
		jump(jump_force)
		update_animation(0)

	if (switch):
		timer = Timer.new()
		timer.wait_time = switchTime
		timer.one_shot = false
		timer.timeout.connect(_on_timer_timeout)
		add_child(timer)
		timer.start()
	
	if (direction == Direction.LEFT):
		update_animation(-1)
	elif (direction == Direction.RIGHT):
		update_animation(1)
	
	if preview_animation != "" and animated_sprite.sprite_frames.has_animation(preview_animation):
		animated_sprite.flip_h = false
		animated_sprite.play("idle" if preview_animation == "dash" else preview_animation)
		if preview_animation == "dash":
			reset_preview()
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if preview_animation == "dash":
		if preview_dashing:
			preview_dash_elapsed = minf(preview_dash_elapsed + delta, DASH_PREVIEW_DURATION)
			position.x = preview_start_x + (DASH_PREVIEW_FORCE * preview_dash_elapsed)

	# Gravity
	
	if (switch && timer.is_stopped()):
		timer.start()
	
	if (jumping):
		velocity.y += gravity * delta
		if velocity.y > 500:
			velocity.y = 500
		if (ground.y < position.y):
			jump(jump_force)
			
		
		move_and_slide()
		update_animation(direction)
	_update_bounds()

func update_animation(direction):
	if (jumping):
		if animated_sprite.animation != "jump-down":
			animated_sprite.play("jump-down")
	elif(attacking):
		animated_sprite.play("blast-down")
	elif direction == 0:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("run-side")
		if (direction == -1):
			animated_sprite.flip_h = (true)
		else:
			animated_sprite.flip_h = (false)
			
func jump(force):
	velocity.y = -force

func _on_timer_timeout():
	xFlip *= -1
	update_animation(xFlip)

func reset_preview() -> void:
	if preview_animation == "dash":
		preview_cycle_id += 1
		preview_dashing = false
		preview_dash_elapsed = 0.0
		preview_start_x = last_bounds_size.x * absf(scale.x) * 0.5
		velocity = Vector2.ZERO
		position.x = preview_start_x
		animated_sprite.flip_h = false
		animated_sprite.play("idle")
		_run_dash_preview(preview_cycle_id)

func _run_dash_preview(cycle_id: int) -> void:
	while cycle_id == preview_cycle_id and is_inside_tree():
		await get_tree().create_timer(DASH_PREVIEW_WAIT).timeout
		if cycle_id != preview_cycle_id or not is_inside_tree():
			return

		preview_dash_elapsed = 0.0
		preview_dashing = true
		animated_sprite.flip_h = false
		animated_sprite.play(preview_animation)
		await get_tree().create_timer(DASH_PREVIEW_DURATION).timeout
		if cycle_id != preview_cycle_id or not is_inside_tree():
			return

		preview_dashing = false
		position.x = preview_start_x +  DASH_PREVIEW_FORCE * DASH_PREVIEW_DURATION
		velocity = Vector2.ZERO
		animated_sprite.play("idle")
		await get_tree().create_timer(DASH_PREVIEW_WAIT).timeout
		if cycle_id != preview_cycle_id or not is_inside_tree():
			return

		position.x = preview_start_x
		velocity = Vector2.ZERO

func _update_bounds() -> void:
	var texture := animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame)
	if texture == null:
		return

	var scaled_size := texture.get_size() * animated_sprite.scale.abs()
	if scaled_size == last_bounds_size:
		return
	last_bounds_size = scaled_size
	if bounds == null:
		return
	bounds.custom_minimum_size = scaled_size
	if preview_animation != "dash":
		position = scaled_size * 0.5
