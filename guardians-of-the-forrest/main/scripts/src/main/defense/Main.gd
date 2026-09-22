extends Node2D

@export var level_config: DefenseLevelConfig
@export var wave = 0
@export var boss: bool = false
@export var aliveEnemies = 0
@export var enemy: CharacterBody2D
@export var bossEnemy: CharacterBody2D
@export var spawnTimer: Timer
@export var lives: int = 5

var enemies: Array[Node] = []
var level_complete: bool = false
var frozen: bool = false
var active_freeze_nodes: Array[Node] = []
var active_freeze_actions: Array[StringName] = []

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
@onready var spawnBossAudioPlayer: AudioStreamPlayer = get_node_or_null("SpawnPlayerBoss") as AudioStreamPlayer

@onready var tutorial: Control = $HUD/MarginContainer/Tutorial

var curWaveEnemies: Array[Wave] = []
var originalWaveEnemies: Array[Wave] = []
var curLives = lives

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not PlayerData.difficulty_changed.is_connected(_on_difficulty_changed):
		PlayerData.difficulty_changed.connect(_on_difficulty_changed)
	_select_difficulty_config(PlayerData.difficulty)
	if level_config == null:
		push_error("Assign a DefenseLevelConfig resource before starting this level.")
		return
	#enemy.setEnabled(true)
	curLives = lives
	if (enemy.dest.has_method("setVisibleHealth")):
		enemy.dest.setVisibleHealth(curLives)
	for enemy_node in enemies.duplicate():
		if is_instance_valid(enemy_node):
			enemy_node.queue_free()
	enemies.clear()
	hpLabel.text = str(curLives)
	originalWaveEnemies = copy_waves(level_config.waveEnemies)
	curWaveEnemies = copy_waves(originalWaveEnemies)
	waveTotalLabel.text = str(curWaveEnemies.size())
	completion_container.visible = false
	wave = 0
	nextWave()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _select_difficulty_config(difficulty: PlayerData.Difficulty) -> void:
	var difficulty_name: String = PlayerData.Difficulty.keys()[difficulty].capitalize()
	var level_folder := "boss" if boss else "defense"
	var config_path := "res://main/scripts/src/main/defense/difficulty/%s/%s.tres" % [level_folder, difficulty_name]
	var selected_config := load(config_path) as DefenseLevelConfig
	if selected_config == null:
		push_error("Unable to load difficulty configuration: " + config_path)
		return
	level_config = selected_config


func _on_difficulty_changed(_difficulty: PlayerData.Difficulty) -> void:
	# Let the button signal finish before replacing the scene that owns it.
	get_tree().reload_current_scene.call_deferred()


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
	# Enemy cleanup can trigger this while the level is leaving the scene tree.
	if not is_instance_valid(spawnTimer) or not spawnTimer.is_inside_tree():
		return
	if (wave < curWaveEnemies.size()):
		aliveEnemies = curWaveEnemies[wave].total()
		wave = wave + 1
		enemyLabel.text = str(aliveEnemies)
		#print("[New Wave]:\n - Wave: ",wave)
		waveLabel.text = str(wave)
		_check_freeze_for_wave(wave)
		if not frozen:
			spawnTimer.start()
	else:
		spawnTimer.stop()
		level_complete = true
		_show_completion()
		if (boss):
			$DeathPlayerBoss.play()
	
func spawn():
	if level_complete:
		return
	if (enemy):
		enemy.type = curWaveEnemies[wave-1].getRandEnemyBossLast()
		var newEnemy
		if (enemy.type == DefenceEnemy.EnemyType.BOSS && bossEnemy):
			bossEnemy.type = DefenceEnemy.EnemyType.BOSS
			newEnemy = bossEnemy.duplicate()
			if spawnBossAudioPlayer:
				spawnBossAudioPlayer.play()
		else:
			newEnemy = enemy.duplicate()
			spawnAudioPlayer.play()
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
	_check_freeze_for_wave(0)

func _on_return_button_pressed() -> void:
	if (boss):
		PlayerData.restart()
		get_tree().change_scene_to_file("res://main/scenes/Main.tscn")
	else:
		get_tree().change_scene_to_file("res://main/scenes/levels/platforming/Level.tscn")
func _on_try_again_button_pressed() -> void:
	revertLoss()
	_ready()

func _unhandled_input(event: InputEvent) -> void:
	if not frozen:
		return
	if event is InputEventKey and event.pressed and not event.echo and _matches_freeze_action(event):
		for node in active_freeze_nodes:
			if is_instance_valid(node):
				node.hide()
		active_freeze_nodes.clear()
		frozen = false
		call_deferred("_apply_frozen_state", false)
		if aliveEnemies > 0:
			spawnTimer.start()
		get_viewport().set_input_as_handled()

func _matches_freeze_action(event: InputEvent) -> bool:
	for action in active_freeze_actions:
		if event.is_action_pressed(action):
			return true
	return false

func _check_freeze_for_wave(wave_number: int) -> void:
	active_freeze_nodes.clear()
	active_freeze_actions.clear()
	for entry in level_config.freeze_entries:
		if entry.wave != wave_number:
			continue
		var node := get_node_or_null(entry.node) as CanvasItem
		if node == null:
			continue
		node.show()
		active_freeze_nodes.append(node)
		active_freeze_actions.append(entry.action)

	if active_freeze_nodes.is_empty():
		return
	frozen = true
	call_deferred("_apply_frozen_state", true)

func _apply_frozen_state(should_freeze: bool) -> void:
	for child in get_children():
		if child is CanvasLayer or child is AudioStreamPlayer or child is Control:
			continue
		child.set_physics_process(!should_freeze)
		child.process_mode = (
			Node.PROCESS_MODE_DISABLED
			if should_freeze
			else Node.PROCESS_MODE_INHERIT
		)

func _on_boss_enemy_damaged_target() -> void:
	targetDamage()

func _on_enemy_damaged_target() -> void:
	targetDamage()

func targetDamage() -> void:
	curLives -= 1
	hpLabel.text = str(curLives)
	if (enemy.dest.has_method("setVisibleHealth")):
		enemy.dest.setVisibleHealth(curLives)
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


func _on_menu_help() -> void:
	tutorial.set_visible(!tutorial.is_visible())
	frozen = !frozen
	_apply_frozen_state(frozen)
