@abstract
class_name CutsceneFrame
extends Control

@export var captions: Array[TimedCaption]
@onready var label: Label = $MarginContainer/Label
@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nextCaption()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if (Input.is_action_pressed("Left")):
		parallaxLeft()
	
	elif (Input.is_action_pressed("Right")):
		parallaxRight()
	
	pass

func parallaxLeft():
	parallax(Vector2(-0.5, 0))
	return

func parallaxRight():
	parallax(Vector2(0.5, 0))
	return
	

func parallax(dir: Vector2):
	assert(false, "Error: 'parallax' method must be overridden in child class: " + get_script().resource_path)

func nextCaption() -> void:
	if (!captions.is_empty()):
		label.set_text(captions[0].caption) 
		timer.start(captions[0].displayTime)
		captions.remove_at(0)
	

func _on_timer_timeout() -> void:
	nextCaption()
