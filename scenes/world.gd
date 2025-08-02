extends Node2D

func _ready() -> void:
	EventManager.hole_created.connect(_on_hole_created)
	EventManager.game_over.connect(_on_game_over)

func _on_hole_created() -> void:
	pass

func _on_game_over() -> void:
	get_tree().paused = true

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reload"):
		TransitionManager.reload_scene()
