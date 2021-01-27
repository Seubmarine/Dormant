extends Node

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

onready var is_fullscreen := false
onready var is_captured := true
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		if is_fullscreen:
			is_fullscreen = false
		else:
			is_fullscreen = true
		OS.window_fullscreen = is_fullscreen
	if Input.is_action_just_pressed("ui_cancel"):
		is_fullscreen = !is_fullscreen
		print(is_fullscreen)
		if is_fullscreen:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
