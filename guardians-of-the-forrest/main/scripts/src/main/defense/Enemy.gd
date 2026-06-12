extends Node

@onready var rangeRay: RayCast2D = $RayCast2D
@onready var sprite: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rangeRay.collision_mask = self.collision_mask
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var damaged = getTargetsInRange()

	for target in damaged:
		if (target 
		&& target.is_in_group("Tree") 
		&& target.has_method("damage")):
			target.damage()


func damage():
	queue_free()


func getTargetsInRange() -> Array[Node]:
	var collisions: Array[Node] = []
	var exemptCollisions: Array[Node] = []
	var curCollision
	
	while (rangeRay.is_colliding()):
		
		curCollision = rangeRay.get_collider()

		if (curCollision):
			rangeRay.add_exception(curCollision)
			exemptCollisions.append(curCollision)

			collisions.append(getTargetableParent(curCollision))
			
		else:
			break
		
		rangeRay.force_raycast_update()

	for collision in exemptCollisions:
		rangeRay.remove_exception(collision)
	
	return collisions
	

func getTargetableParent(collider: Node) -> Node:
	var current: Node = collider
	
	while current != null:
		if current.is_in_group("Target"):
			return current
			
		current = current.get_parent()
		
		if !current || current == get_tree().root:
			break
	print("valid parent not found")
	return null


func xFlip(xReverse):
	sprite.flip_h = xReverse

	if (xReverse):
		rangeRay.rotation_degrees = 180
	else:
		rangeRay.rotation_degrees = 0
