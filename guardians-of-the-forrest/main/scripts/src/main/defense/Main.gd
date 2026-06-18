extends Node2D

@export var waveEnemies = [1,2,4,6]
@export var wave = 0
@export var aliveEnemies = 0
@export var enemy: CharacterBody2D
@export var spawnTimer: Timer
var enemies: Array[Node] = []
@onready var leftFollow: PathFollow2D = $Left/Position
@onready var rightFollow: PathFollow2D = $Right/Position
@onready var bottomFollow: PathFollow2D = $Bottom/Position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#enemy.setEnabled(true)
	nextWave()
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_spawn_timer_timeout() -> void:
	if aliveEnemies > 0:
		spawn()
		aliveEnemies -= 1
	else:
		spawnTimer.stop()

func nextWave():
	spawnTimer.start()
	if (wave < waveEnemies.size()):
		aliveEnemies = waveEnemies[wave]
		wave = wave + 1
		print("Wave: ",wave)
	else:
		spawnTimer.stop()
		print("Level Complete")
	

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
		newEnemy.tree_exited.connect(func():
			_on_enemy_tree_exited(newEnemy)
		)
		enemies.append(newEnemy)
		print("Alive:",enemies.size())
		print("Remaining:",aliveEnemies)


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
	


func _on_enemy_tree_exited(enemy_node: Node) -> void:
	enemies.erase(enemy_node)
	print("Alive:",enemies.size())
	print("Remaining:",aliveEnemies)
	if enemies.size() <= 0 && aliveEnemies <= 0:
		nextWave()
	
