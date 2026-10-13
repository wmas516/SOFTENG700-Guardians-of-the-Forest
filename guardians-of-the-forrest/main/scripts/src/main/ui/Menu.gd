extends Control

@export var hideHelp: bool = false

@onready var menuContainer: MarginContainer = $MenuContainer
@onready var helpButton: Button = $HBoxContainer/HelpButton
@onready var tabs: TabContainer = $MenuContainer/MarginContainer/Audio

var tab_outline: Panel
var hovered_tab: int = -1

signal help

func _ready() -> void:
	helpButton.visible = !hideHelp
	var tab_bar := tabs.get_tab_bar()
	tab_outline = Panel.new()
	tab_outline.z_index = 4
	tab_outline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tab_outline.visible = false
	var outline_style := StyleBoxFlat.new()
	outline_style.bg_color = Color(0, 0, 0, 0)
	outline_style.set_border_width_all(2)
	outline_style.border_color = Color(0.827451, 0.615686, 0, 1)
	tab_outline.add_theme_stylebox_override("panel", outline_style)
	add_child(tab_outline)
	tab_bar.tab_hovered.connect(_on_tab_hovered)
	tab_bar.mouse_exited.connect(_on_tab_mouse_exited)
	tab_bar.resized.connect(_update_tab_outline)
	tabs.resized.connect(_update_tab_outline)
	tabs.tab_changed.connect(_on_tab_changed)


func _on_tab_hovered(index: int) -> void:
	hovered_tab = index
	_update_tab_outline()


func _on_tab_mouse_exited() -> void:
	hovered_tab = -1
	tab_outline.hide()


func _on_tab_changed(_index: int) -> void:
	_update_tab_outline()


func _update_tab_outline() -> void:
	if hovered_tab < 0 or hovered_tab >= tabs.get_tab_count() or hovered_tab == tabs.current_tab or not menuContainer.visible:
		tab_outline.hide()
		return
	var tab_bar := tabs.get_tab_bar()
	var tab_rect := tab_bar.get_tab_rect(hovered_tab)
	var outline_margin := Vector2(8, 4)
	tab_outline.global_position = tab_bar.global_position + tab_rect.position + outline_margin
	tab_outline.size = tab_rect.size - outline_margin * 2
	tab_outline.show()

func _on_help_button_pressed() -> void:
	help.emit()

func _on_menu_button_pressed() -> void:
	menuContainer.set_visible(!menuContainer.visible)
	if not menuContainer.visible:
		tab_outline.hide()
