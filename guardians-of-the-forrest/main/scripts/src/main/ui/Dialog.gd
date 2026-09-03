extends Control

@onready var speakerLabel: Label = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/NameLabel
@onready var textLabel: RichTextLabel = $PanelContainer/HBoxContainer/MarginContainer2/VBoxContainer/RichTextLabel
@onready var imageLabel: TextureRect = $TextureRect
@export var speaker: String
@export var text: String
@export var speakerImage: CompressedTexture2D

var textArray: Array[String] = []
var textLabelWidth: int
var textIndex = 0

signal captionDone 

class Word:
	var text: String
	var length: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	
	textLabelWidth = int($PanelContainer.size.x) - 60
	
	if (speaker):
		setSpeaker(speaker)
	if (speakerImage):
		setImage(speakerImage)
	if (text):
		setDialog(text)
		
	if (speakerImage):
		setImage(speakerImage)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_event := event as InputEventMouseButton
		if $PanelContainer.get_global_rect().has_point(click_event.global_position):
			nextDialog()
	elif event is InputEventKey and event.pressed and not event.echo and event.is_action_pressed("Skip"):
		nextDialog()
	
func setDialog(text: String) -> void:
	textArray.clear()
	splitTextIntoDialog(text)
	nextDialog()
	
func nextDialog() -> void:
	if (textArray.size()-1 < textIndex):
		finished()
		return
	text = textArray[textIndex]
	if (textArray.size()-1 > textIndex):
		text += "..."
			
	textLabel.text = text
	textIndex += 1

func setSpeaker(speaker: String) -> void:
	speakerLabel.text = speaker

func setImage(speakerImage: CompressedTexture2D) -> void:
	imageLabel.texture = speakerImage

func splitTextIntoDialog(text: String) -> void:
	var words: Array[Word] = []
	var font := textLabel.get_theme_font("normal_font")
	var font_size := textLabel.get_theme_font_size("normal_font_size")
	if (font == null):
		textArray.append(text)
		return
	
	for word in text.split(" "):
		var dialog_word := Word.new()
		dialog_word.text = word
		dialog_word.length = word.length()
		words.append(dialog_word)
		
	var length = 0
	var curText = ""
	while(!words.is_empty()):
		var curWord = words[0]
		var nextText = curText + curWord.text + " "
		
		if (font.get_string_size(nextText, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > textLabelWidth and curText != ""):
			textArray.append(curText)
			curText = ""
			length = 0
			
		curText += curWord.text + " "
		length += curWord.length + 1 
		words.remove_at(0)

	if (curText != ""):
		curText.remove_char(-1)
		textArray.append(curText)

func finished():
	visible = false
	captionDone.emit()
	self.hide()
