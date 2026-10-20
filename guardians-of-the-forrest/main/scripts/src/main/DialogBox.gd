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
	_set_caption_controls_mouse_transparent(self)
	visible = false
	continue_label.text = "Click/Press or use [E] to continue"

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

func _set_caption_controls_mouse_transparent(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_set_caption_controls_mouse_transparent(child)

func _input(event: InputEvent) -> void:
	if not visible:
		return

	var clicked_caption := false
	var click_position := Vector2.ZERO
	if event is InputEventMouseButton:
		clicked_caption = event.pressed and event.button_index == MOUSE_BUTTON_LEFT
		click_position = event.position
	elif event is InputEventScreenTouch:
		clicked_caption = event.pressed
		click_position = event.position

	if clicked_caption and panel_container.get_global_rect().has_point(click_position):
		if text.is_empty():
			_advance_dialog()
		else:
			# Scene-authored boss captions use the Skip action to advance their
			# cutscene freeze logic.
			var skip_event := InputEventAction.new()
			skip_event.action = "Skip"
			skip_event.pressed = true
			Input.parse_input_event(skip_event)
			skip_event = InputEventAction.new()
			skip_event.action = "Skip"
			skip_event.pressed = false
			Input.parse_input_event(skip_event)
		get_viewport().set_input_as_handled()


func _advance_dialog() -> void:
	if typing:
		if typing_tween != null and typing_tween.is_running():
			typing_tween.kill()
		text_label.visible_characters = -1
		typing = false
	else:
		DialogManager.advance()

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
		_advance_dialog()
