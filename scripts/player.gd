extends CharacterBody2D
class_name Player

@export var crack_scene: PackedScene
@export var trails: Node2D
@onready var sprite := $Sprite2D
var trail: Crack

var dir: Vector2 = Vector2.ZERO
var _is_active: bool = true
var _is_drawing: bool = false

var death_tween: Tween = null
var respawn_tween: Tween = null

var MAX_POWER: float = 1.
var power: float = 1.
var POWER_COST: float = 0.001/5

var MAX_HEALTH: float = 3.
var health: float = 5.

var RECHARGE_DIST: float = 20.
var RECHARGE_AMOUNT: float = 0.0025

var prev_pos: Vector2 = Vector2.ZERO

@onready var drive_sound := $DriveSound
@onready var draw_sound := $DrawSound
var pitch: float = 0.

@export var spawn_point: Sprite2D # absolutely horrid architecture!

# i-frames
var _is_invincible: bool = false
var itween: Tween = null

func _ready() -> void:
	_create_trail()
	drive_sound.play()
	EventManager.shake_screen.connect(_shake_screen)

func _process(delta: float) -> void:
	if _is_active:
##		global_position = lerp(position, get_global_mouse_position(), 1.0 - pow(0.965, delta * 60))

		global_position = lerp(position, get_global_mouse_position(), 1.0 - pow(0.95, delta * 60))
		
		dir = get_global_mouse_position() - position
		rotation = lerp_angle(rotation, atan2(dir.y, dir.x) + PI/2, 0.2)

		if Input.is_action_just_pressed("draw") and not _is_drawing:
			if power > 0.:
				_is_drawing = true
				draw_sound.play()
				#AudioManager.play_effect(AudioManager.draw_start_sfx, 10)

		if Input.is_action_just_released("draw") and _is_drawing:
			_is_drawing = false
			_create_trail()
			draw_sound.stop()

		if _is_drawing:
			trail.add_point(global_position)
			if trail.get_point_count() > 2:
				power -= (global_position - prev_pos).length() * POWER_COST
				if power < 0.:
					AudioManager.play_effect(AudioManager.power_empty_sfx, 10)
					power = 0.
					_is_drawing = false
					_create_trail()
					draw_sound.stop()
		else:
			if (global_position - prev_pos).length() > RECHARGE_DIST and power < 1.:
				power += RECHARGE_AMOUNT
				if power > 1: 
					power = 1.
					AudioManager.play_effect(AudioManager.power_full_sfx, 10)

		pitch = clampf((global_position - prev_pos).length()/20. + 1., 1., 2.)
		drive_sound.pitch_scale = pitch
		drive_sound.pitch_scale = pitch

		prev_pos = global_position

func _create_trail() -> void:
	if trail: trail.destroy()

	trail = crack_scene.instantiate()
	trails.add_child.call_deferred(trail)

func fall() -> void:
	damage(1)
	die()
	AudioManager.play_effect(AudioManager.fall_sfx)

func die() -> void:
	_is_active = false
	_is_drawing = false
	
	draw_sound.stop()
	drive_sound.stop()
	$CollisionShape2D.set_deferred("disabled", true)
	if death_tween: death_tween.kill() 
	
	death_tween = get_tree().create_tween()
	death_tween.set_parallel()
	death_tween.tween_property(self, "rotation", rotation + 3*PI, 1)
	death_tween.tween_property(self, "scale", Vector2(0., 0.), 1)
	death_tween.tween_property(self, "modulate:a", 0., 1)
	death_tween.set_parallel(false)
	death_tween.tween_callback(
		func(): 
			respawn()
			)
			
func respawn() -> void:
	_create_trail()
	if respawn_tween: respawn_tween.kill()
	modulate.a = 1.
	respawn_tween = get_tree().create_tween()
	respawn_tween.tween_property(self, "global_position", Vector2.ZERO, 1)
	respawn_tween.tween_property(spawn_point, "modulate:a", 1., 0.25)
	respawn_tween.tween_property(self, "scale", Vector2(1, 1), 0.5)
	respawn_tween.tween_property(spawn_point, "modulate:a", 0.2, 0.5)
	respawn_tween.tween_callback(
		func():
			_is_active = true
			drive_sound.play()
			_activate_invincibility()
			$CollisionShape2D.set_deferred("disabled", false)
	)
	respawn_tween.tween_method(func(val): power = val, power, 1., 1. * (1 - power))

func hit(val) -> void:
	if not _is_invincible:
		damage(val)
		_activate_invincibility()
		EventManager.player_health_changed.emit()
		AudioManager.play_effect(AudioManager.player_hit_sfx)
		_shake_screen()

func damage(val) -> void:
	health -= val

func _activate_invincibility(duration: float = 3) -> void:
	_is_invincible = true
	if itween: itween.kill()
	itween = get_tree().create_tween()
	for i in range(duration):
		itween.tween_property(sprite.material, "shader_parameter/overlay_strength", 0.8, 0.1)
		itween.tween_property(sprite.material, "shader_parameter/overlay_strength", 0.0, 0.1)

	itween.chain().tween_callback(func(): _is_invincible = false)

func _shake_screen() -> void:
	$Camera2D.screen_shake(8, 0.5)

func add_health(val: float) -> void:
	EventManager.player_health_changed.emit()
	health += val
