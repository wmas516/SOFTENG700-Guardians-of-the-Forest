extends TextureRect
## Attach to each background layer TextureRect (Sky, Hills, Forest, Dirt, Bush...).
## Gives it an independent, slow sine-wave drift so different depths appear
## to move at different rates -- the "painted parallax" / wind-sway look.
## Tune sway_distance and sway_speed per-layer: smaller/slower for far
## layers, larger/faster for near ones.
 
@export var sway_distance: Vector2 = Vector2(15.0, 6.0)  # px, how far this layer drifts
@export var sway_speed: float = 0.25                      # radians/sec -- lower = lazier
@export var phase_offset: float = 0.0                      # stagger layers so they don't sync up
@export var rotation_amplitude_deg: float = 0.0            # optional gentle tilt, good for foliage
 
var _base_position: Vector2
var _time: float = 0.0
 
func _ready() -> void:
	_base_position = position
	if rotation_amplitude_deg != 0.0:
		pivot_offset = size / 2.0
 
func _process(delta: float) -> void:
	_time += delta
	position = _base_position + Vector2(
		sin(_time * sway_speed + phase_offset) * sway_distance.x,
		sin(_time * sway_speed * 0.6 + phase_offset + 1.57) * sway_distance.y
	)
	if rotation_amplitude_deg != 0.0:
		rotation_degrees = sin(_time * sway_speed * 0.8 + phase_offset) * rotation_amplitude_deg
