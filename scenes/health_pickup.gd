extends Area2D

@export var health = 1

var tween: Tween = null
var death_tween: Tween = null 
var _is_active = true

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.add_health(health)
		if tween: tween.kill()
		tween = get_tree().create_tween()
		tween.tween_property(self, "modulate:a", 0., 0.1)
		tween.tween_callback(func(): queue_free())

func _ready() -> void:
	scale = Vector2(randf_range(1., 1.2), randf_range(1., 1.2))
	if tween: tween.kill()
	tween = get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5)
	tween.tween_property(self, "scale", Vector2(1., 1.), 0.5)

func fall() -> void:
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
