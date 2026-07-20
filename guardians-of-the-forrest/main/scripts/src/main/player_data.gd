extends Node

signal health_changed(new_health: int, max_health: int)
signal player_died

var max_health: int
var current_health: int
	
func take_damage(amount: int) -> void:
	current_health -= amount
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
