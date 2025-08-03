extends CharacterBody2D
class_name Enemy

var death_tween: Tween = null 
var _is_active = true

@onready var sprite: Node2D = $Sprite
var target: Player = null

var run: bool = false
var _state: bool = true

var chase_speed: float = 850
var run_speed: float = 600
var prev_pos := Vector2.ZERO

@onready var drive_sound := $DriveSound

var spawn_tween: Tween = null

func _ready() -> void:
	target = get_tree().get_nodes_in_group("player")[0]
	add_to_group("enemies")
	drive_sound.play()
	
	modulate.a = 0.
	scale = Vector2(0., 0.)
	_is_active = false
	spawn()

func fall() -> void:
	die()

func die() -> void:
	if _is_active:
		drive_sound.stop()
		EventManager.enemy_died.emit()
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
	if _is_active and target._is_active:
		$NavigationAgent2D.target_position = target.global_position
		var nav_point_dir := to_local($NavigationAgent2D.get_next_path_position())
		
		if (target.trail.get_point_count() > 10 and target.velocity.length() > 1100.):
			if _state:
				run = true if randf() > 0.7 else false
				_state = false
			
			if run: 
				$NavigationAgent2D.set_velocity(nav_point_dir.normalized() * -run_speed)
			else:
				$NavigationAgent2D.set_velocity(nav_point_dir.normalized() * chase_speed)
		else:
			_state = true
			$NavigationAgent2D.set_velocity(nav_point_dir.normalized() * chase_speed)
	else:
		velocity = Vector2.ZERO
		move_and_slide()
	
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	sprite.rotation = atan2(velocity.y, velocity.x) + PI/2
	drive_sound.pitch_scale = clampf((global_position - prev_pos).length()/20. + 1., 1., 2.)
	prev_pos = global_position
	move_and_slide()
	
func hit(val) -> void:
	die()

func _on_hit_area_body_entered(body: Node2D) -> void:
	if body is Player and _is_active:
		body.hit(1)
		_is_active = false
		$DeathSound.play()
		$Sprite.hide()
		
		var death_anim = $DeathAnimation
		death_anim.reparent(get_parent())
		death_anim.animation_finished.connect(func(): death_anim.queue_free())
		death_anim.show()
		death_anim.play()
		EventManager.enemy_self_died.emit()
		queue_free()
		
func spawn() -> void:
	if spawn_tween: spawn_tween.kill()
	spawn_tween = get_tree().create_tween()
	spawn_tween.set_parallel()
	spawn_tween.tween_property(self, "scale", Vector2(1., 1.), 1.)
	spawn_tween.tween_property(self, "modulate:a", 1., 1.)
	spawn_tween.set_parallel(false)
	spawn_tween.tween_callback(func(): _is_active = true)
