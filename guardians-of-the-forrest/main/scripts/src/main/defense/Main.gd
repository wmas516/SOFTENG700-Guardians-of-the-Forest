extends Node2D

class Wave:
	var normal: int
	var elite: int
	var boss: int
	func _init(pNormal: int, pElite: int, pBoss: int):
		normal = pNormal
		elite = pElite
		boss = pBoss
	func spawnNormal() -> void:
		normal -= 1
	func spawnElite() -> void:
		elite -= 1
	func spawnBoss() -> void:
		boss -= 1
	func getRandEnemyBossLast() -> DefenceEnemy.EnemyType:
		if (total() > 0):
			var options = []
			if (normal > 0):
				options.append(DefenceEnemy.EnemyType.NORMAL)
			if (elite > 0):
				options.append(DefenceEnemy.EnemyType.ELITE)
			if (options.is_empty() && boss > 0):
				options.append(DefenceEnemy.EnemyType.BOSS)
			var index = randi() % options.size()
			subType(options[index])
			return (options[index])
		return (DefenceEnemy.EnemyType.NORMAL)
	func subType(type:DefenceEnemy.EnemyType):
		match type:
			DefenceEnemy.EnemyType.NORMAL:
				spawnNormal()
			DefenceEnemy.EnemyType.ELITE:
				spawnElite()
			DefenceEnemy.EnemyType.BOSS:
				spawnBoss()
	func total() -> int:
		return (normal + elite + boss)

@export var waveEnemies: Array = [Wave.new(1,1,1),Wave.new(2,1,0),Wave.new(0,0,2),Wave.new(3,2,1)]
@export var wave = 0
@export var aliveEnemies = 0
@export var enemy: CharacterBody2D
@export var spawnTimer: Timer

var enemies: Array[Node] = []
var level_complete: bool = false

@onready var leftFollow: PathFollow2D = $Left/Position
@onready var rightFollow: PathFollow2D = $Right/Position
@onready var bottomFollow: PathFollow2D = $Bottom/Position

@onready var waveLabel: Label = $HUD/MarginContainer/HBoxContainer/Wave/HBoxContainer/MarginContainer2/CurrentWave
@onready var waveTotalLabel: Label = $HUD/MarginContainer/HBoxContainer/Wave/HBoxContainer/MarginContainer4/TotalWave
@onready var enemyLabel: Label = $HUD/MarginContainer/HBoxContainer/Enemies/HBoxContainer/MarginContainer2/Count
@onready var completion_container: Container = $HUD/ReturnBox
@onready var completion_button: Button = $HUD/ReturnBox/ReturnButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#enemy.setEnabled(true)
	waveTotalLabel.text = str(waveEnemies.size())
	completion_container.visible = false
	nextWave()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_spawn_timer_timeout() -> void:
	if level_complete:
		return
	if aliveEnemies > 0:
		spawn()
		aliveEnemies -= 1
	else:
		spawnTimer.stop()

func nextWave():
	spawnTimer.start()
	if (wave < waveEnemies.size()):
		aliveEnemies = waveEnemies[wave].total()
		wave = wave + 1
		enemyLabel.text = str(aliveEnemies)
		#print("[New Wave]:\n - Wave: ",wave)
		waveLabel.text = str(wave)
	else:
		spawnTimer.stop()
		level_complete = true
		_show_completion()
	

func spawn():
	if level_complete:
		return
	if (enemy):
		enemy.type = waveEnemies[wave-1].getRandEnemyBossLast()
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

func _show_completion() -> void:
	completion_container.visible = true

func _on_return_button_pressed() -> void:
	print("return pressed")
	get_tree().change_scene_to_file("res://main/scenes/levels/platforming/Platforming.tscn")
