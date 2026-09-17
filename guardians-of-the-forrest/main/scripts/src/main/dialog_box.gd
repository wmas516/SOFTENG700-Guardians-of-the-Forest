extends CanvasLayer

@onready var portrait_rect: TextureRect = $PortraitRect
@onready var name_label: Label = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/NameLabel
@onready var text_label: RichTextLabel = $PanelContainer/HBoxContainer/MarginContainer2/VBoxContainer/TextLabel

var typing: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogManager.dialog_started.connect(func(): visible = true)
	DialogManager.dialog_ended.connect(func(): visible = false)
	DialogManager.line_changed.connect(on_line_changed)

func on_line_changed(line: DialogLine) -> void:
	name_label.text = line.speaker
	portrait_rect.texture = line.portrait
	text_label.visible_characters = 0
	text_label.text = line.text
	typing = true
	
	var tween := create_tween()
	tween.tween_property(text_label, "visible_characters", line.text.length(), line.text.length() * 0.02)
	tween.tween_callback(func(): typing = false)
	
func _unhandled_input(event: InputEvent) -> void:
	if not visible: return
	
	if event.is_action_pressed("Skip"):
		if typing: 
			text_label.visible_characters = -1
			typing = false
		else:
			DialogManager.advance()
