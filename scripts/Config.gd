extends Node

var platform_mobile: bool = false
var arena_xbound: float = 3800.
var arena_ybound: float = 3800.

func _ready() -> void:
	platform_mobile = true if (OS.get_name() == "Android" or OS.has_feature("web_android") or OS.has_feature("web_ios")) else false
