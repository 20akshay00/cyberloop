extends Area2D
class_name ProximityMine

var tween: Tween = null
@onready var light := $LightSprite
@onready var explosion_timer := $ExplosionTimer
var _is_exploding := false

func explode() -> void:
	_is_exploding = true
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
	if body is Player:
		explode()
		body.hit(1)
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
