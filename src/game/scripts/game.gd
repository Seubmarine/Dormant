extends Node

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

onready var is_fullscreen := false
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		if is_fullscreen:
			is_fullscreen = false
		else:
			is_fullscreen = true
		OS.window_fullscreen = is_fullscreen
