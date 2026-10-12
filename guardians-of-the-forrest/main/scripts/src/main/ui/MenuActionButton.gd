@tool
extends Button

var _button_text: String = ""

@export var button_text: String:
	get:
		return _button_text
	set(value):
		_button_text = value
		_update_label()

func _ready() -> void:
	_update_label()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _update_label() -> void:
	if not is_node_ready():
		return
	var label := get_node_or_null("Banner/MarginContainer/Label") as Label
	if label:
		label.text = _button_text
		label.add_theme_color_override("font_color", Color.WHITE)

func _on_mouse_entered() -> void:
	_set_hover_outline(true)
	_set_label_color(Color(0.827451, 0.615686, 0, 1))

func _on_mouse_exited() -> void:
	_set_hover_outline(false)
	_set_label_color(Color.WHITE)

func _on_button_down() -> void:
	_set_hover_outline(true)
	_set_label_color(Color(0.827451, 0.615686, 0, 1))

func _on_button_up() -> void:
	var mouse_over_button := false
	if is_inside_tree() and get_viewport() != null:
		mouse_over_button = get_global_rect().has_point(get_global_mouse_position())
	_set_hover_outline(mouse_over_button)
	_set_label_color(Color(0.827451, 0.615686, 0, 1) if mouse_over_button else Color.WHITE)

func _set_hover_outline(visible: bool) -> void:
	var outline := get_node_or_null("Banner/MarginContainer/HoverOutline") as Panel
	if outline:
		outline.visible = visible

func _set_label_color(color: Color) -> void:
	var label := get_node_or_null("Banner/MarginContainer/Label") as Label
	if label:
		label.add_theme_color_override("font_color", color)
