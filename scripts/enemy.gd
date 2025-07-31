extends CharacterBody2D

var death_tween: Tween = null 
var _is_active = true

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
