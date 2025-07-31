extends CharacterBody2D
class_name Player

@export var crack_scene: PackedScene
@export var trails: Node2D
@onready var sprite := $Sprite2D
var trail: Crack

var dir: Vector2 = Vector2.ZERO
var _is_active: bool = true
var _is_drawing: bool = false

var death_tween: Tween = null
var respawn_tween: Tween = null

func _ready() -> void:
	_create_trail()

func _process(delta: float) -> void:
	if _is_active:
		global_position = lerp(position, get_global_mouse_position(), 0.035)
		
		dir = get_global_mouse_position() - position
		rotation = atan2(dir.y, dir.x) + PI/2

		if Input.is_action_just_pressed("draw") and not _is_drawing:
			_is_drawing = true
		if Input.is_action_just_released("draw") and _is_drawing:
			_is_drawing = false
			_create_trail()

		if _is_drawing:
			trail.add_point(global_position)

func _create_trail() -> void:
	if trail: trail.destroy()

	trail = crack_scene.instantiate()
	trails.add_child.call_deferred(trail)

func die() -> void:
	_is_active = false
	_is_drawing = false
	
	if death_tween: death_tween.kill() 
	
	death_tween = get_tree().create_tween()
	death_tween.set_parallel()
	death_tween.tween_property(self, "rotation", rotation + 3*PI, 1)
	death_tween.tween_property(self, "scale", Vector2(0., 0.), 1)
	death_tween.tween_property(self, "modulate:a", 0., 1)
	death_tween.set_parallel(false)
	death_tween.tween_callback(
		func(): 
			respawn()
			)
			
func respawn() -> void:
	_create_trail()
	if respawn_tween: respawn_tween.kill()
	respawn_tween = get_tree().create_tween()
	respawn_tween.tween_property(self, "global_position", Vector2.ZERO, 1)

	respawn_tween.set_parallel()
	respawn_tween.tween_property(self, "scale", Vector2(1, 1), 0.5)
	respawn_tween.tween_property(self, "modulate:a", 1, 0.5)
	respawn_tween.set_parallel(false)
	respawn_tween.tween_callback(
		func():
			_is_active = true
	)
