extends CharacterBody2D
class_name Player

@export var crack_scene: PackedScene
@export var trails: Node2D
@onready var sprite := $Sprite2D
var trail: Crack

var _is_active: bool = true
var _is_drawing: bool = false

var death_tween: Tween = null
var respawn_tween: Tween = null

var MAX_POWER: float = 1.
var power: float = 1.
var POWER_COST: float = 0.0005/5

var MAX_HEALTH: float = 3.
var health: float = 5.

var RECHARGE_DIST: float = 25.
var RECHARGE_AMOUNT: float = 0.0045

var prev_pos: Vector2 = Vector2.ZERO

@onready var drive_sound := $DriveSound
@onready var draw_sound := $DrawSound
@onready var power_full_sound := $PowerFullSound
@onready var power_empty_sound := $PowerDepletedSound
@onready var hit_sound := $HitSound
@onready var draw_start_sound := $DrawStartSound
@onready var fall_sound := $FallSound

var pitch: float = 0.

@export var spawn_point: Sprite2D # absolutely horrid architecture!

var closest_enemy_pos: Vector2 = Vector2.ZERO
var closest_enemy_dist: float = 1e10

# i-frames
var _is_invincible: bool = false
var itween: Tween = null

@export var min_speed: float = 700.0
@export var max_speed: float = 2500.0
@export var rotation_speed: float = 10.0  # radians per second
@export var sensitivity: float = 2.5  # How strongly distance affects speed

var mouse_dir := Vector2.ZERO
var mouse_distance := 0.

func _ready() -> void:
	_create_trail()
	
	drive_sound.play()
	EventManager.shake_screen.connect(_shake_screen)

func _process(delta: float) -> void:
	if _is_active:
		var target_pos = get_global_mouse_position()
		if (target_pos - global_position).length() > 10.0:
			mouse_dir = target_pos - global_position
			mouse_distance = mouse_dir.length()

		var target_rot = mouse_dir.angle() + PI/2
		rotation = lerp_angle(rotation, target_rot, rotation_speed * delta)

		var speed = min_speed + min(mouse_distance * sensitivity, max_speed)
		velocity = Vector2(cos(rotation-PI/2), sin(rotation-PI/2)) * speed
		move_and_slide()

		if Input.is_action_just_pressed("draw") and not _is_drawing:
			if power > 0.05:
				_is_drawing = true
				draw_sound.play()
			else:
				if not power_empty_sound.is_playing(): power_empty_sound.play()
				#draw_start_sound.play()

		if Input.is_action_just_released("draw") and _is_drawing:
			_is_drawing = false
			_create_trail()
			draw_sound.stop()

		if _is_drawing:
			trail.add_point(global_position)
			if trail.get_point_count() > 2:
				power -= (global_position - prev_pos).length() * POWER_COST
				if power < 0.:
					power_empty_sound.play()
					power = 0.
					_is_drawing = false
					_create_trail()
					draw_sound.stop()
		else:
			if (global_position - prev_pos).length() > RECHARGE_DIST and power < 1.:
				power += RECHARGE_AMOUNT
				if power > 1: 
					power = 1.
					power_full_sound.play()

		pitch = clampf((global_position - prev_pos).length()/20. + 1., 1., 2.)
		drive_sound.pitch_scale = pitch
		drive_sound.pitch_scale = pitch

		prev_pos = global_position
		
		if get_tree().get_nodes_in_group("enemies").size() > 0:
			$Pointer.show()
		else:
			$Pointer.hide()
		
		for enemy in get_tree().get_nodes_in_group("enemies"):
			var dist = (enemy.global_position - global_position).length()
			if dist < closest_enemy_dist:
				closest_enemy_dist = dist
				closest_enemy_pos = enemy.global_position - global_position
			
		$Pointer.rotation = lerp_angle($Pointer.rotation, atan2(closest_enemy_pos.y, closest_enemy_pos.x) - rotation, 0.1)
		closest_enemy_dist= 1e10
	
func _create_trail() -> void:
	if trail: trail.destroy()

	trail = crack_scene.instantiate()
	trails.add_child.call_deferred(trail)

func fall() -> void:
	die()
	fall_sound.play()

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
			damage(1)
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
		hit_sound.play()
		_shake_screen()

func damage(val) -> void:
	health -= val
	EventManager.player_health_changed.emit()
	EventManager.player_hit.emit()
	
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
	health += val
	EventManager.player_health_changed.emit()

func death() -> void:
	$Sprite2D.hide()
	$DeathSound.play()
	$DeathAnimation.show()
	$DeathAnimation.play()
	_is_active = false
	_is_drawing = false
	draw_sound.stop()
	drive_sound.stop()
	$CollisionShape2D.set_deferred("disabled", true)
	$DeathAnimation.animation_finished.connect(func(): EventManager.game_over.emit())
