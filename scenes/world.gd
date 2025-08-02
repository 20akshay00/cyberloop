extends Node2D

var _is_active := false

func _ready() -> void:
	EventManager.hole_created.connect(_on_hole_created)
	EventManager.game_over.connect(_on_game_over)
	set_activity(false)

func _on_hole_created() -> void:
	pass

func _on_game_over() -> void:
	get_tree().paused = true
	TransitionManager.reload_scene()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reload"):
		TransitionManager.reload_scene()
	if not _is_active and Input.is_action_just_pressed("draw"):
		set_activity(true)
		$UI.start()

func set_activity(val: bool):
	_is_active = val
	for child in get_children():
		if "_is_active" in child:
			child._is_active = val
