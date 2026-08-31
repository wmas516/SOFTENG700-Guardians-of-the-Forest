extends Node

@onready var frame2: Control =  $Frame2
@onready var frame3: Control =  $Frame3
@onready var frame4: Control =  $Frame4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hideAllFrames()
	disableAllFrames()
	frame2.visible = true
	frame2.process_mode = Node.PROCESS_MODE_INHERIT
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(OS.find_keycode_from_string("2")):
		hideAllFrames()
		disableAllFrames()
		frame2.visible = true
		frame2.process_mode = Node.PROCESS_MODE_INHERIT
	
	elif Input.is_key_pressed(OS.find_keycode_from_string("3")):
		hideAllFrames()
		disableAllFrames()
		frame3.visible =  true
		frame3.process_mode = Node.PROCESS_MODE_INHERIT
	
	elif Input.is_key_pressed(OS.find_keycode_from_string("4")):
		hideAllFrames()
		disableAllFrames()
		frame4.visible =  true
		frame4.process_mode = Node.PROCESS_MODE_INHERIT
	

func hideAllFrames():
	frame2.visible = false
	frame3.visible = false
	frame4.visible = false

func disableAllFrames():
	frame2.process_mode = Node.PROCESS_MODE_DISABLED
	frame3.process_mode = Node.PROCESS_MODE_DISABLED
	frame4.process_mode = Node.PROCESS_MODE_DISABLED
