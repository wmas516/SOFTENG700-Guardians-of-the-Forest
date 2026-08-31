class_name PlayerTutorial
extends CharacterBody2D

enum Direction {FORWARD, LEFT, RIGHT}

@export var jump_force = 200
@export var gravity = 400

@export var direction: Direction = Direction.FORWARD
@export var jumping: bool
@export var switch: bool
@export var switchTime: int

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bounds: Control = get_parent() as Control

var ground
var xFlip = 1
var timer: Timer
var last_bounds_size: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_bounds()
	ground = position
	velocity = Vector2.ZERO

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
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
	_update_bounds()

func update_animation(direction):
	if direction == 0:
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

func _update_bounds() -> void:
	if bounds == null:
		return

	var texture := animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame)
	if texture == null:
		return

	var scaled_size := texture.get_size() * animated_sprite.scale.abs()
	if scaled_size == last_bounds_size:
		return
	last_bounds_size = scaled_size
	bounds.custom_minimum_size = scaled_size
	position = scaled_size * 0.5
