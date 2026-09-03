extends Node2D

@export var waveEnemies: Array[Wave] = [Wave.new(1,1,1),Wave.new(2,1,0),Wave.new(0,0,2),Wave.new(3,2,1)]
@export var wave = 0
@export var aliveEnemies = 0
@export var enemy: CharacterBody2D
@export var bossEnemy: CharacterBody2D
@export var spawnTimer: Timer
@export var lives: int = 5

var enemies: Array[Node] = []
var level_complete: bool = false

@onready var leftFollow: PathFollow2D = $Left/Position
@onready var rightFollow: PathFollow2D = $Right/Position
@onready var bottomFollow: PathFollow2D = $Bottom/Position

@onready var waveLabel: Label = $HUD/MarginContainer/HBoxContainer/Wave/HBoxContainer/MarginContainer2/CurrentWave
@onready var waveTotalLabel: Label = $HUD/MarginContainer/HBoxContainer/Wave/HBoxContainer/MarginContainer4/TotalWave
@onready var hpLabel: Label = $HUD/MarginContainer/HBoxContainer/HP/HBoxContainer/MarginContainer2/Count
@onready var enemyLabel: Label = $HUD/MarginContainer/HBoxContainer/Enemies/HBoxContainer/MarginContainer2/Count
@onready var completion_container: Container = $HUD/ReturnBox
@onready var tryAgain_container: Container = $HUD/TryAgainBox
@onready var spawnAudioPlayer: AudioStreamPlayer = $SpawnPlayer

var curWaveEnemies = waveEnemies
var originalWaveEnemies: Array[Wave] = []
var curLives = lives

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#enemy.setEnabled(true)
	curLives = lives
	for enemy_node in enemies.duplicate():
		if is_instance_valid(enemy_node):
			enemy_node.queue_free()
	enemies.clear()
	hpLabel.text = str(curLives)
	if originalWaveEnemies.is_empty():
		originalWaveEnemies = copy_waves(waveEnemies)
	curWaveEnemies = copy_waves(originalWaveEnemies)
	waveTotalLabel.text = str(curWaveEnemies.size())
	completion_container.visible = false
	wave = 0
	nextWave()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func copy_waves(waves: Array[Wave]) -> Array[Wave]:
	var copied_waves: Array[Wave] = []
	for wave_resource in waves:
		copied_waves.append(Wave.new(wave_resource.normal, wave_resource.elite, wave_resource.boss))
	return copied_waves

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
	if (wave < curWaveEnemies.size()):
		aliveEnemies = curWaveEnemies[wave].total()
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
		enemy.type = curWaveEnemies[wave-1].getRandEnemyBossLast()
		var newEnemy
		if (enemy.type == DefenceEnemy.EnemyType.BOSS && bossEnemy):
			bossEnemy.type = DefenceEnemy.EnemyType.BOSS
			newEnemy = bossEnemy.duplicate()
		else:
			newEnemy = enemy.duplicate()
		var spawnPoint = randomSpawn()
		add_child(newEnemy)
		newEnemy.global_position = spawnPoint
		if newEnemy.has_method("setEnabled"):
			newEnemy.setEnabled(true)
		newEnemy.tree_exited.connect(func():
			_on_enemy_tree_exited(newEnemy)
		)
		enemies.append(newEnemy)
		spawnAudioPlayer.play()
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

func _on_try_again_button_pressed() -> void:
	print("try again")
	revertLoss()
	_ready()

func _on_boss_enemy_damaged_target(target) -> void:
	targetDamage(target)

func _on_enemy_damaged_target(target) -> void:
	targetDamage(target)

func targetDamage(target) -> void:
	curLives -= 1
	hpLabel.text = str(curLives)
	if (target.has_method("setVisibleHealth")):
		target.setVisibleHealth(curLives)
	if (curLives <= 0):
		loss()

func loss() -> void:
	tryAgain_container.visible = true
	for child in get_children():
		if !(child is Control):
			child.process_mode = Node.PROCESS_MODE_DISABLED
			child.set_physics_process(false)
	for enemy in enemies:
		if enemy is DefenceEnemy: 
			(enemy as DefenceEnemy).setEnabled(false)
			(enemy as DefenceEnemy).set_physics_process(false)

func revertLoss() -> void:
	tryAgain_container.visible = false
	for child in get_children():
		if !(child is Control):
			child.process_mode = Node.PROCESS_MODE_INHERIT
			child.set_physics_process(true)
			if (child.has_method("_ready()")):
				child._ready()
