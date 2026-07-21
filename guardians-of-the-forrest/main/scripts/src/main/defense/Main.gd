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

@onready var waveLabel: Label = $HUD/MarginContainer/HBoxContainer/Wave/HBoxContainer/MarginContainer2/CurrentWave
@onready var waveTotalLabel: Label = $HUD/MarginContainer/HBoxContainer/Wave/HBoxContainer/MarginContainer4/TotalWave
@onready var enemyLabel: Label = $HUD/MarginContainer/HBoxContainer/Enemies/HBoxContainer/MarginContainer2/Count

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#enemy.setEnabled(true)
	waveTotalLabel.text = str(waveEnemies.size())
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
		enemyLabel.text = str(aliveEnemies)
		#print("[New Wave]:\n - Wave: ",wave)
		waveLabel.text = str(wave)
	else:
		spawnTimer.stop()
		print("Level Complete")
	

func spawn():
	if (enemy):
		var newEnemy = enemy.duplicate()
		var spawnPoint = randomSpawn()
		add_child(newEnemy)
		newEnemy.global_position = spawnPoint
		if newEnemy.has_method("setEnabled"):
			newEnemy.setEnabled(true)
		newEnemy.tree_exited.connect(func():
			_on_enemy_tree_exited(newEnemy)
		)
		enemies.append(newEnemy)
		#print("[Enemy Spawned]:")
		#enemyLog()


func randomSpawn() -> Vector2:
	var pathFollower = bottomFollow
	match(randi() % 3):
		0:
			pathFollower = leftFollow
		1:
			pathFollower = rightFollow
			
	pathFollower.set_progress_ratio(randf())
	return(pathFollower.position)


func _on_enemy_tree_exited(enemy_node: Node) -> void:
	enemies.erase(enemy_node)
	#print("[Enemy Dead]:")
	enemyLog()
	if enemies.size() <= 0 && aliveEnemies <= 0:
		nextWave()
	
func enemyLog():
	#print(" - Alive: ", enemies.size())
	#print(" - Remaining: ", aliveEnemies)
	enemyLabel.text = str(aliveEnemies + enemies.size())
