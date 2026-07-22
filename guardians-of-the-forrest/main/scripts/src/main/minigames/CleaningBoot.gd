extends Node2D

@export var sprites: Array[Sprite2D]

@onready var spotLabel: Label = $HUD/MarginContainer/HBoxContainer/Wave/HBoxContainer/MarginContainer2/CurrentSpots
@onready var completion_panel: Control = $HUD/ReturnBox
@onready var completion_button: Button = $HUD/ReturnBox/ReturnButton

var isDragging = false
var level_complete: bool = false

func _ready():
	spotLabel.text = str(sprites.size())

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

func dragSprite(curSprite):
	if level_complete:
		return
	if curSprite.modulate.a > 0.1:
		curSprite.modulate.a = curSprite.modulate.a - 0.01
	else:
		curSprite.modulate.a = 0
		sprites.erase(curSprite)
		curSprite.queue_free()
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
		if curSpriteRect.has_point(localPos):
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
