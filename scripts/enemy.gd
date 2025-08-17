extends CharacterBody2D
class_name Enemy

@export_subgroup("Attributes")
@export var CHASE_SPEED: float = 850.
@export var RUN_SPEED: float = 600.
@export var RUN_PROBABILITY: float = 0.3
@export_subgroup("Audio")
@export var MIN_PITCH: float = 1.
@export var MAX_PITCH: float = 2.
@export_subgroup("Visuals")
@export var fall_animation_config: FallAnimationConfig

# onready variables
@onready var _sprite: Node2D = $Sprite
@onready var _navigation_agent: NavigationAgent2D = $NavigationAgent2D
# audio
@onready var drive_sound := $DriveSound
@onready var fall_sound := $FallSound
@onready var death_sound := $DeathSound

var _death_tween: Tween = null 

# state
var _is_active = true
var run: bool = false
var _state: bool = true

# data
var _target: Player = null

func _ready() -> void:
	_target = get_tree().get_nodes_in_group("player")[0]
	add_to_group("enemies")
	drive_sound.play()
	
	modulate.a = 0.
	scale = Vector2(0., 0.)
	_is_active = false
	spawn()

func set_fall_state() -> void:
	if not _is_active: return
	# audio
	drive_sound.stop()
	AudioManager.play_spatial_effect(AudioManager.fall_sfx, global_position, 0., "Misc")

	# visual
	_death_tween = Utils.play_fall_animation(self, _death_tween)
	_death_tween.tween_callback(queue_free)

	# state
	_is_active = false
	process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO
	EventManager.enemy_died.emit()

func on_fall_completed() -> void:
	queue_free()

func die() -> void:
	if _is_active:
		drive_sound.stop()
		AudioManager.play_spatial_effect(AudioManager.fall_sfx, global_position, 0., "Misc")
		
		EventManager.enemy_died.emit()
		
		_is_active = false
		process_mode = Node.PROCESS_MODE_DISABLED
		velocity = Vector2.ZERO
	
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate:a", 0., 0.2)

func _physics_process(delta: float) -> void:
	if _is_active and _target._is_active:
		_navigation_agent.target_position = _target.global_position
		var nav_point_dir := to_local(_navigation_agent.get_next_path_position())
		
		if _target.is_vulnerable():
			if _state:
				run = true if randf() < RUN_PROBABILITY else false
				_state = false
			
			if run: 
				_navigation_agent.set_velocity(nav_point_dir.normalized() * -RUN_SPEED)
			else:
				_navigation_agent.set_velocity(nav_point_dir.normalized() * CHASE_SPEED)
		else:
			_state = true
			_navigation_agent.set_velocity(nav_point_dir.normalized() * CHASE_SPEED)
	else:
		velocity = Vector2.ZERO
		move_and_slide()
	
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	_update_rotation()
	_update_pitch()
	move_and_slide()

func _update_rotation() -> void:
	_sprite.rotation = atan2(velocity.y, velocity.x) + PI/2

func _update_pitch() -> void:
	var _pitch = MIN_PITCH + (MAX_PITCH - MIN_PITCH) * velocity.length() / CHASE_SPEED
	drive_sound.pitch_scale = _pitch

func hit(val) -> void:
	die()

func _on_hit_area_body_entered(body: Node2D) -> void:
	if body is Player and _is_active:
		body.hit(1)
		_is_active = false
		death_sound.play()
		$Sprite.hide()
		
		var death_anim = $DeathAnimation
		death_sound.reparent(death_anim)
		death_anim.reparent(get_parent())
		death_anim.animation_finished.connect(func(): death_anim.queue_free())
		death_anim.show()
		death_anim.play()
		EventManager.enemy_self_died.emit()
		queue_free()
		
func spawn() -> void:
	var _spawn_tween = get_tree().create_tween()
	_spawn_tween.set_parallel()
	_spawn_tween.tween_property(self, "scale", Vector2(1., 1.), 1.)
	_spawn_tween.tween_property(self, "modulate:a", 1., 1.)
	_spawn_tween.set_parallel(false)
	_spawn_tween.tween_callback(func(): _is_active = true)
