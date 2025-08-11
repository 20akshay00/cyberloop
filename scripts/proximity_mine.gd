extends Area2D
class_name ProximityMine

var tween: Tween = null
@onready var light := $LightSprite
@onready var explosion_timer := $ExplosionTimer
var _is_exploding := false

var death_tween: Tween = null 
var _is_active = true

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
	$Explosion.animation_finished.connect(
		func():
			queue_free()
	)
	$Explosion.reparent(get_parent())

	if tween: tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0., 0.2)

func _on_body_entered(body: Node2D) -> void:
	if (body is Player) and not _is_exploding:
		_is_exploding = true
		get_tree().create_timer(0.05).timeout.connect(explode)

		#if explosion_timer.is_stopped():
			#explosion_timer.start()
			#if tween: tween.kill()
			#tween = get_tree().create_tween()
			#tween.tween_property(light, "modulate:a", 0., 0.1)
			#tween.tween_property(light, "modulate:a", 1., 0.1)
			#tween.set_loops()

#func _on_body_exited(body: Node2D) -> void:
	#if get_overlapping_bodies().size() == 0:
		#explosion_timer.stop()
		#if tween: tween.kill()
		#light.modulate.a = 0.
#
#func _on_explosion_timer_timeout() -> void:
	#if not _is_exploding: explode()
	#for body in get_overlapping_bodies():
		#if body is Player:
			#print("hi")
			#body.hit(1)

func fall() -> void:
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

func spawn() -> void:
	var spawn_tween = get_tree().create_tween()
	spawn_tween.set_parallel()
	spawn_tween.tween_property(self, "scale", Vector2(1., 1.), 1.)
	spawn_tween.tween_property(self, "modulate:a", 1., 1.)
	spawn_tween.set_parallel(false)
	spawn_tween.tween_callback(func(): _is_active = true)
