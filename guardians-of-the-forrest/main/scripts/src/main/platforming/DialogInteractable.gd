class_name DialogInteractable
extends Area2D

@export var dialog_sequence: DialogSequence
@export var dialog_line: DialogLine
@export var need_to_interact: bool = true
@export var size: Vector2 = Vector2(64, 64):
	set(value):
		size = value
		if is_node_ready():
			_fit_shape_to_size()
@export var interact_action: String = "Heal"
@export var popup_text: String = "Press [] to interact":
	set(value):
		popup_text = value
		if label:
			label.text = value
@export var label_offset: Vector2 = Vector2.ZERO

@onready var label: Label = $Label
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var _player_inside: bool = false
var fade_tween: Tween
var interactable_enabled: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = popup_text
	
	var keys = InputMap.action_get_events("Interact")
	var newText: Array[String] = []
	for key in keys:
		newText.append("["+OS.get_keycode_string(key.physical_keycode)+"]")
		
	label.text = popup_text.replace("[]", " or ".join(newText))
	label.hide()
	
	label.position = Vector2(label_offset.x, label_offset.y)
	_fit_shape_to_size()
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_interact() -> void:
	if dialog_sequence:
		DialogManager.start_dialog(dialog_sequence.lines)
	elif dialog_line:
		DialogManager.start_dialog([dialog_line])
	else:
		print("Interactable has no associated dialog sequence or line.")
		pass

func _unhandled_input(event_input) -> void:
	if need_to_interact and interactable_enabled and _player_inside and event_input.is_action_pressed("Interact"):
		_on_interact()
		get_viewport().set_input_as_handled()
		
func _on_body_entered(body: Node2D) -> void:
	#print("Area entered")
	if interactable_enabled and body.is_in_group("Player"):
		_player_inside = true
		if need_to_interact:
			interactable_enabled = false
			_show_label()
		else:
			_on_interact()

func _on_body_exited(body: Node2D) -> void:
	if interactable_enabled and body.is_in_group("Player"):
		_player_inside = false
		if need_to_interact:
			interactable_enabled = true
			_hide_label()
		else:
			# Disable interactable after leaving for walk in dialogs
			interactable_enabled = false
		
func _show_label() -> void:
	if fade_tween:
		fade_tween.kill()
	label.show()
	fade_tween = create_tween()
	label.modulate.a = 0.0
	fade_tween.tween_property(label, "modulate:a", 1.0, 0.2)
	
func _hide_label() -> void:
	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(label, "modulate:a", 0.0, 0.15)
	fade_tween.tween_callback(label.hide)

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
