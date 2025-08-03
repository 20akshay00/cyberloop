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

func _ready() -> void:
	var enemy = enemy_scene.instantiate()
	enemies.add_child(enemy)
	enemy.global_position = Vector2(500, 500)
