extends Node

signal dialog_started
signal line_changed(line: DialogLine)
signal dialog_ended

var current_lines: Array[DialogLine] = []
var current_index: int = -1
var active: bool = false

func start_dialog(lines: Array[DialogLine]) -> void:
	current_lines = lines
	current_index = -1
	active = true
	dialog_started.emit()
	advance()

func advance() -> void:
	current_index += 1
	if current_index >= current_lines.size():
		end_dialog()
		return
	line_changed.emit(current_lines[current_index])
	
func end_dialog() -> void:
	active = false
	current_lines = []
	current_index = -1
	dialog_ended.emit()
