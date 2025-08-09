extends CanvasLayer

@export var player: Player
@onready var power_bar := $PowerBar
@onready var health_bar := $HealthBar
@onready var score_label := $VBoxContainer/CurrentScore

var tween: Tween = null
var start_tween: Tween = null
var title_tween: Tween = null
var wave_tween: Tween = null
var score_tween: Tween = null

func _ready() -> void:
	EventManager.wave_changed.connect(set_wave)
	EventManager.player_health_changed.connect(_on_player_health_changed)
	
	if start_tween: start_tween.kill()
	start_tween = get_tree().create_tween()
	start_tween.set_loops()
	start_tween.tween_property($ClickToStart, "modulate:a", 0.2, 1.)
	start_tween.tween_property($ClickToStart, "modulate:a", 1, 1.)
	
	if title_tween: title_tween.kill()
	title_tween = get_tree().create_tween()
	title_tween.set_loops()
	title_tween.tween_property($Title, "scale", Vector2(1.4, 1.4), 1.)
	title_tween.tween_property($Title, "scale", Vector2(1.3, 1.3), 1.)
	
func _process(delta: float) -> void:
	power_bar.value = player.power

func _on_player_health_changed() -> void:
	if tween: tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(health_bar, "value", player.health, 2. * abs(health_bar.value - player.health)/player.MAX_HEALTH)
	tween.tween_callback(
	func():
		if player.health <= 0: player.death()
	)

func start() -> void:
	if start_tween: start_tween.kill()
	start_tween = get_tree().create_tween()
	start_tween.tween_property($ClickToStart, "modulate:a", 0., 0.2)

	if title_tween: title_tween.kill()
	title_tween = get_tree().create_tween()
	title_tween.tween_property($Title, "modulate:a", 0., 0.2)

func _on_retry_button_pressed() -> void:
	TransitionManager.reload_scene()
	
func set_high_score(score: int):
	$VBoxContainer/HighScore.text = "High score: " + str(score)

func set_score(score: int):
	score_label.text = "Score: " + str(score)
	#if score_tween: score_tween.kill()
	#score_tween = get_tree().create_tween()
	#score_tween.tween_property(score_label, "scale", Vector2(1.2, 1.2), 0.5)
	#score_tween.tween_property(score_label, "scale", Vector2(1., 1.), 0.5)

func set_wave(wave: int):
	$WaveLabel.text = "Wave " + str(wave)
	if wave_tween: wave_tween.kill()
	wave_tween = get_tree().create_tween()
	wave_tween.tween_property($WaveLabel, "scale", Vector2(1.3, 1.3), 0.25)
	wave_tween.tween_property($WaveLabel, "scale", Vector2(1., 1.), 0.25)
