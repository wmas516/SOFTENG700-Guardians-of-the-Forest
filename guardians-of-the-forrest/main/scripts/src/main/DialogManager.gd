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
	textLabelWidth = int(DialogBox.panel_container.size.x) - 60

func start_dialog(lines: Array[DialogLine]) -> void:
	PlayerData.player_active = false
	current_lines = lines
	current_index = -1
	dialog_started.emit()
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
	var font: Font = DialogBox.text_label.get_theme_font("normal_font")
	var font_size= DialogBox.text_label.get_theme_font_size("normal_font_size")
	if (font == null):
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
