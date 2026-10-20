extends Control

const STICK_RADIUS := 82.0
const KNOB_RADIUS := 34.0
const DEADZONE := 0.22
const ACTION_THRESHOLD := 0.28

var _touch_index := -1
var _mouse_down := false
var _direction := Vector2.ZERO
var _active_actions: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process_input(true)


func _draw() -> void:
	var center := size * 0.5
	var knob_center := center + _direction * STICK_RADIUS * 0.68
	draw_circle(center, STICK_RADIUS, Color(0.08, 0.12, 0.10, 0.68))
	draw_arc(center, STICK_RADIUS, 0.0, TAU, 64, Color(1.0, 1.0, 1.0, 0.78), 4.0, true)
	draw_line(center, knob_center, Color(0.88, 0.68, 0.18, 0.82), 8.0, true)
	draw_circle(knob_center, KNOB_RADIUS, Color(0.72, 0.52, 0.12, 0.92))
	draw_arc(knob_center, KNOB_RADIUS, 0.0, TAU, 48, Color(1.0, 1.0, 1.0, 0.9), 3.0, true)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1 and get_global_rect().has_point(event.position):
			_touch_index = event.index
			_update_stick(event.position)
			get_viewport().set_input_as_handled()
		elif not event.pressed and event.index == _touch_index:
			_touch_index = -1
			_reset_stick()
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_stick(event.position)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and _touch_index == -1 and get_global_rect().has_point(event.position):
			_mouse_down = true
			_update_stick(event.position)
			get_viewport().set_input_as_handled()
		elif not event.pressed and _mouse_down:
			_mouse_down = false
			_reset_stick()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _mouse_down:
		_update_stick(event.position)
		get_viewport().set_input_as_handled()


func _update_stick(screen_position: Vector2) -> void:
	var local_position := get_global_transform_with_canvas().affine_inverse() * screen_position
	var offset := local_position - size * 0.5
	_direction = (offset / STICK_RADIUS).limit_length(1.0)
	if _direction.length() < DEADZONE:
		_direction = Vector2.ZERO
	_update_movement_actions()
	queue_redraw()


func _update_movement_actions() -> void:
	_set_action("Left", _direction.x < -ACTION_THRESHOLD)
	_set_action("Right", _direction.x > ACTION_THRESHOLD)
	_set_action("Up", _direction.y < -ACTION_THRESHOLD)
	_set_action("Down", _direction.y > ACTION_THRESHOLD)


func _set_action(action: StringName, should_press: bool) -> void:
	if should_press and not _active_actions.has(action):
		_active_actions[action] = true
		Input.action_press(action)
	elif not should_press and _active_actions.has(action):
		_active_actions.erase(action)
		Input.action_release(action)


func _reset_stick() -> void:
	_direction = Vector2.ZERO
	_update_movement_actions()
	queue_redraw()


func release_movement() -> void:
	_touch_index = -1
	_mouse_down = false
	_reset_stick()


func _exit_tree() -> void:
	release_movement()
