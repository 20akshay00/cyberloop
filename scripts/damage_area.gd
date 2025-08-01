extends Area2D
class_name DamageArea

var _is_active: bool = false

func _ready() -> void:
	EventManager.hole_created.emit()
	AudioManager.play_effect(AudioManager.loop_created_sfx, 10.)
	get_tree().create_timer(0.2).timeout.connect(
		func(): 
			_is_active = true
			for body in get_overlapping_bodies():
				body.die()
	)

func set_points(points:PackedVector2Array) -> void:
	$CollisionPolygon2D.polygon = points
	
	var visual_points = points.duplicate()
	visual_points.push_back(points[0])
	
	$Line2D.points = visual_points
	$Polygon2D.polygon = visual_points
	$NavigationObstacle2D.vertices = points

func _on_body_entered(body: Node2D) -> void:
	if body and _is_active:
		body.die()
