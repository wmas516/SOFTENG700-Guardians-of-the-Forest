extends Node2D

@export var waveEnemies = [1,2,4,6]
@export var wave = 0
@export var enemy: CharacterBody2D
@export var spawnTimer: Timer
var enemies = []
@onready var leftFollow: PathFollow2D = $Left/Position
@onready var rightFollow: PathFollow2D = $Right/Position
@onready var bottomFollow: PathFollow2D = $Bottom/Position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#enemy.setEnabled(true)
	if (spawnTimer):
		spawnTimer.start()
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_spawn_timer_timeout() -> void:
	print("timeout")
	spawn()
	pass # Replace with function body.


func spawn():
	if (enemy):
		var newEnemy = enemy.duplicate()
		var spawnPoint = randomSpawn()

		add_child(newEnemy)
		newEnemy.global_position = spawnPoint
		if newEnemy.has_method("setPath"):
			newEnemy.setPath(spawnPoint)
		if newEnemy.has_method("setEnabled"):
			newEnemy.setEnabled(true)
		enemies.append(newEnemy)
		print("cloned")


func randomSpawn() -> Vector2:
	match(randi() % 3):
		0:
			leftFollow.set_progress_ratio(randf())
			return(leftFollow.position)
		1:
			rightFollow.set_progress_ratio(randf())
			return(rightFollow.position)
		_:
			bottomFollow.set_progress_ratio(randf())
			return(bottomFollow.position)
	
