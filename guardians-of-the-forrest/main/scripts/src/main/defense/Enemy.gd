extends CharacterBody2D

@onready var rangeRay: RayCast2D = $RayCast2D
@onready var sprite: Sprite2D = $Sprite2D

@export var enabled = false

@export var dest: CollisionObject2D;

@export var damageTimer: Timer
@export var speed = 0.002
var timerOver = false
var destPos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rangeRay.collision_mask = self.collision_mask
	if (dest):
		destPos = dest.global_position
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if (enabled):
		var damaged = getTargetsInRange()
		
		damageTargets(damaged)
		if (destPos):
			#moveTowardTarget(targetPos)
			if (damageTimer && !damageTimer.is_stopped()):
				velocity = Vector2(0, 0)
				pass
			else:
				var direction = global_position.direction_to(destPos)
				velocity = speed * direction
				rotation = direction.angle()
				if (direction.x < 0):
					sprite.flip_v = true
				
			
		move_and_slide()
		
	return

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

func damageTargets(damaged):
	for target in damaged:
		if (target 
		&& target.is_in_group("Tree") 
		&& target.has_method("damage")):
			if (damageTimer):
				if (damageTimer.is_stopped()):
					damageTimer.start()
				elif (timerOver):
					target.damage()
					damage()
			else:
				target.damage()

func _on_damage_timer_timeout() -> void:
	timerOver = true

func setEnabled(enable):
	enabled = enable
	visible = enable
	return

func moveTowardTarget(pos):
	global_position.direction_to(pos)
