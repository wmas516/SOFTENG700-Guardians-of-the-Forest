extends PanelContainer

const CREDITS_PATH := "res://resources/credits/credits.txt"
const SCROLL_SPEED := 24.0
const TITLE_FONT: Font = preload("res://resources/fonts/UIFontTitle.ttf")
const TITLE_FONT_SIZE := 32

@onready var scroll_container: ScrollContainer = $MarginContainer/ScrollContainer
@onready var top_spacer: Control = $MarginContainer/ScrollContainer/Content/TopSpacer
@onready var bottom_spacer: Control = $MarginContainer/ScrollContainer/Content/BottomSpacer
@onready var credits_text: RichTextLabel = $MarginContainer/ScrollContainer/Content/CreditsText

var scroll_position := 0.0


func _ready() -> void:
	var file := FileAccess.open(CREDITS_PATH, FileAccess.READ)
	if file == null:
		push_error("Unable to open credits file: %s" % CREDITS_PATH)
		credits_text.text = "Credits could not be loaded."
		return

	_format_credits(file.get_as_text())
	call_deferred("_position_credits_at_midpoint")
	visibility_changed.connect(_on_visibility_changed)


func _process(delta: float) -> void:
	if not visible:
		return

	var scroll_bar := scroll_container.get_v_scroll_bar()
	var max_scroll := scroll_bar.max_value - scroll_bar.page
	if max_scroll <= 0.0:
		return

	scroll_position += SCROLL_SPEED * delta
	if scroll_position >= max_scroll:
		scroll_position = 0.0
	scroll_container.scroll_vertical = int(scroll_position)


func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		call_deferred("_position_credits_at_midpoint")


func _position_credits_at_midpoint() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_visible_in_tree():
		return
	if scroll_container.size.y <= 0.0:
		return

	top_spacer.custom_minimum_size.y = scroll_container.size.y * 0.5
	bottom_spacer.custom_minimum_size.y = scroll_container.size.y
	scroll_position = 0.0
	scroll_container.scroll_vertical = 0


func _format_credits(source: String) -> void:
	credits_text.clear()
	var lines := source.split("\n", true)
	for index in lines.size():
		var line: String = lines[index].trim_suffix("\r")
		var title_prefix_length := 0
		if line.begins_with("\\t "):
			title_prefix_length = 3
		elif line.begins_with("\t "):
			title_prefix_length = 2

		if title_prefix_length > 0:
			credits_text.push_font(TITLE_FONT)
			credits_text.push_font_size(TITLE_FONT_SIZE)
			credits_text.add_text(line.substr(title_prefix_length))
			credits_text.pop()
			credits_text.pop()
		else:
			credits_text.add_text(line)
		if index < lines.size() - 1:
			credits_text.add_text("\n")
