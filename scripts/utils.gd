extends Node
class_name Utils

static func play_fall_animation(entity: Node2D, death_tween: Tween = null) -> Tween:
	if "fall_animation_config" not in entity: return null 
	if not entity._is_active: return null

	var config = entity.fall_animation_config
	entity._is_active = false
	
	if death_tween: death_tween.kill()
	death_tween = entity.get_parent().create_tween()
	death_tween.set_parallel()
	death_tween.tween_property(entity, "rotation", config.angle_target, config.angle_duration)
	death_tween.tween_property(entity, "scale", config.scale_target, config.scale_duration)
	death_tween.tween_property(entity, "modulate:a", config.alpha_target, config.alpha_duration)
	death_tween.set_parallel(false)
	death_tween.tween_callback(entity.on_fall_completed)
	
	return death_tween
