class_name  TutorialInteractable
extends Area2D

signal interacted(interactable: Interactable)

@export var label_offset: Vector2 = Vector2.ZERO

@export var fadable: Array[Node] = []

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var _player_inside: bool = false
var fade_tween: Array[Tween]
var interactable_enabled: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for item in fadable:
		item.hide()
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
		
func _on_body_entered(body: Node2D) -> void:
	print("Area entered")
	if interactable_enabled and body.is_in_group("Player"):
		_player_inside = true
		_show_label()

func _on_body_exited(body: Node2D) -> void:
	if interactable_enabled and body.is_in_group("Player"):
		_player_inside = false
		_hide_label()
		
func _show_label() -> void:
	if fade_tween:
		for t in fade_tween:
			t.kill()
	for item in fadable:
		item.show()
		fade_tween.append(create_tween())
		item.modulate.a = 0.0
		fade_tween[-1].tween_property(item, "modulate:a", 1.0, 0.2)
	
func _hide_label() -> void:
	if fade_tween:
		for t in fade_tween:
			t.kill()
	for item in fadable:
		fade_tween.append(create_tween())
		fade_tween[-1].tween_property(item, "modulate:a", 0.0, 0.15)
		fade_tween[-1].tween_callback(item.hide)
