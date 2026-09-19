extends CanvasLayer

@onready var portrait_rect: TextureRect = $PortraitRect
@onready var name_label: Label = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/NameLabel
@onready var text_label: RichTextLabel = $PanelContainer/HBoxContainer/MarginContainer2/VBoxContainer/TextLabel
@onready var continue_label: Label = $PanelContainer/HBoxContainer/MarginContainer3/VBoxContainer/ContinueLabel

var typing: bool = false
var typing_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	DialogManager.dialog_started.connect(func(): visible = true)
	DialogManager.dialog_ended.connect(func(): visible = false)
	DialogManager.line_changed.connect(on_line_changed)
	
	var keys = InputMap.action_get_events("Skip")
	var newText: Array[String] = []
	for key in keys:
		newText.append("["+OS.get_keycode_string(key.physical_keycode)+"]")
		
	continue_label.text = continue_label.text.replace("[]", " or ".join(newText))

func on_line_changed(line: DialogLine) -> void:
	name_label.text = line.speaker
	portrait_rect.texture = line.portrait
	text_label.visible_characters = 0
	text_label.text = line.text
	typing = true
	
	typing_tween = create_tween()
	typing_tween.tween_property(text_label, "visible_characters", line.text.length(), line.text.length() * 0.02)
	typing_tween.tween_callback(func(): typing = false)
	
func _unhandled_input(event: InputEvent) -> void:
	if not visible: return
	
	if event.is_action_pressed("Skip"):
		if typing: 
			typing_tween.kill()
			text_label.visible_characters = -1
			typing = false
		else:
			DialogManager.advance()
