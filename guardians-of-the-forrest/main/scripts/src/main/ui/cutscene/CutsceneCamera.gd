extends CanvasModulate
## Attach to the CanvasModulate node that parents all your image layers.
## Drives the illusion of camera movement over a static painted cutscene:
## a slow deliberate pan for the duration of the shot, plus a small
## continuous handheld-style jitter layered on top.
##
## Position is recomputed fresh each frame from base + pan + jitter,
## rather than being tweened directly, so the two effects don't fight
## over the same property.

@export var pan_distance: Vector2 = Vector2(-40.0, 0.0)  # total drift over pan_duration
@export var pan_duration: float = 8.0                     # seconds -- match your caption timing
@export var shake_strength: float = 2.0                   # px -- keep small, this isn't an earthquake
@export var shake_speed: float = 8.0

var _base_position: Vector2
var _pan_offset: Vector2 = Vector2.ZERO
var _noise := FastNoiseLite.new()
var _time: float = 0.0

func _ready() -> void:
	_base_position = position
	_noise.seed = randi()
	_noise.frequency = 0.05
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(_set_pan_offset, Vector2.ZERO, pan_distance, pan_duration)

func _set_pan_offset(offset: Vector2) -> void:
	_pan_offset = offset

func _process(delta: float) -> void:
	_time += delta * shake_speed
	var jitter := Vector2(
		_noise.get_noise_1d(_time),
		_noise.get_noise_1d(_time + 1000.0)
	) * shake_strength
	position = _base_position + _pan_offset + jitter
