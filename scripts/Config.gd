extends Node

var platform_mobile: bool = false
var arena_xbound: float = 3800.
var arena_ybound: float = 3800.

var config: PlayerConfig = null

func _ready() -> void:
	platform_mobile = true if (OS.get_name() == "Android" or OS.has_feature("web_android") or OS.has_feature("web_ios")) else false
	var default_config: PlayerConfig = load("res://default_player_config.tres")
	config = load("user://player_config.tres") if(ResourceLoader.exists("user://player_config.tres")) else default_config.duplicate()

	if platform_mobile: config.control_scheme = PlayerConfig.CONTROL_SCHEMES.TOUCHSCREEN

func save() -> void:
	ResourceSaver.save(config, "user://player_config.tres")

func reset() -> void:
	var default_config: PlayerConfig = load("res://default_player_config.tres")
	config = default_config.duplicate()
	if platform_mobile: config.control_scheme = PlayerConfig.CONTROL_SCHEMES.TOUCHSCREEN
	
	save()

func _get(property):
	if config and property in config:
		return config.get(property)
	return null

func _set(property, value):
	if config and property in config:
		config.set(property, value)
		return true
	return false
