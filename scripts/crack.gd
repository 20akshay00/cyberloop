extends Line2D
class_name Crack

var _is_orphan: bool = false
var _max_points: int = 100
var intersect_idx: int = -1

var damage_area_scene: PackedScene = load("res://scenes/damage_area.tscn")
var crack_scene: PackedScene = load("res://scenes/crack.tscn")

func _ready() -> void:
	_is_orphan = false

func _process(delta: float) -> void:
	if _is_orphan:
		if get_point_count() > 0:
			remove_point(0)
		else:
			queue_free()
		return 

	if get_point_count() > _max_points: remove_point(0)
	
	for idx in range(points.size()-3):
		if Geometry2D.segment_intersects_segment(points[idx], points[idx+1], points[-2], points[-1]):
			intersect_idx = idx
			break

	if intersect_idx >= 0:
		var damage_area = damage_area_scene.instantiate()
		damage_area.set_points(points.slice(intersect_idx, points.size()-1))
		add_sibling(damage_area)
		
		var crack = crack_scene.instantiate()
		crack.points = points.slice(0, intersect_idx)
		add_sibling(crack)
		crack.destroy()

		clear_points()
		intersect_idx = -1

func destroy():
	_is_orphan = true
