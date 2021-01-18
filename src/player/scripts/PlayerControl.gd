extends KinematicBody

var input_direction : Vector2 # Keyboard Input and joystick
var velocity : Vector3
onready var original_rotation = -transform.basis.get_euler().y
onready var mesh = $MeshPivot
var current_fall_speed : float = 0.0

var snap : Vector3 = -get_floor_normal()

export var gravity : float = 0.98
export var speed : float = 15
export var jumpVelocity : float = 15

func get_input() -> Vector2:
	input_direction = Vector2(
		Input.get_action_strength("move_left") - Input.get_action_strength("move_right"),
		Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward"))
	if input_direction.length() > 1:
		input_direction = input_direction.normalized()
	return input_direction


var mesh_orientation = 0.0
var smooth_mesh_orientation = 0.0

func turn_mesh(delta: float) -> void:
	if get_input() != Vector2.ZERO:
		mesh_orientation = get_input().angle() + (90 * PI/180) + ($CameraPivot.transform.basis.get_euler().y - original_rotation)
		smooth_mesh_orientation = lerp_angle(smooth_mesh_orientation, mesh_orientation, delta * 11)
	$MeshPivot.set_rotation(Vector3(0,smooth_mesh_orientation,0))

func align_with_y(xform:Transform, new_y:Vector3):
	#TODO:
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
	
onready var look_raycast : RayCast = $CameraPivot/SpringArm/LookRayCast
onready var object_ref := load("res://src/level/debug_level/shared/cube_rigidbody.tscn")
func _place_object() -> void:
	if look_raycast.is_colliding():
		print('u')
		var object : Spatial = object_ref.instance()
		var ray_pos = look_raycast.get_collision_point()
		var ray_norm = look_raycast.get_collision_normal()
		get_tree().get_root().add_child(object)
		object.global_transform.origin = ray_pos
		object.global_transform = align_with_y(object.global_transform, ray_norm)

func _remove_object() -> void:
	if look_raycast.is_colliding():
		var shape := look_raycast.get_collider()
		var object = shape.get_owner()
		if object == null:
			object = shape
		elif object == get_node("/root/Game"):
			object = shape
		if object.is_in_group('removable'):
			object.queue_free()
		
func _physics_process(delta: float) -> void:
	turn_mesh(delta)
	velocity = Vector3(-get_input().x, 0, get_input().y) 
	velocity = velocity.rotated(Vector3.UP, $CameraPivot.transform.basis.get_euler().y - original_rotation) * speed
	var snap_vector = get_floor_normal() #if input_direction == Vector2.ZERO else Vector3.DOWN
	gravity = 0.98
	
	if Input.is_action_just_pressed("place_object"):
		_place_object()
	if Input.is_action_just_pressed("remove_object"):
		_remove_object()
	if Input.is_action_pressed("jump"):
		snap_vector = Vector3.ZERO
		velocity.y = jumpVelocity
		
	if !is_on_floor():
		current_fall_speed -= gravity
		current_fall_speed = max(current_fall_speed, -52)
		velocity.y += current_fall_speed
	else:
		current_fall_speed = 0
	velocity = move_and_slide_with_snap(velocity, -snap_vector, Vector3.UP, true, 4,  1.3, false)
#	velocity = move_and_slide(velocity, Vector3.UP, true, 4,  1.3, false)
	
	#Support collision with other rigid body, currently bugged, look at https://github.com/godotengine/godot/issues/31981
	for index in get_slide_count():
		var collision := get_slide_collision(index)
		if collision.collider.is_class("RigidBody"):
			collision.collider.apply_impulse(collision.position, -collision.normal * 0.00001)
