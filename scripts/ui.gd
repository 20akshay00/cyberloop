extends CanvasLayer

@export var player: Player
@onready var power_bar := $PowerBar
@onready var health_bar := $HealthBar

var tween: Tween = null
var start_tween: Tween = null

func _ready() -> void:
	EventManager.player_health_changed.connect(_on_player_health_changed)
	
	if start_tween: start_tween.kill()
	start_tween = get_tree().create_tween()
	start_tween.set_loops()
	start_tween.tween_property($ClickToStart, "modulate:a", 0.2, 1.)
	start_tween.tween_property($ClickToStart, "modulate:a", 1, 1.)
	
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

func start() -> void:
	if start_tween: start_tween.kill()
	start_tween = get_tree().create_tween()
	start_tween.tween_property($ClickToStart, "modulate:a", 0., 0.2)

func _on_retry_button_pressed() -> void:
	TransitionManager.reload_scene()
	
func set_high_score(score: int):
	$VBoxContainer/HighScore.text = "High score: " + str(score)

func set_score(score: int):
	$VBoxContainer/CurrentScore.text = "Score: " + str(score)
