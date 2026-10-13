extends Node2D

@export var sprites: Array[Sprite2D]
@export_range(0.01, 60.0, 0.01) var cleaningTime: float = 3.0

@onready var spotLabel: Label = $HUD/MarginContainer/UIPanel/MarginContainer/HBoxContainer/Wave/HBoxContainer/MarginContainer2/CurrentSpots
@onready var completion_panel: Control = $HUD/ReturnBox
@onready var completion_button: Button = $HUD/ReturnBox/ReturnButton

@onready var bootLeft: Sprite2D = $BootLeft
@onready var dirtyLeft: Sprite2D = $BootLeft/Dirty
@onready var bootRight: Sprite2D = $BootRight
@onready var dirtyRight: Sprite2D = $BootRight/Dirty

@onready var areaLeft: StaticBody2D = $Left
@onready var areaRight: StaticBody2D = $Right

@onready var scrubSoundPlayer: AudioStreamPlayer = $ScrubPlayer

@onready var objectiveLabel: Label = $HUD/MarginContainer/Objective/HBoxContainer/MarginContainer/Title
@onready var tutorialVideo: Control = $HUD/MarginContainer/TutorialVideo


var rightFocused: bool = true

var isDragging = false
var level_complete: bool = false
var cleaning_progress: Dictionary = {}


func _ready():
	spotLabel.text = str(sprites.size())
	for sprite in sprites:
		cleaning_progress[sprite] = 0.0
	areaLeft.visible = true
	areaRight.visible = true
	swapFoot()

func _process(delta: float) -> void:
	if level_complete or (tutorialVideo and tutorialVideo.visible):
		scrubSoundPlayer.stop()
		return
	if not isDragging or not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		scrubSoundPlayer.stop()
		return

	var sprite := isPointInsideSprite(get_global_mouse_position())
	if sprite == null:
		scrubSoundPlayer.stop()
		return

	_clean_sprite_for_time(sprite, delta)

func _input(event):
	if level_complete || (tutorialVideo && tutorialVideo.visible):
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			isDragging = event.pressed
			if not isDragging:
				scrubSoundPlayer.stop()

func _clean_sprite_for_time(curSprite: Sprite2D, delta: float) -> void:
	var required_time := maxf(cleaningTime, 0.01)
	var elapsed := float(cleaning_progress.get(curSprite, 0.0)) + delta
	cleaning_progress[curSprite] = elapsed
	curSprite.modulate.a = clampf(1.0 - elapsed / required_time, 0.0, 1.0)
	if not scrubSoundPlayer.is_playing():
		scrubSoundPlayer.play()

	if elapsed < required_time:
		return

	curSprite.modulate.a = 0.0
	sprites.erase(curSprite)
	cleaning_progress.erase(curSprite)
	curSprite.queue_free()
	scrubSoundPlayer.stop()
	if sprites.size() <= 0:
		clearedSprite(sprites.size())
		miniGameOver()
	else:
		clearedSprite(sprites.size())
		objectiveLabel.set_text("Select the other boot")

func isPointInsideSprite(globalPoint: Vector2) -> Sprite2D:
	if sprites == null:
		return null

	for curSprite in sprites:
		var curSpriteRect: Rect2
		var localPos = curSprite.to_local(globalPoint)
		var textureSize = curSprite.texture.get_size()

		if curSprite.centered:
			curSpriteRect = Rect2(-textureSize / 2, textureSize)
		else:
			curSpriteRect = Rect2(Vector2.ZERO, textureSize)
		if curSprite.visible == true && curSpriteRect.has_point(localPos):
			return curSprite
	return null

func clearedSprite(left: int):
	spotLabel.text = str(left)

func miniGameOver():
	print("Boot Cleared")
	level_complete = true
	completion_panel.visible = true

func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main/scenes/levels/platforming/Level.tscn")


func _on_shoe_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	var mouse_event := event as InputEventMouseButton
	if (mouse_event 
	and mouse_event.button_index == MOUSE_BUTTON_LEFT 
	and mouse_event.pressed
	and (rightFocused && !dirtyRight
	or  !rightFocused && !dirtyLeft
	)):
		swapFoot()


func swapFoot():
	rightFocused = !rightFocused
	bootLeft.visible = !rightFocused
	if (dirtyLeft):
		dirtyLeft.visible = !rightFocused
	areaRight.visible = !rightFocused
	
	areaLeft.visible = rightFocused
	if (dirtyRight):
		dirtyRight.visible = rightFocused
	bootRight.visible = rightFocused
	objectiveLabel.set_text("Scrub the boot to clear the myrtle rust")


func _on_menu_help() -> void:
	if (tutorialVideo):
		tutorialVideo.visible = !tutorialVideo.visible
