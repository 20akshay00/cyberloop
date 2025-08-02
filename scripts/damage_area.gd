extends Area2D
class_name DamageArea

var _is_active: bool = false
var fade_tween: Tween = null

func _ready() -> void:
	EventManager.hole_created.emit()
	AudioManager.play_effect(AudioManager.loop_created_sfx, 10.)
	get_tree().create_timer(0.3).timeout.connect(
		func(): 
			_is_active = true
			for body in get_overlapping_bodies():
				body.fall()
				
			for area in get_overlapping_areas():
				if area.has_method("fall"): area.fall()
	)
	fade_in()

func set_points(points:PackedVector2Array) -> void:
	$CollisionPolygon2D.polygon = points
	
	$Line2D.points = points
	$Polygon2D.polygon = points
	$NavigationObstacle2D.vertices = points

	$Polygon2D.uv = generate_uvs($Polygon2D.polygon)
	
func _on_body_entered(body: Node2D) -> void:
	if body and _is_active:
		body.fall()

func fade_in() -> void:
	$Polygon2D.material.get_shader_parameter("dissolve_texture").noise.seed = randi()
	if fade_tween: fade_tween.kill()
	fade_tween = get_tree().create_tween()
	fade_tween.tween_property($Polygon2D.material, "shader_parameter/dissolve_value", 0., 0.5)

func generate_uvs(polygon: PackedVector2Array) -> PackedVector2Array:
	if polygon.is_empty():
		return PackedVector2Array()

	var points = Array(polygon)
	var xmin = points.map(func(p): return p.x).reduce(func(a, b): return min(a, b))
	var ymin = points.map(func(p): return p.y).reduce(func(a, b): return min(a, b))
	var anchor = Vector2(xmin, ymin)

	return PackedVector2Array(points.map(func(p): return (p - anchor)/5))
