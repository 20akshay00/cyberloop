extends Camera2D

var shake_intensity: float = 0.
var active_shake_time: float = 0.

var shake_decay: float = 5.

var shake_time: float = 0.
var shake_time_speed: float = 20.

var noise = FastNoiseLite.new()

var zoom_in := false
var zoom_out := false

const ZOOM_MAX := 0.8
const ZOOM_MIN := 1.
const ZOOM_SPEED := 0.25

@onready var alert_rect: ColorRect = $CanvasLayer/AlertRect

func _physics_process(delta: float) -> void:
	if active_shake_time > 0:
		shake_time += delta * shake_time_speed
		active_shake_time -= delta
		
		offset = Vector2(
			noise.get_noise_2d(shake_time, 0) * shake_intensity,
			noise.get_noise_2d(0, shake_time) * shake_intensity
		)
		
		shake_intensity = max(shake_intensity - shake_decay * delta, 0)
	else:
		offset = lerp(offset, Vector2.ZERO, 10.5 * delta)

func screen_shake(intensity: int, time: float) -> void:
	randomize()
	noise.seed = randi()
	noise.frequency = 2.
	shake_intensity = intensity
	active_shake_time = time
	shake_time = 0.
	
func _process(delta: float) -> void:
	if Input.is_action_just_released("zoom_out"):
		zoom_in = true
		zoom_out = false

	if Input.is_action_just_released("zoom_in"):
		zoom_out = true

	if zoom_in:
		var zoom_target = max(zoom.x - 0.1, ZOOM_MIN)
		zoom = lerp(zoom, Vector2(zoom_target, zoom_target), ZOOM_SPEED)
		get_tree().create_timer(0.10).timeout.connect(func(): zoom_in = false)

	if zoom_out:
		var zoom_target = min(zoom.x + 0.1, ZOOM_MAX)
		zoom = lerp(zoom, Vector2(zoom_target, zoom_target), ZOOM_SPEED)
		get_tree().create_timer(0.10).timeout.connect(func(): zoom_out= false)
