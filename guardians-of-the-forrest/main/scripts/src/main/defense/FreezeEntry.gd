class_name FreezeEntry
extends Resource

@export var node: NodePath
@export var wave: int = 1
@export var action: StringName = &"Skip"

func _init(pNode: NodePath = NodePath(), pWave: int = 1, pAction: StringName = &"Skip") -> void:
	node = pNode
	wave = pWave
	action = pAction
