extends CharacterBody2D
class_name Player

@export var trail_scene: PackedScene
@export var trails: Node2D
@export var spawn_point: Sprite2D # absolutely horrid architecture!

@export_subgroup("Attributes")
@export var MAX_HEALTH: float = 5.
@export var MAX_POWER: float = 1.
@export var health: float = MAX_HEALTH
@export var power: float = 1.

@export_subgroup("Handling")
@export var MIN_SPEED: float = 700.0
@export var MAX_SPEED: float = 2500.0
@export var ROTATION_SPEED: float = 10.0 # radians per second

@export var CURSOR_DEADZONE: float = 10.0

@export_subgroup("Trail", "POWER_")
@export var POWER_DRAIN_RATE: float = 0.0005 / 5
@export var POWER_RECHARGE_VELOCITY: float = 2200.
@export var POWER_RECHARGE_RATE: float = 0.275

@export_subgroup("Visuals")
@export var fall_animation_config: FallAnimationConfig

@export_subgroup("Audio")
@export var MIN_PITCH: float = 1.
@export var MAX_PITCH: float = 2.

# onready variables
@onready var alert_rect: ColorRect = $Camera2D/CanvasLayer/AlertRect
@onready var camera: Camera2D = $Camera2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var pointer: Node2D = $Pointer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

## audio
@onready var drive_sound := $DriveSound
@onready var draw_sound := $DrawSound
@onready var power_full_sound := $PowerFullSound
@onready var power_empty_sound := $PowerDepletedSound
@onready var power_charging_sound := $PowerChargingSound
@onready var hit_sound := $HitSound
@onready var draw_start_sound := $DrawStartSound
@onready var fall_sound := $FallSound
var _pitch: float = 0.

# state variables
var _is_active: bool :
	set(val):
		if val:
			if collision_shape: collision_shape.set_deferred("disabled", false)
			if drive_sound: drive_sound.play()
		else:
			_is_drawing = false
			if collision_shape: collision_shape.set_deferred("disabled", true)
			if draw_sound: draw_sound.stop()
			if drive_sound: drive_sound.stop()

		_is_active = val

var _is_drawing: bool = false
var _is_invincible: bool = false

# tweens
var _death_tween: Tween = null
var _respawn_tween: Tween = null
var _invincibility_tween: Tween = null

# data
var _prev_pos: Vector2 = Vector2.ZERO
var _trail: Trail

var _closest_enemy_pos: Vector2 = Vector2.ZERO
var _closest_enemy_dist: float = 1e10

var _mouse_dir := Vector2.ZERO
var _mouse_distance := 0.
var _target_pos := Vector2(2 * CURSOR_DEADZONE, 0.)

func _ready() -> void:
	_create_trail()	
	drive_sound.play()
	EventManager.shake_screen.connect(_shake_screen)
	EventManager.wave_changed.connect(_on_wave_changed)

	if Config.platform_mobile:
		EventManager.draw_enabled.connect(_on_draw)
		EventManager.draw_disabled.connect(_on_draw_release)
	
func _process(delta: float) -> void:
	if _is_active:
		_process_input(delta)
		_update_transform(delta)
		_update_trail(delta)
		_update_pitch()

		_update_enemy_compass(delta)
		_prev_pos = global_position

func _on_draw():
	power_charging_sound.stop()
	if power > 0.05:
		_is_drawing = true
		draw_sound.play()
	else:
		if not power_empty_sound.is_playing(): power_empty_sound.play()
		
func _on_draw_release():
	_is_drawing = false
	_create_trail()
	draw_sound.stop()

func _process_input(delta: float) -> void:
	if Config.control_scheme == PlayerConfig.CONTROL_SCHEMES.TOUCHSCREEN:
		_target_pos = Input.get_vector("left", "right", "up", "down") * Config.mobile_joystick_sensitivity + global_position
		_target_pos.x = clamp(_target_pos.x, -Config.arena_xbound, Config.arena_xbound)
		_target_pos.y = clamp(_target_pos.y, -Config.arena_ybound, Config.arena_ybound)
		
	elif Config.control_scheme == PlayerConfig.CONTROL_SCHEMES.MOUSE:
		_target_pos = get_global_mouse_position()
		
	elif Config.control_scheme == PlayerConfig.CONTROL_SCHEMES.KEYBOARD:
		var angle = lerp_angle(_target_pos.angle(), _target_pos.angle() + delta * Input.get_axis("rotate_ccw", "rotate_cw") * Config.rotation_sensitivity, 0.9)
		_target_pos = _target_pos.rotated(angle - _target_pos.angle())
		
		_target_pos *= clamp(_target_pos.length() + Input.get_axis("deccelerate", "accelerate") * Config.acceleration_sensitivity * delta, CURSOR_DEADZONE * 2., 2000.)/_target_pos.length()
	
	if (_target_pos - global_position).length() > CURSOR_DEADZONE:
		_mouse_dir = _target_pos - global_position
		_mouse_distance = _mouse_dir.length()

	if not Config.platform_mobile and Input.is_action_just_pressed("draw") and not _is_drawing:
		_on_draw()

	if not Config.platform_mobile and Input.is_action_just_released("draw") and _is_drawing:
		_on_draw_release()

func _update_transform(delta: float) -> void:
	var _target_rot = _mouse_dir.angle() + PI / 2
	rotation = lerp_angle(rotation, _target_rot, ROTATION_SPEED * delta)

	var speed = MIN_SPEED + min(_mouse_distance * Config.cursor_sensitivity * camera.zoom.x, MAX_SPEED - MIN_SPEED)
	velocity = Vector2(cos(rotation - PI / 2), sin(rotation - PI / 2)) * speed
	move_and_slide()

func _update_enemy_compass(delta: float) -> void:
	if get_tree().get_nodes_in_group("enemies").size() > 0:
		pointer.show()
		for enemy in get_tree().get_nodes_in_group("enemies"):
			var dist = (enemy.global_position - global_position).length()
			if dist < _closest_enemy_dist:
				_closest_enemy_dist = dist
				_closest_enemy_pos = enemy.global_position - global_position
			
		pointer.rotation = lerp_angle(pointer.rotation, atan2(_closest_enemy_pos.y, _closest_enemy_pos.x) - rotation, 0.1)
		_closest_enemy_dist = 1e10
	else:
		pointer.hide()

func _update_trail(delta: float) -> void:
	if _is_drawing:
		_trail.add_point(global_position)
		if _trail.get_point_count() > 2:
			power -= (global_position - _prev_pos).length() * POWER_DRAIN_RATE
			if power < 0.:
				power_empty_sound.play()
				power = 0.
				_is_drawing = false
				_create_trail()
				draw_sound.stop()
	else:
		if velocity.length() > POWER_RECHARGE_VELOCITY and power < MAX_POWER:
			power += POWER_RECHARGE_RATE * delta
			if power_charging_sound.has_stream_playback() == false:
				draw_start_sound.play()
				power_charging_sound.play()
			if power > 1:
				power = 1.
				power_charging_sound.stop()
				power_full_sound.play()
	
	if velocity.length() < POWER_RECHARGE_VELOCITY:
		power_charging_sound.stop()

func _update_pitch() -> void:
	_pitch = MIN_PITCH + (MAX_PITCH - MIN_PITCH) * (velocity.length() - MIN_SPEED) / (MAX_SPEED - MIN_SPEED)
	drive_sound.pitch_scale = _pitch
	draw_sound.pitch_scale = _pitch

func _create_trail() -> void:
	if _trail: _trail.destroy()
	_trail = trail_scene.instantiate()
	trails.add_child.call_deferred(_trail)

func set_fall_state(damage_val: int = 2) -> void:
	if not _is_active: return
	# audio
	fall_sound.play()	
	draw_sound.stop()
	drive_sound.stop()
	power_charging_sound.stop()

	Utils.play_fall_animation(self, _death_tween)

	# state
	_is_active = false

func on_fall_completed() -> void:
	damage(2)
	respawn()

func respawn() -> void:
	_create_trail()
	modulate.a = 1.
	
	if _respawn_tween: _respawn_tween.kill()
	_respawn_tween = get_tree().create_tween()
	_respawn_tween.tween_property(self, "global_position", Vector2.ZERO, 1)
	_respawn_tween.tween_property(spawn_point, "modulate:a", 1., 0.25)
	_respawn_tween.tween_property(self, "scale", Vector2(1, 1), 0.5)
	_respawn_tween.tween_property(spawn_point, "modulate:a", 0.2, 0.5)
	_respawn_tween.tween_callback(
		func():
			_is_active = true
			_activate_invincibility()
	)
	
	_respawn_tween.tween_method(func(val): power = val, power, 1., 1. * (1 - power))

func hit(val) -> void:
	if not _is_invincible:
		damage(val)
		_activate_invincibility()
		hit_sound.play()
		_shake_screen()

func damage(val) -> void:
	health -= val
	EventManager.player_health_changed.emit()
	EventManager.player_hit.emit()
	
func _activate_invincibility(duration: float = 4) -> void:
	_is_invincible = true
	if _invincibility_tween: _invincibility_tween.kill()
	_invincibility_tween = get_tree().create_tween()
	
	for i in range(duration):
		_invincibility_tween.tween_property(sprite.material, "shader_parameter/overlay_strength", 0.8, 0.1)
		_invincibility_tween.tween_property(sprite.material, "shader_parameter/overlay_strength", 0.0, 0.1)

	_invincibility_tween.chain().tween_callback(func(): _is_invincible = false)

func _shake_screen() -> void:
	camera.screen_shake(8, 0.5)

func add_health(val: float) -> void:
	health = min(MAX_HEALTH, health + val)
	EventManager.player_health_changed.emit()

func death() -> void:
	_is_active = false

	# visuals
	sprite.hide()
	$DeathAnimation.show()
	$DeathAnimation.play()
	$DeathAnimation.animation_finished.connect(func(): EventManager.game_over.emit())

	# audio
	$DeathSound.play()

func _on_wave_changed(wave: int) -> void:
	return

func _update_alert() -> void:
	pass

func is_vulnerable() -> bool:
	return _trail.get_point_count() > 10 and velocity.length() > 1100.
