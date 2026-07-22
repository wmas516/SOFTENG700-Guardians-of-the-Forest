extends Node2D

@export var sprites: Array[Sprite2D]

@onready var spotLabel: Label = $HUD/MarginContainer/HBoxContainer/Wave/HBoxContainer/MarginContainer2/CurrentSpots

var isDragging = false

func _ready():
	spotLabel.text = str(sprites.size())
	pass

func _input(event):
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
	if curSprite.modulate.a > 0.1:
		curSprite.modulate.a = curSprite.modulate.a - 0.01
	else: 
		curSprite.modulate.a = 0
		sprites.erase(curSprite)
		curSprite.queue_free()
		if (sprites.size() <= 0):
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
		if (curSpriteRect.has_point(localPos)):
			return curSprite
	return null
	
func clearedSprite(left: int):
	#print("[Removed Disease]:")
	#print(" - ", left , " left to go")
	spotLabel.text = str(left)
func miniGameOver():
	print("Boot Cleared")
