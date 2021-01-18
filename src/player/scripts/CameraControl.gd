extends Spatial

export var target : NodePath
export var mouse_sensitibity : float = 0.1
export var joystick_sensibility : float = 2.0
var input_left_joystick : Vector2 = Vector2.ZERO

var pitch : float = 0.0
var yaw : float = 0.0
var minmaxpitch : Vector2 = Vector2(90, -80)
var camera_motion : Vector3 = Vector3(0,0,0)
var smooth_cancer = Vector2.ZERO

	
func set_pitch_yaw(direction,sensivity):
	yaw -= direction.x * sensivity
	pitch -= direction.y * sensivity
	pitch = clamp(pitch, minmaxpitch.y, minmaxpitch.x)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		set_pitch_yaw(event.relative, mouse_sensitibity)
	
func _physics_process(delta: float) -> void:
	input_left_joystick = Vector2(
		Input.get_action_strength("camera_right") - Input.get_action_strength("camera_left"),
		Input.get_action_strength("camera_down") - Input.get_action_strength("camera_up"))
	
	if input_left_joystick != Vector2.ZERO:
		set_pitch_yaw(input_left_joystick, joystick_sensibility)
	var cancer = Vector2(pitch, yaw)
	smooth_cancer = smooth_cancer.linear_interpolate(cancer, 15*delta)
	$".".set_rotation_degrees(Vector3(smooth_cancer.x, smooth_cancer.y, 0))
