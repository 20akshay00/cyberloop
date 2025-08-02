extends CanvasLayer

@export var player: Player
@onready var power_bar := $PowerBar
@onready var health_bar := $HealthBar

var tween: Tween = null

func _ready() -> void:
	EventManager.player_health_changed.connect(_on_player_health_changed)

func _process(delta: float) -> void:
	power_bar.value = player.power

func _on_player_health_changed() -> void:
	if tween: tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(health_bar, "value", player.health, 2. * abs(health_bar.value - player.health)/player.MAX_HEALTH)
	tween.tween_callback(
	func():
		if player.health == 0: player.death()
	)
