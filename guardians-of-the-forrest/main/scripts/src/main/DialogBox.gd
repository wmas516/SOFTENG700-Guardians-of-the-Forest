extends CanvasLayer

@export var speaker: String = ""
@export_multiline var text: String = ""
@export var speakerImage: Texture2D

@onready var portrait_rect: TextureRect = $MarginContainer/PortraitLayer/PortraitRect
@onready var name_label: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/NameLabel
@onready var text_label: RichTextLabel = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MarginContainer2/VBoxContainer/TextLabel
@onready var continue_label: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MarginContainer3/VBoxContainer/ContinueLabel
@onready var panel_container: PanelContainer = $MarginContainer/PanelContainer

var typing: bool = false
var typing_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	continue_label.text = "Press [] to continue"
	var keys = InputMap.action_get_events("Skip")
	var newText: Array[String] = []
	for key in keys:
		newText.append("[" + OS.get_keycode_string(key.physical_keycode) + "]")
	continue_label.text = continue_label.text.replace("[]", " or ".join(newText))

	# Boss wave interstitials still provide their content on the scene instance,
	# while other dialog boxes are driven by DialogManager.
	if not text.is_empty():
		name_label.text = speaker
		portrait_rect.texture = speakerImage
		text_label.text = text
		text_label.visible_characters = -1
		return

	DialogManager.dialog_started.connect(func(): visible = true)
	DialogManager.dialog_ended.connect(func(): visible = false)
	DialogManager.line_changed.connect(on_line_changed)

func on_line_changed(line: DialogLine) -> void:
	name_label.text = line.speaker
	portrait_rect.texture = line.portrait
	text_label.visible_characters = 0
	text_label.text = line.text
	typing = true
	
	typing_tween = create_tween()
	typing_tween.tween_property(text_label, "visible_characters", line.text.length(), line.text.length() * 0.02)
	typing_tween.tween_callback(func(): typing = false)

func apply_caption(line: DialogLine) -> void:
	speaker = line.speaker
	text = line.text
	speakerImage = line.portrait
	name_label.text = speaker
	portrait_rect.texture = speakerImage
	text_label.text = text
	text_label.visible_characters = -1

func has_caption() -> bool:
	return not text.is_empty()
	
func _unhandled_input(event: InputEvent) -> void:
	if not visible or not text.is_empty(): return
	
	if event.is_action_pressed("Skip"):
		if typing: 
			typing_tween.kill()
			text_label.visible_characters = -1
			typing = false
		else:
			DialogManager.advance()
