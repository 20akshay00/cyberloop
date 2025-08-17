extends Area2D
class_name ProximityMine

@export var EXPLOSION_DELAY: float = 0.15
@export var fall_animation_config: FallAnimationConfig

# onready variables
@onready var light := $LightSprite
@onready var explosion_timer := $ExplosionTimer

# state
var _is_active = true
var _is_exploding := false

var _death_tween: Tween = null 

func _ready() -> void:
	modulate.a = 0.
	scale = Vector2(0., 0.)
	_is_active = false
	spawn()

func explode() -> void:
	for body in get_overlapping_bodies():
		body.hit(1)
	
	$ExplosionSound.play()
	$Explosion.show()
	$Explosion.play("explode")	
	$Explosion.animation_finished.connect(queue_free)
	$Explosion.reparent(get_parent())

	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0., 0.2)

func _on_body_entered(body: Node2D) -> void:
	if (body is Player) and not _is_exploding:
		_is_exploding = true
		get_tree().create_timer(EXPLOSION_DELAY).timeout.connect(explode)

func spawn() -> void:
	var spawn_tween = get_tree().create_tween()
	spawn_tween.set_parallel()
	spawn_tween.tween_property(self, "scale", Vector2(1., 1.), 1.)
	spawn_tween.tween_property(self, "modulate:a", 1., 1.)
	spawn_tween.set_parallel(false)
	spawn_tween.tween_callback(func(): _is_active = true)

func set_fall_state() -> void:
	if not _is_active: return
	Utils.play_fall_animation(self, _death_tween)
	_is_active = false

func on_fall_completed() -> void:
	queue_free()
