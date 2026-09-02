extends Node

@onready var frame1: Control = $Frame1
@onready var frame2: Control =  $Frame2
@onready var frame3: Control =  $Frame3
@onready var frame4: Control =  $Frame4

var frames: Array[CutsceneFrame] = []
var index = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hideAllFrames()
	disableAllFrames()
	for child in get_children():
		if (child is CutsceneFrame):
			frames.append(child)
	showFrame(index)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_key_pressed(OS.find_keycode_from_string("1")):
		hideAllFrames()
		disableAllFrames()
		showFrame(0)
		
	elif Input.is_key_pressed(OS.find_keycode_from_string("2")):
		hideAllFrames()
		disableAllFrames()
		showFrame(1)
	
	elif Input.is_key_pressed(OS.find_keycode_from_string("3")):
		hideAllFrames()
		disableAllFrames()
		showFrame(2)
	
	elif Input.is_key_pressed(OS.find_keycode_from_string("4")):
		hideAllFrames()
		disableAllFrames()
		showFrame(3)
	

func hideAllFrames():
	for frame in frames:
		frame.visible = false

func disableAllFrames():
	for frame in frames:
		frame.stopFrame()
		frame.process_mode = Node.PROCESS_MODE_DISABLED

func showFrame(frame_index: int):
	index = frame_index
	frames[index].visible  = true
	frames[index].process_mode = Node.PROCESS_MODE_INHERIT
	frames[index].startFrame()

func _on_frame_done() -> void:
	hideAllFrames()
	disableAllFrames()
	index += 1
	if (index >= frames.size()):
		get_tree().change_scene_to_file("res://main/scenes/levels/platforming/Level.tscn")
		
	else:
		showFrame(index)
