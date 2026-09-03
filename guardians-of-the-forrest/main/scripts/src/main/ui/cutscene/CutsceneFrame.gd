@abstract
class_name CutsceneFrame
extends Control

@export var speed: float = 1
@export var captions: Array[TimedCaption]
@export var nonNarrativeCaptions: Array[TimedCaption]
@onready var label: Label = $MarginContainer/Label
@onready var timer: Timer = $Timer

var index = 0

signal done

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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

func startFrame() -> void:
	index = 0
	timer.stop()
	nextCaption()

func stopFrame() -> void:
	timer.stop()

func nextCaption() -> void:
	if (captions.size() > index):
		label.set_text(captions[index].caption if PlayerData.skip_narrative else nonNarrativeCaptions[index.caption].caption)
		timer.start(captions[index].displayTime if PlayerData.skip_narrative else nonNarrativeCaptions[index.caption].displayTime)
	else:
		done.emit()
	
	index += 1
	

func _on_timer_timeout() -> void:
	nextCaption()
