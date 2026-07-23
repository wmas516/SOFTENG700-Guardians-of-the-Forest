extends Node

signal health_changed(new_health: int, max_health: int)
signal player_died

var current_health: int = 100
var max_health: int = 100
var saved_platforming_position: Vector2 = Vector2.ZERO
var has_saved_platforming_position: bool = false
var trimed_trees: Array[String] = []
	
func take_damage(amount: int) -> void:
	current_health = maxi(current_health - amount, 0)
	health_changed.emit(current_health, max_health)
	print("Current Health: ", current_health)
	if current_health == 0:
		player_died.emit()

func heal(amount: int) -> void:
	current_health = clampi(current_health + amount, 0, max_health)
	health_changed.emit(current_health, max_health)
	
func reset() -> void:
	current_health = max_health
	
func set_health(set_num: int) -> void:
	max_health = set_num
	current_health = max_health
	health_changed.emit(current_health, max_health)

func save_platforming_position(position: Vector2) -> void:
	saved_platforming_position = position
	has_saved_platforming_position = true

func clear_platforming_position() -> void:
	has_saved_platforming_position = false

func add_trimmed_tree_name(tree_name: String) -> void:
	trimed_trees.append(tree_name)

# func save_trimmed_tree_name(tree_name: String) -> void:
# func clear_trimmed_tree_name() 
