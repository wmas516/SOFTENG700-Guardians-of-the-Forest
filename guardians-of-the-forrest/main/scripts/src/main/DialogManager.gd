extends Node

signal dialog_started
signal line_changed(line: DialogLine)
signal dialog_ended

var current_lines: Array[DialogLine] = []
var current_index: int = -1

var textLabelWidth: int
var textIndex = 0
class Word:
	var text: String
	var length: int
	
func _ready() -> void:
	# Wait until the dialog controls have completed their first layout pass so
	# wrapping uses the actual text field width rather than an estimate based on
	# the outer panel.
	await get_tree().process_frame
	if not DialogBox.text_label.resized.is_connected(_update_text_label_width):
		DialogBox.text_label.resized.connect(_update_text_label_width)
	_update_text_label_width()

func _update_text_label_width() -> void:
	var field_width := int(DialogBox.text_label.size.x)
	if field_width >= 100:
		textLabelWidth = field_width
		return

	var panel_width := int(DialogBox.panel_container.size.x)
	if panel_width >= 100:
		textLabelWidth = panel_width - 60
		return

	# The autoload can receive the first dialog before the nested controls have
	# completed layout. Use the viewport as a safe temporary width instead of
	# treating an uninitialized control size as a one-pixel text field.
	textLabelWidth = maxi(1, int(get_viewport().get_visible_rect().size.x) - 120)

func start_dialog(lines: Array[DialogLine]) -> void:
	PlayerData.player_active = false
	current_lines = lines
	current_index = -1
	dialog_started.emit()
	# Showing the CanvasLayer can trigger another layout pass after it has been
	# hidden. Wait for that pass before measuring the first dialog line.
	await get_tree().process_frame
	_update_text_label_width()
	advance()

func advance() -> void:
	current_index += 1
	if current_index >= current_lines.size():
		end_dialog()
		return
	splitTextIntoDialog(current_lines[current_index].text)
	line_changed.emit(current_lines[current_index])
	
func end_dialog() -> void:
	PlayerData.player_active = true
	current_lines = []
	current_index = -1
	dialog_ended.emit()

func splitTextIntoDialog(text: String) -> void:
	_update_text_label_width()
	var font: Font = DialogBox.text_label.get_theme_font("normal_font")
	var font_size= DialogBox.text_label.get_theme_font_size("normal_font_size")
	if (font == null):
		return
	if font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= textLabelWidth:
		return
		
	var currentLine: DialogLine = current_lines.pop_at(current_index)
	var words: Array[Word] = []
	
	for word in text.split(" "):
		var dialog_word := Word.new()
		dialog_word.text = word
		dialog_word.length = word.length()
		words.append(dialog_word)
	
	var length = 0
	var splitNum = 0
	var curText = ""
	while(!words.is_empty()):
		var curWord = words[0]
		var nextText = curText + curWord.text + " "
		
		if (font.get_string_size(nextText, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > textLabelWidth and curText != ""):
			var newDialogLine = DialogLine.new()
			newDialogLine.speaker = currentLine.speaker
			newDialogLine.portrait = currentLine.portrait
			newDialogLine.text = curText + "..."
			current_lines.insert(current_index + splitNum, newDialogLine)
			splitNum += 1
			curText = ""
			length = 0
			
		curText += curWord.text + " "
		length += curWord.length + 1 
		words.remove_at(0)

	if (curText != ""):
		curText.remove_char(-1)
		var newDialogLine = DialogLine.new()
		newDialogLine.speaker = currentLine.speaker
		newDialogLine.portrait = currentLine.portrait
		newDialogLine.text = curText
		current_lines.insert(current_index + splitNum, newDialogLine)
