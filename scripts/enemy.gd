extends CharacterBody2D
class_name Enemy

var death_tween: Tween = null 
var _is_active = true

@export var target: Player = null
@onready var sprite: Node2D = $Sprite

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

func _physics_process(delta: float) -> void:
	if _is_active:
		$NavigationAgent2D.target_position = target.global_position
		var nav_point_dir := to_local($NavigationAgent2D.get_next_path_position()).normalized()
		velocity = nav_point_dir * 500.
		sprite.rotation = atan2(velocity.y, velocity.x) + PI/2
		
		move_and_slide()

#func _on_timer_timeout() -> void:
	#if $NavigationAgent2D.target_position != target.global_position:
		#$NavigationAgent2D.target_position = target.global_position
	#$Timer.start()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
