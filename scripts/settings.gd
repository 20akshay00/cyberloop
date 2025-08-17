extends Control

@export var button_base_color: Color = Color("ffffff")
@export var button_press_color: Color = Color("67c6c6")

@onready var keyboard_btn = $VBoxContainer/ControlScheme/Buttons/KeyboardButton
@onready var mouse_btn = $VBoxContainer/ControlScheme/Buttons/MouseButton
@onready var controller_btn = $VBoxContainer/ControlScheme/Buttons/ControllerButton
@onready var shader_material: ShaderMaterial = $ColorRect.material


var button_map: Dictionary
var tween: Tween

func _ready():
	if Config.platform_mobile:
		$VBoxContainer/ControlScheme.hide()

	button_map = {
		keyboard_btn: PlayerConfig.CONTROL_SCHEMES.KEYBOARD,
		mouse_btn: PlayerConfig.CONTROL_SCHEMES.MOUSE,
		controller_btn: PlayerConfig.CONTROL_SCHEMES.CONTROLLER
	}

	var group = ButtonGroup.new()
	for btn in button_map.keys():
		btn.button_group = group
		btn.toggled.connect(_on_control_button_toggled.bind(btn))

	_update_buttons(Config.control_scheme)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		deactivate()

func _on_control_button_toggled(toggled_on: bool, btn):
	if toggled_on:
		Config.control_scheme = button_map[btn]
		_update_buttons(Config.control_scheme)

func _update_buttons(active_scheme):
	for btn in button_map.keys():
		if button_map[btn] == active_scheme:
			btn.modulate = button_press_color
			btn.button_pressed = true
		else:
			btn.modulate = button_base_color
			btn.button_pressed = false

func activate() -> void:
	show()
	var col = shader_material.get_shader_parameter("tint_color")

	if tween: tween.kill()
	tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "modulate:a", 1., 0.5)
	tween.tween_property(shader_material, "shader_parameter/tint_color", Color(col.r, col.g, col.b, 0.16), 0.5)

func deactivate() -> void:
	Config.save()
	var col = shader_material.get_shader_parameter("tint_color")
	get_tree().paused = false

	if tween: tween.kill()
	tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property(self, "modulate:a", 0., 0.5)
	tween.tween_property(shader_material, "shader_parameter/tint_color", Color(col.r, col.g, col.b, 0.), 0.5)
	tween.set_parallel(false)
	tween.tween_callback(
		func():
			hide()
	)
