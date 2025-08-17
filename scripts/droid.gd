extends CharacterBody2D
class_name Droid

@export var projectile_scene: PackedScene
@export var fall_animation_config: FallAnimationConfig

@onready var shoot_timer = $ShootTimer
var _death_tween: Tween = null 

var target: Player = null
var dir: Vector2 = Vector2.ZERO

var _is_active: bool = true

func _ready() -> void:
	modulate.a = 0.
	scale = Vector2(0., 0.)
	_is_active = false
	spawn()

func _process(delta: float) -> void:
	if target:
		dir = target.global_position - global_position
		rotation = lerp_angle(rotation, atan2(dir.y, dir.x), 0.5)

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is Player:
		target = body
		shoot_timer.start()

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body is Player:
		target = null
		shoot_timer.stop()

func _on_shoot_timer_timeout() -> void:
	if target and _is_active:
		var projectile = projectile_scene.instantiate()
		projectile.global_position = global_position
		projectile.rotation = rotation
		projectile.velocity = 900 * Vector2(cos(rotation), sin(rotation))
		add_sibling(projectile)
		$ShootSound.play()

func set_fall_state() -> void:
	if not _is_active: return 
	_death_tween = Utils.play_fall_animation(self, _death_tween)
	_is_active = false
	EventManager.enemy_died.emit()

func on_fall_completed() -> void:
	queue_free()

func spawn() -> void:
	var spawn_tween = get_tree().create_tween()
	spawn_tween.set_parallel()
	spawn_tween.tween_property(self, "scale", Vector2(1., 1.), 1.)
	spawn_tween.tween_property(self, "modulate:a", 1., 1.)
	spawn_tween.set_parallel(false)
	spawn_tween.tween_callback(func(): _is_active = true)
