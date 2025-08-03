extends Node2D

@export var enemy_scene: PackedScene
@export var enemies: Node2D

@export var droid_scene: PackedScene
@export var droids: Node2D

@export var mine_scene: PackedScene
@export var mines: Node2D

@export var pickup_scene: PackedScene
@export var pickups: Node2D

@export var player: Player

var side = 3800
var xmin = -side
var xmax = +side
var ymin = -side
var ymax = side

var _is_active: bool = false
var wave: int = 0

func _ready() -> void:
	_change_wave()

func _spawn_enemy() -> void:

	var enemy = enemy_scene.instantiate()
	enemies.add_child(enemy)
	enemy.global_position = _spawn_pos_player()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("undraw"):
		_change_wave()

func _spawn_pos_player(radius: float = 5) -> Vector2:
	var base_angle = player.velocity.angle()
	var offset_angle = base_angle + PI  # opposite direction
	var angle_variation = PI/3  # +/- 30 degrees variation
	var final_angle = offset_angle + randf_range(-angle_variation, angle_variation)

	var offset = Vector2(cos(final_angle), sin(final_angle)) * radius
	return player.global_position

func _spawn_pos_boundary() -> Vector2:
	var player_pos = player.global_position
	var player_quad = Vector2(sign(player_pos.x), sign(player_pos.y))

	var chosen = -player_quad
	
	var x = randf_range(0, xmax) if chosen.x > 0 else randf_range(xmin, 0)
	var y = randf_range(0, ymax) if chosen.y > 0 else randf_range(ymin, 0)

	if randf() > 0.5:
		y = ymax if chosen.y > 0 else ymin
	else:
		x = xmax if chosen.x > 0 else xmin
	
	return Vector2(x, y)

func _change_wave() -> void:
	wave += 1
	EventManager.wave_changed.emit(wave)
