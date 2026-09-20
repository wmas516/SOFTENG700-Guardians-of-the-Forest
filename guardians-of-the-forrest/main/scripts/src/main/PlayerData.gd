extends Node

enum Difficulty {EASY, MEDIUM, HARD}

signal difficulty_changed(new_difficulty: Difficulty)

var saved_platforming_position: Vector2 = Vector2.ZERO
var has_saved_platforming_position: bool = false
var trimed_trees: Array[String] = []
var infected_trees: Array[String] = []
var game_progress_stage: int = 0
var skip_narrative: bool = false
var player_active: bool = true
var difficulty: Difficulty = Difficulty.MEDIUM

func update_progress_stage(stage: int) -> void:
	game_progress_stage = stage

func save_platforming_position(position: Vector2) -> void:
	saved_platforming_position = position
	has_saved_platforming_position = true

func clear_platforming_position() -> void:
	has_saved_platforming_position = false

func add_trimmed_tree_name(tree_name: String) -> void:
	if not trimed_trees.has(tree_name):
		trimed_trees.append(tree_name)

func set_difficulty(new_difficulty: Difficulty) -> void:
	if difficulty == new_difficulty:
		return
	difficulty = new_difficulty
	difficulty_changed.emit(difficulty)

func restart() -> void:
	saved_platforming_position = Vector2.ZERO
	has_saved_platforming_position = false
	trimed_trees = []
	infected_trees = []
	game_progress_stage = 0
	player_active = true
	
