extends Node
class_name Utils

func play_fall_animation(entity: Node2D) -> Tween:
	if "fall_animation_config" not in entity: return null 
	if not entity._is_active: return null

	var config = entity.fall_animation_config
	entity._is_active = false

	var death_tween = get_tree().create_tween()
	death_tween.set_parallel()
	death_tween.tween_property(self, "rotation", config.angle_target, config.angle_duration)
	death_tween.tween_property(self, "scale", config.scale_target, config.scale_duration)
	death_tween.tween_property(self, "modulate:a", config.alpha_target, config.alpha_duration)
	death_tween.set_parallel(false)
	death_tween.tween_callback(queue_free)
	
	return death_tween
