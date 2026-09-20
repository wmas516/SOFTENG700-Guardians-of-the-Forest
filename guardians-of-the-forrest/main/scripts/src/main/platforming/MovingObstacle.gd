extends StaticBody2D

@onready var sprite: Sprite2D = $Sprite2D

@export var waypoints: Array[Marker2D] = []
@export var speed: float = 100.0

var wp_index: int = 0

func _ready() -> void:
	move_to_next()
	
func move_to_next() -> void:
	if waypoints.is_empty(): return
	var target := waypoints[wp_index].global_position
	
	if target.x < global_position.x:
		sprite.flip_h = true
	elif target.x > global_position.x:
		sprite.flip_h = false
	
	var dist := global_position.distance_to(target)
	var tween := create_tween()
	tween.tween_property(self, "global_position", target, dist / speed)
	tween.tween_callback(advance)
	
func advance() -> void:
	wp_index = (wp_index + 1) % waypoints.size()
	move_to_next()
