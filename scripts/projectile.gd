extends Area2D

var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	activate()

func _process(delta: float) -> void:
	global_position += delta * velocity

func activate() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	get_tree().create_timer(5.).timeout.connect(
		func():
			queue_free()
	)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		queue_free()
