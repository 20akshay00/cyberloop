extends CanvasLayer

var tween: Tween = null

@onready var card := $TextureRect
@onready var title := $VBoxContainer/Title
@onready var highscore := $VBoxContainer/HighScore
@onready  var score := $VBoxContainer/CurrentScore
@onready var retry := $VBoxContainer/RetryButton

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	#EventManager.game_over.connect(_on_game_over)
	card.modulate.a = 0.
	title.modulate.a = 0.
	score.modulate.a = 0.
	highscore.modulate.a = 0.
	retry.modulate.a = 0.
	
func _on_game_over() -> void:
	show()
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(card, "modulate:a", 1., 0.5)
	tween.tween_property(title, "modulate:a", 1., 0.5)

	tween.tween_property(highscore, "modulate:a", 1., 0.5)
	tween.tween_property(score, "modulate:a", 1., 0.5)
	tween.tween_property(retry, "modulate:a", 1., 0.5)

func _on_retry_button_pressed() -> void:
	TransitionManager.reload_scene()
