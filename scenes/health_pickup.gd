extends Area2D

@export var health = 1

var tween: Tween = null
var death_tween: Tween = null 
var _is_active = true

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.add_health(health)
		AudioManager.play_effect(AudioManager.pick_up_sfx, -10)
		if tween: tween.kill()
		tween = get_tree().create_tween()
		tween.tween_property(self, "modulate:a", 0., 0.1)
		tween.tween_callback(func(): queue_free())

func _ready() -> void:
	scale = Vector2(randf_range(1., 1.2), randf_range(1., 1.2))
	modulate.a = 0.
	scale = Vector2(0., 0.)
	_is_active = false
	spawn()

func set_fall_state() -> void:
	if not _is_active: return 
	
	Utils.play_fall_animation(self)
	_is_active = false

func on_fall_completed() -> void:
	queue_free()

func spawn() -> void:
	var spawn_tween = get_tree().create_tween()
	spawn_tween.set_parallel()
	spawn_tween.tween_property(self, "scale", Vector2(1., 1.), 1.5)
	spawn_tween.tween_property(self, "modulate:a", 1., 1.5)
	spawn_tween.set_parallel(false)
	spawn_tween.tween_callback(func(): init())

func init() -> void:
	_is_active = true
	if tween: tween.kill()
	tween = get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.5)
	tween.tween_property(self, "scale", Vector2(1., 1.), 0.5)
