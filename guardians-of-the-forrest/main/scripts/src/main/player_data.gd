extends Node

signal health_changed(new_health: int, max_health: int)
signal player_died

@export var max_health: int = 100
var health: int = max_health:
	set(value):
		health_changed.emit(health, max_health)
		if health <= 0:
			player_died.emit()

func heal(amount: int) -> void:
	health += amount
	
func take_damage(amount: int) -> void:
	health -= amount

func reeset() -> void:
	health = max_health
