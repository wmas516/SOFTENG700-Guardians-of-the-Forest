extends Control

const BUTTON_TEXTURE: Texture2D = preload("res://resources/icons/Circle Button.png")
const BUTTON_SIZE := Vector2(112.0, 112.0)
const BUTTON_MARGIN := 32.0
const BUTTON_GAP := 16.0
const JOYSTICK_SCRIPT = preload("res://main/scripts/src/main/ui/TouchJoystick.gd")
const JOYSTICK_SIZE := Vector2(200.0, 200.0)

@export_enum("Platforming", "Defense") var control_scheme: String = "Platforming"
@export var menu_container_path: NodePath = ^"../../UI/MarginContainer/Menu/MenuContainer"
@export var tutorial_path: NodePath = ^"../../UI/MarginContainer/Tutorial"

var menu_container: Control
var tutorial: Control

# Pointer IDs map to the action button each pointer is holding. Action counts
# allow a touch and a mouse (or multiple touches) to hold actions safely.
var active_pointers: Dictionary = {}
var active_actions: Dictionary = {}
var action_buttons: Dictionary = {}
var move_joystick: Control


func _ready() -> void:
	_resolve_ui_references()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if control_scheme == "Defense":
		_create_move_joystick()
		_create_action_button("Damage", "ATTACK", true, 1)
	else:
		_create_action_button("Left", "<", false, 0)
		_create_action_button("Right", ">", false, 1)
		_create_action_button("Dash", "DASH", true, 1)
		_create_action_button("Jump", "JUMP", true, 0)
		_create_action_button("Interact", "USE", true, 0)
	_update_controls_visibility()
	get_viewport().size_changed.connect(_update_button_positions)
	set_process(true)


func _resolve_ui_references() -> void:
	menu_container = get_node_or_null(menu_container_path) as Control
	tutorial = get_node_or_null(tutorial_path) as Control
	if menu_container != null and tutorial != null:
		return

	# Scene instances can inherit this script from different UI hierarchies.
	# Fall back to named UI nodes instead of letting stale exported paths break
	# TouchControls initialization.
	var scene_root := get_tree().current_scene
	if scene_root == null:
		scene_root = get_tree().root
	if menu_container == null:
		var menu := scene_root.find_child("Menu", true, false)
		if menu != null:
			menu_container = menu.get_node_or_null("MenuContainer") as Control
	if tutorial == null:
		tutorial = scene_root.find_child("Tutorial", true, false) as Control


func _process(_delta: float) -> void:
	_update_controls_visibility()


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			_press_pointer(event.index, event.position)
		else:
			_release_pointer(event.index)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var pointer_id := "mouse:%d" % event.device
		if event.pressed:
			_press_pointer(pointer_id, event.position)
		else:
			_release_pointer(pointer_id)


func _create_action_button(action: String, caption: String, right_side: bool, index: int) -> void:
	var button := TextureButton.new()
	button.name = action + "TouchButton"
	button.texture_normal = BUTTON_TEXTURE
	button.texture_pressed = BUTTON_TEXTURE
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.custom_minimum_size = BUTTON_SIZE
	button.size = BUTTON_SIZE
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.modulate = Color(1.0, 1.0, 1.0, 0.72)
	button.set_meta("action", action)
	button.set_meta("right_side", right_side)
	button.set_meta("button_index", index)
	button.set_meta("row_index", 1 if action == "Interact" else 0)
	add_child(button)
	action_buttons[action] = button

	var label := Label.new()
	label.text = caption
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	label.add_theme_font_size_override("font_size", 22 if caption.length() <= 2 else 18)
	button.add_child(label)
	_update_button_position(button)


func _create_move_joystick() -> void:
	move_joystick = Control.new()
	move_joystick.name = "MoveJoystick"
	move_joystick.set_script(JOYSTICK_SCRIPT)
	move_joystick.custom_minimum_size = JOYSTICK_SIZE
	move_joystick.size = JOYSTICK_SIZE
	add_child(move_joystick)
	_update_joystick_position()


func _update_button_positions() -> void:
	_update_joystick_position()
	for child in get_children():
		if child is TextureButton:
			_update_button_position(child)


func _update_joystick_position() -> void:
	if move_joystick == null:
		return
	move_joystick.position = Vector2(
		BUTTON_MARGIN,
		get_viewport_rect().size.y - BUTTON_MARGIN - JOYSTICK_SIZE.y
	)


func _update_button_position(button: TextureButton) -> void:
	if control_scheme == "Defense":
		_update_defense_button_position(button)
		return

	var right_side: bool = button.get_meta("right_side")
	var index: int = button.get_meta("button_index")
	var row_index: int = button.get_meta("row_index")
	var x_offset := BUTTON_MARGIN + index * (BUTTON_SIZE.x + BUTTON_GAP)
	var y_position := get_viewport_rect().size.y - BUTTON_MARGIN - BUTTON_SIZE.y - row_index * (BUTTON_SIZE.y + BUTTON_GAP)
	if right_side:
		button.position = Vector2(get_viewport_rect().size.x - x_offset - BUTTON_SIZE.x, y_position)
	else:
		button.position = Vector2(x_offset, y_position)


func _update_defense_button_position(button: TextureButton) -> void:
	var view_size := get_viewport_rect().size
	var bottom := view_size.y - BUTTON_MARGIN - BUTTON_SIZE.y
	match button.name:
		"DamageTouchButton":
			button.position = Vector2(view_size.x - BUTTON_MARGIN - BUTTON_SIZE.x, bottom)


func _update_controls_visibility() -> void:
	if menu_container == null:
		visible = false
		return
	var tutorial_is_visible := tutorial != null and tutorial.visible
	var should_show := PlayerData.touch_controls_enabled and not menu_container.visible and not tutorial_is_visible
	if visible and not should_show:
		_release_all_actions()
	visible = should_show


func _press_pointer(pointer_id: Variant, screen_position: Vector2) -> void:
	if active_pointers.has(pointer_id):
		return
	for child in get_children():
		if child is TextureButton and child.get_global_rect().has_point(screen_position):
			var action: String = child.get_meta("action")
			active_pointers[pointer_id] = action
			_press_action(action)
			get_viewport().set_input_as_handled()
			return


func _release_pointer(pointer_id: Variant) -> void:
	if not active_pointers.has(pointer_id):
		return
	var action: String = active_pointers[pointer_id]
	active_pointers.erase(pointer_id)
	_release_action(action)
	get_viewport().set_input_as_handled()


func _press_action(action: String) -> void:
	var pointer_count := int(active_actions.get(action, 0))
	active_actions[action] = pointer_count + 1
	if pointer_count > 0:
		return

	Input.action_press(action)
	_emit_action_event(action, true)
	_emit_action_event("Skip", true)
	_emit_action_event("Skip", false)
	var button := action_buttons.get(action) as TextureButton
	if button != null:
		button.modulate = Color(0.82, 0.82, 0.82, 0.92)


func _release_action(action: String) -> void:
	if not active_actions.has(action):
		return
	var pointer_count := int(active_actions[action]) - 1
	if pointer_count > 0:
		active_actions[action] = pointer_count
		return

	active_actions.erase(action)
	Input.action_release(action)
	_emit_action_event(action, false)
	var button := action_buttons.get(action) as TextureButton
	if button != null:
		button.modulate = Color(1.0, 1.0, 1.0, 0.72)


func _emit_action_event(action: String, pressed: bool) -> void:
	var action_event := InputEventAction.new()
	action_event.action = action
	action_event.pressed = pressed
	Input.parse_input_event(action_event)


func _release_all_actions() -> void:
	if move_joystick != null and move_joystick.has_method("release_movement"):
		move_joystick.call("release_movement")
	active_pointers.clear()
	for action in active_actions.keys():
		Input.action_release(action)
		_emit_action_event(action, false)
		var button := action_buttons.get(action) as TextureButton
		if button != null:
			button.modulate = Color(1.0, 1.0, 1.0, 0.72)
	active_actions.clear()


func _exit_tree() -> void:
	_release_all_actions()
