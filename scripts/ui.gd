extends CanvasLayer

@export var player: Player
@onready var power_bar := $PowerBar

func _process(delta: float) -> void:
	power_bar.value = player.power
