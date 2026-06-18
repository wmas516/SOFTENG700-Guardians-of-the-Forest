extends CharacterBody2D
class_name PlayerDef

@export var speed = 125

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var rangeRay: RayCast2D = $Range

func _ready() -> void:
	rangeRay.collision_mask = self.collision_mask
	return

func _physics_process(delta: float) -> void:

	var x = Input.get_axis("Left", "Right")
	var y = Input.get_axis("Up", "Down")

	velocity.y = (speed * y)
	velocity.x = (speed * x)

	flip(x < 0)

	if(Input.is_action_just_pressed("Heal")):
		var healed = getTargetsInRange()

		for target in healed:
			if (target 
			&& target.is_in_group("Tree") 
			&& target.has_method("heal")):
				target.heal()

	
	if(Input.is_action_just_pressed("Damage")):
		var damaged = getTargetsInRange()

		for target in damaged:
			if (target 
			# && target.is_in_group("Enemies") 
			&& target.has_method("damage")):
				target.damage()

	setTargetAngle(x, y)
	move_and_slide()
	update_animation((y || x))
	return

func flip(xReverse):
	animated_sprite.flip_h = xReverse
	return

func setTargetAngle(x, y):
	var angle = null
		
	if x != 0:
		if x > 0:
			angle = 0  
		else: 
			angle = 180
		if y != 0:
			angle += 45 * sign(y) * sign(x)
	elif y != 0:
			angle = 90 * sign(y)

	if (angle != null):
		rangeRay.rotation_degrees = angle
	return

func update_animation(move):
	if move:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
	return


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
