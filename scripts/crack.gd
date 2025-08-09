extends Line2D
class_name Crack

var _is_orphan: bool = false
var _max_points: int = 90
var intersect_idx: int = -1

@export var damage_area_scene: PackedScene

var shape_points: PackedVector2Array = []

const spawn_side: float = 50.
var spawn_area := PackedVector2Array(
	[
		Vector2(-spawn_side, -spawn_side), 
		Vector2(-spawn_side, spawn_side), 
		Vector2(spawn_side, spawn_side), 
		Vector2(spawn_side, -spawn_side)
		]
)

const VALID_COLOR := Color("#79f5f6")
const ERR_COLOR := Color("#f64747")
var error_tween: Tween = null

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
		shape_points = points.slice(intersect_idx, points.size()-1)
		
		if calculate_area(shape_points) > 5000:
			if (Geometry2D.intersect_polygons(shape_points, spawn_area).size() == 0) and (Geometry2D.decompose_polygon_in_convex(shape_points).size() > 0):
					var damage_area = damage_area_scene.instantiate()
					damage_area.set_points(shape_points)
					add_sibling(damage_area)
				
					var crack = self.duplicate()
					crack.points = points.slice(0, intersect_idx)
					add_sibling(crack)
					crack.destroy()
					clear_points()
			else:
				_throw_error()
				
		intersect_idx = -1

func destroy():
	_is_orphan = true

func calculate_area(mesh_vertices: PackedVector2Array) -> float:
	var result := 0.0
	var num_vertices := mesh_vertices.size()

	for q in range(num_vertices):
		var p = (q - 1 + num_vertices) % num_vertices
		result += mesh_vertices[q].cross(mesh_vertices[p])
	
	return abs(result) * 0.5

func _throw_error() -> void:
	EventManager.shake_screen.emit()
	AudioManager.play_effect(AudioManager.loop_invalid_sfx)
	if error_tween: error_tween.kill()
	error_tween = get_tree().create_tween()
	error_tween.tween_property(self, "default_color", ERR_COLOR, 0.25)
	error_tween.tween_property(self, "default_color", VALID_COLOR, 0.25)
