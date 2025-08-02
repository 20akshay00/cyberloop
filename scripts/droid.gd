extends CharacterBody2D
class_name Droid

@onready var shoot_timer = $ShootTimer
@export var projectile_scene: PackedScene

var target: Player = null
var dir: Vector2 = Vector2.ZERO

var death_tween: Tween = null 
var _is_active = true

func _process(delta: float) -> void:
	if target:
		dir = target.global_position - global_position
		rotation = atan2(dir.y, dir.x)

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is Player:
		target = body
		shoot_timer.start()

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body is Player:
		target = null
		shoot_timer.stop()

func _on_shoot_timer_timeout() -> void:
	if target:
		var projectile = projectile_scene.instantiate()
		projectile.global_position = global_position
		projectile.rotation = rotation
		projectile.velocity = 900 * Vector2(cos(rotation), sin(rotation))
		add_sibling(projectile)

func fall() -> void:
	die()

func die() -> void:
	if _is_active:
		_is_active = false
		if death_tween: death_tween.kill() 
		
		death_tween = get_tree().create_tween()
		death_tween.set_parallel()
		death_tween.tween_property(self, "rotation", rotation + 3*PI, 1)
		death_tween.tween_property(self, "scale", Vector2(0., 0.), 1)
		death_tween.tween_property(self, "modulate:a", 0., 1)
		death_tween.set_parallel(false)
		death_tween.tween_callback(queue_free)
