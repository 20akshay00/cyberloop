extends CanvasLayer

func _ready() -> void:
	layer = 2
	
func change_scene(target : PackedScene) -> void:
	$ColorRect.material.set_shader_parameter("reverse", false)
	var tween = get_tree().create_tween()
	tween.tween_property($ColorRect.material, "shader_parameter/progress", 1., 0.5)
	tween.tween_callback(
		func(): get_tree().change_scene_to_packed(target); $ColorRect.material.set_shader_parameter("reverse", true)
		)
			
	tween.tween_property($ColorRect.material, "shader_parameter/progress", 0., 0.5)

func reload_scene() -> void:
	get_tree().paused = false
	AudioManager.play_effect(AudioManager.transition_sfx)
	$ColorRect.material.set_shader_parameter("reverse", false)
	var tween = get_tree().create_tween()
	tween.tween_property($ColorRect.material, "shader_parameter/progress", 1., 0.5)
	tween.tween_callback(
		func(): get_tree().reload_current_scene(); $ColorRect.material.set_shader_parameter("reverse", true)
		)
	tween.tween_property($ColorRect.material, "shader_parameter/progress", 0., 0.5)
