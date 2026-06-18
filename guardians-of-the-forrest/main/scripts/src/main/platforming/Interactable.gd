class_name Interactable
extends Area2D

signal interacted(interactable: Interactable)

@export_group("Appearance")
@export var texture: Texture2D:
	set(value):
		texture = value
		if sprite_2d:
			sprite_2d.texture = value
			_fit_sprite_to_size()
			
@export var size: Vector2 = Vector2(64, 64):
	set(value):
		size = value
		if is_node_ready():
			_fit_sprite_to_size()
			_fit_shape_to_size()

@export_group("Interaction")
@export var popup_text: String = "Press [E] to interact":
	set(value):
		popup_text = value
		if label:
			label.text = value

@export var interact_action: String = "Heal"
@export var label_offset: float = 40.0

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var _player_inside: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_2d.texture = texture
	label.text = popup_text
	label.hide()
	
	label.position = Vector2(-label.size.x/2.0, - label_offset)
	
	_fit_sprite_to_size()
	_fit_shape_to_size()
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
func _unhandled_input(event_input) -> void:
	if _player_inside and event_input.is_action_pressed(interact_action):
		interacted.emit(self)
		get_viewport().set_input_as_handled()
		
func _on_body_entered(body: Node2D) -> void:
	print("Area entered")
	if body.is_in_group("Player"):
		_player_inside = true
		_show_label()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_player_inside = false
		_hide_label()
		
func _show_label() -> void:
	label.show()
	var tween := create_tween()
	label.modulate.a = 0.0
	tween.tween_property(label, "modulate:a", 1.0, 0.2)
	
func _hide_label() -> void:
	var tween := create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 0.15)
	tween.tween_callback(label.hide)
	
func _fit_sprite_to_size() -> void:
	if sprite_2d.texture == null:
		return
	var tex_size := sprite_2d.texture.get_size()
	# Scale sprite so its largest axis fits within the target size
	var scale_factor := minf(size.x / tex_size.x, size.y / tex_size.y)
	sprite_2d.scale = Vector2(scale_factor, scale_factor)


func _fit_shape_to_size() -> void:
	if collision_shape_2d.shape == null:
		return
	match collision_shape_2d.shape.get_class():
		"RectangleShape2D":
			(collision_shape_2d.shape as RectangleShape2D).size = size
		"CircleShape2D":
			# Use half the smallest axis so the circle stays inside the bounds
			(collision_shape_2d.shape as CircleShape2D).radius = minf(size.x, size.y) / 2.0
		"CapsuleShape2D":
			(collision_shape_2d.shape as CapsuleShape2D).radius = minf(size.x, size.y) / 2.0
			(collision_shape_2d.shape as CapsuleShape2D).height = size.y
