extends Node

signal health_changed(new_health: int, max_health: int)
signal player_died

var max_health: int = 100
var health: int = max_health
	
func take_damage(amount: int) -> void:
	health -= amount
	health_changed.emit(health, max_health)
	print(health)
	if health == 0:
		player_died.emit()

func heal(amount: int) -> void:
	health = clampi(health + amount, 0, max_health)
	health_changed.emit(health, max_health)
	
func reset() -> void:
	health = max_health
	health_changed.emit(health, max_health)
