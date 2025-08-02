extends CharacterBody2D
class_name Enemy

var death_tween: Tween = null 
var _is_active = true

@onready var sprite: Node2D = $Sprite
var target: Player = null

var run: bool = false
var _state: bool = true

func _ready() -> void:
	target = get_tree().get_nodes_in_group("player")[0]
	add_to_group("enemies")

func fall() -> void:
	die()

func die() -> void:
	if _is_active:
		_is_active = false
		process_mode = Node.PROCESS_MODE_DISABLED
		velocity = Vector2.ZERO
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
		var nav_point_dir := to_local($NavigationAgent2D.get_next_path_position())
		
		print((target.global_position - target.prev_pos).length())
		if (target.trail.get_point_count() > 50 and (target.global_position - target.prev_pos).length() > 10.) or target._is_invincible:
			if _state:
				run = true if randf() > 0.2 else false
				_state = false
			
			if run: 
				$NavigationAgent2D.set_velocity(nav_point_dir.normalized() * -550.)
			else:
				$NavigationAgent2D.set_velocity(nav_point_dir.normalized() * 900.)
		else:
			_state = true
			$NavigationAgent2D.set_velocity(nav_point_dir.normalized() * 900.)

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	sprite.rotation = atan2(velocity.y, velocity.x) + PI/2
	
	move_and_slide()
	
func hit(val) -> void:
	die()

func _on_hit_area_body_entered(body: Node2D) -> void:
	if body is Player:
		body.hit(1)
		queue_free()
