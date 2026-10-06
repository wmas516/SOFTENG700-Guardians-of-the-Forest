extends Control

@onready var videoStreamer: VideoStreamPlayer = $MarginContainer/AspectRatioContainer/VideoStreamPlayer
@onready var label: Label = $MarginContainer/Label

@export var video: VideoStreamTheora
@export var instruction: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if instruction:
		label.set_text(instruction)
	
	if videoStreamer:
		videoStreamer.set_stream(video)
		videoStreamer.play()
		videoStreamer.loop = true
		videoStreamer.autoplay = true


func _on_button_pressed() -> void:
	self.visible = false
