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

var side = 3600
var xmin = -side
var xmax = +side
var ymin = -side
var ymax = side

var _is_active: bool = false
var wave: int = 0

var enemy_count = 0
var enemy_count_ref = [
	1, 1, 1, 2, 2, 2, 3, 3, 3, 3,
	3, 4, 4, 4, 4, 4, 4, 4, 5, 5,
	5, 5, 5, 5, 5, 5, 6, 6, 6, 6
	]

var spawn_complete := false

var droid_count_ref = [
	0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 
	2, 0, 2, 0, 2, 0, 2, 0, 2, 0,
	2, 0, 3, 0, 3, 0, 3, 0, 3, 0
	]
	
var mine_count_ref = [
	0, 0, 0, 1, 0, 2, 0, 2, 0, 2, 
	0, 2, 2, 2, 2, 2, 0, 3, 0, 3,
	3, 0, 3, 0, 3, 0, 3, 4, 5, 5
	]

var num_lives_ref = [
	0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 2, 2, 2, 2, 2
	]

func _ready() -> void:
	EventManager.enemy_died.connect(_check_enemies)
	EventManager.enemy_self_died.connect(_check_enemies)
	
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

func _spawn_pos_random(exclude: Array[Vector2] = [], cutoff=100., maxiter=10) -> Vector2:
	exclude.push_back(player.global_position)
	for i in maxiter:
		var pos = Vector2(randf_range(xmin * 0.9, xmax * 0.9), randf_range(ymin * 0.9, ymax * 0.9))
		var flag = true
		for point in exclude:
			if (pos - point).length() < cutoff:
				flag = false
				break
		
		if flag: 
			return pos

	return Vector2(xmax, ymax)

func _change_wave() -> void:
	spawn_complete = false
	wave += 1
	
	EventManager.wave_changed.emit(wave)
	
	if wave <= 30:
		if wave > 1 : $EnemySpawnSound.play()
		enemy_count = enemy_count_ref[wave-1]
		
		_start_lives_spawn()
		_start_enemy_spawn()
		var pos = _start_droid_spawn()
		_start_mine_spawn(pos)

func check_enemies() -> void:
	enemy_count -= 1
	if enemy_count <= 0 and spawn_complete:
		get_tree().create_timer(3).timeout.connect(func(): _change_wave())

func _check_enemies() -> void:
	call_deferred("check_enemies")

func _start_enemy_spawn() -> void:
	for i in enemy_count:
		_spawn_enemy()
		await get_tree().create_timer(3.).timeout
		
	spawn_complete = true

func _start_droid_spawn(pos: Array[Vector2] = []) -> Array[Vector2]:
	for i in droid_count_ref[wave-1]:
		pos.push_back(_spawn_droid(pos))
		
	return pos 

func _start_mine_spawn(pos: Array[Vector2] = []) -> Array[Vector2]:
	for i in mine_count_ref[wave-1]:
		pos.push_back(_spawn_mine(pos))
		
	return pos

func _start_lives_spawn() -> void:
	var radius = randf_range(500, 1000)
	
	var num_lives = pickups.get_child_count()
	var n = min(max(0, 5 - num_lives), num_lives_ref[wave-1])
		
	var offset = randf() * TAU
	for i in n:
		_spawn_pickup(Vector2(radius * cos(2 * i * PI/n + offset), radius * sin(2 * i * PI/n + offset)))
	
func _spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()
	enemies.add_child(enemy)
	enemy.global_position = _spawn_pos_boundary()
	
func _spawn_droid(exclude: Array[Vector2]=[]) -> Vector2:
	var droid = droid_scene.instantiate()
	droids.add_child(droid)
	droid.global_position = _spawn_pos_random(exclude)
	return droid.global_position

func _spawn_mine(exclude: Array[Vector2] = []) -> Vector2:
	var mine = mine_scene.instantiate()
	mines.add_child(mine)
	mine.global_position = _spawn_pos_random(exclude)
	return mine.global_position
	
func _spawn_pickup(pos: Vector2) -> void:
	var health = pickup_scene.instantiate()
	pickups.add_child(health)
	health.global_position = pos
