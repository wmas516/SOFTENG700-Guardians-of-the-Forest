extends CharacterBody2D
class_name PlayerDef

@export var speed = 125

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var rangeRay: RayCast2D = $Range

@onready var attackTimer: Timer = $AttackTimer

@onready var attacking: bool = false
@onready var damaged: bool = false

@onready var blastSoundPlayer: AudioStreamPlayer = $BlastSound
@onready var hurtSoundPlayer: AudioStreamPlayer = $DamageSound
@onready var stepSoundPlayer: AudioStreamPlayer = $FootstepSound

func _ready() -> void:
	position = Vector2(560.0,375.0)	
	rangeRay.collision_mask = self.collision_mask
	damaged = false
	attacking = false
	attackTimer.stop()
	blastSoundPlayer.stop()
	hurtSoundPlayer.stop()
	stepSoundPlayer.stop()
	return

func _physics_process(delta: float) -> void:

	var x = Input.get_axis("Left", "Right")
	var y = Input.get_axis("Up", "Down")

	velocity = Vector2(x, y)
	velocity = velocity.normalized() * speed
	

	flip(rangeRay.rotation_degrees < -90 || rangeRay.rotation_degrees > 90)

	if(Input.is_action_just_pressed("Heal")):
		var healed = getTargetsInRange()

		for target in healed:
			if (target 
			&& target.is_in_group("Tree") 
			&& target.has_method("heal")):
				target.heal()

	if (animated_sprite.get_animation() == "hurt" && damaged && attackTimer.is_stopped()):
		attackTimer.start()
	elif(Input.is_action_just_pressed("Damage") && !attacking):
		attackTimer.start()
		attacking = true
		blastSoundPlayer.play()
		var damaged = getTargetsInRange()

		for target in damaged:
			if (target 
			# && target.is_in_group("Enemies") 
			&& target.has_method("damage")):
				target.damage()

	setTargetAngle(x, y)
	move_and_slide()
	update_animation(x, y)
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

func update_animation(x, y):
	if (attacking):
		if (rangeRay.rotation_degrees == 90):
			animated_sprite.play("blast-down")
		elif (rangeRay.rotation_degrees == -90):
				animated_sprite.play("blast-up")	
		else:
			animated_sprite.play("blast-side")
		return
	elif (damaged):
		if (!hurtSoundPlayer.playing):
			hurtSoundPlayer.play()
		animated_sprite.play("hurt")
		return
	if (animated_sprite.get_frame() % 3 == 0):
		stepSoundPlayer.play()
	
	if (x && y):
		if y < 0:
			animated_sprite.play("run-diag-top")
		if y > 0:
			animated_sprite.play("run-diag-bot")
	elif (y):
		if y < 0:
			animated_sprite.play("run-top")
		if y > 0:
			animated_sprite.play("run-bot")
	elif (x):
		animated_sprite.play("run-side")
	else:
		animated_sprite.play("idle")
		animated_sprite.flip_h = false
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

func damage():
	#PlayerData.take_damage(10)
	damaged = true
	animated_sprite.play("hurt")
	await animated_sprite.animation_finished

func _on_attack_timer_timeout() -> void:
	attacking = false;
	damaged = false;
