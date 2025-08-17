extends Resource
class_name PlayerConfig

enum CONTROL_SCHEMES {MOUSE, KEYBOARD, CONTROLLER, TOUCHSCREEN}

@export var control_scheme = CONTROL_SCHEMES.MOUSE

@export var cursor_sensitivity: float = 4.3 # fps dependant?
@export var mobile_joystick_sensitivity: float = 600.

# for keyboard controls
@export var rotation_sensitivity: float = 4.
@export var acceleration_sensitivity: float = 800.

@export var crt_enabled: bool = true
