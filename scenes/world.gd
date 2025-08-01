extends Node2D

func _ready() -> void:
	EventManager.hole_created.connect(_on_hole_created)
	
func _on_hole_created() -> void:
	$NavigationRegion2D.bake_navigation_polygon()
