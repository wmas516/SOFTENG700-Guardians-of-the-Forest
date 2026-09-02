extends Node2D

@export var sprites: Array[Sprite2D]
@export var cleaningRate: float = 0.01

@onready var spotLabel: Label = $HUD/MarginContainer/HBoxContainer/Wave/HBoxContainer/MarginContainer2/CurrentSpots
@onready var completion_panel: Control = $HUD/ReturnBox
@onready var completion_button: Button = $HUD/ReturnBox/ReturnButton

@onready var bootLeft: Sprite2D = $BootLeft
@onready var dirtyLeft: Sprite2D = $BootLeft/Dirty
@onready var bootRight: Sprite2D = $BootRight
@onready var dirtyRight: Sprite2D = $BootRight/Dirty

@onready var areaLeft: StaticBody2D = $Left
@onready var areaRight: StaticBody2D = $Right

@onready var scrubSoundPlayer: AudioStreamPlayer = $ScrubPlayer

var rightFocused: bool = true

var isDragging = false
var level_complete: bool = false

func _ready():
	spotLabel.text = str(sprites.size())
	areaLeft.visible = true
	areaRight.visible = true
	swapFoot()

func _input(event):
	if level_complete:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var curSprite = isPointInsideSprite(event.global_position)
				isDragging = true
				if curSprite:
					dragSprite(curSprite)
			else:
				isDragging = false

	if event is InputEventMouseMotion && isDragging:
		var curSprite = isPointInsideSprite(event.global_position)
		if curSprite:
			dragSprite(curSprite)
		else:
			scrubSoundPlayer.stop()
	else:
		scrubSoundPlayer.stop()

func dragSprite(curSprite):
	if level_complete:
		return
	if curSprite.modulate.a > 0.05:
		curSprite.modulate.a = curSprite.modulate.a - cleaningRate
		if (!scrubSoundPlayer.is_playing()):
			scrubSoundPlayer.play()
			
	else:
		curSprite.modulate.a = 0
		sprites.erase(curSprite)
		curSprite.queue_free()
		scrubSoundPlayer.stop()
		if sprites.size() <= 0:
			clearedSprite(sprites.size())
			miniGameOver()
		else:
			clearedSprite(sprites.size())

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
	get_tree().change_scene_to_file("res://main/scenes/levels/platforming/Platforming.tscn")


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
