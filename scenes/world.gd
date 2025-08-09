extends Node2D

var _is_active := false
var high_score: Array = [0, 0]
var score: int = 0

var multiplier: int = 1
var mode: int = 0 # 0 is easy, 1 is hardcore

func _ready() -> void:
	Engine.max_fps = 60
	_load_scores()
	$UI.set_high_score(high_score[mode])
	EventManager.hole_created.connect(_on_hole_created)
	EventManager.game_over.connect(_on_game_over)
	EventManager.enemy_died.connect(_on_enemy_died)
	EventManager.enemy_self_died.connect(_on_enemy_self_died)
	EventManager.player_hit.connect(_on_player_hit)
	EventManager.wave_changed.connect(_on_wave_changed)
	set_activity(false)
	
func _on_hole_created() -> void:
	pass

func _on_game_over() -> void:
	get_tree().paused = true
	if score > high_score[mode]: 
		high_score[mode] = score
		_save_data()
		
	TransitionManager.reload_scene()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reload"):
		TransitionManager.reload_scene()
	if not _is_active and Input.is_action_just_pressed("draw"):
		mode = 0
		set_activity(true)
		$UI.set_high_score(high_score[mode])
		$UI.start()
	if not _is_active and Input.is_action_just_pressed("undraw"):
		mode = 1
		set_activity(true)
		$UI.set_high_score(high_score[mode])
		$UI.start()

func set_activity(val: bool):
	_is_active = val
	for child in get_children():
		if "_is_active" in child:
			child._is_active = val
			
func _load_scores() -> void:
	if FileAccess.file_exists("user://save_data_v2.json"):
		FileAccess.open("user://save_data_v2.json", FileAccess.READ)
		var json := JSON.new()
		var error := json.parse(FileAccess.get_file_as_string("user://save_data_v2.json"))
		if error == OK:
			var data = json.data
			high_score = data["high_score"]

func _save_data() -> void:
	var save_data := {"high_score": high_score}
	var save_file := FileAccess.open("user://save_data_v2.json", FileAccess.WRITE)
	save_file.store_line(JSON.stringify(save_data))

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_data()

func _on_enemy_died() -> void:
	score += 10
	$UI.set_score(score)

func _on_player_hit() -> void:
	score -= 5
	$UI.set_score(score)

func reset_data() -> void:
	high_score[0] = 0
	high_score[1] = 0
	_save_data()

func _on_enemy_self_died() -> void:
	score -= 10
	$UI.set_score(score)
	
func _on_wave_changed(wave: int) -> void:
	score += 5 * wave
	if wave > 30: score += 500
	$UI.set_score(score)

	if wave <= 30:
		if (mode == 0):
			for child in $Trails.get_children():
				if child is DamageArea:
					child.despawn()
	else:
		_on_game_over()


func _on_touch_screen_button_pressed() -> void:
	EventManager.draw_enabled.emit()

func _on_touch_screen_button_released() -> void:
	EventManager.draw_disabled.emit()
