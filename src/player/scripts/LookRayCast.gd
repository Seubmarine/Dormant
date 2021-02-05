extends RayCast

signal grabbable(object)
signal removable(object)
signal placable(collision_point, collision_normal)

func _process(delta: float) -> void:
	if is_colliding():
		var collider = get_collider()
		#When removing an object with queue_free,
		#the raycast can still detect the collider and give a null instance,
		#to prevent it we check if it is a null instance 
		if is_instance_valid(collider):
			
			var object = collider.get_owner()
			
			if object.is_in_group("grabbable"):
				emit_signal("grabbable", object)
			
			if object.is_in_group("removable"):
				emit_signal("removable", object)
			
			if !object.is_in_group("not_placable") and Input.is_action_just_pressed("place_object"):
				emit_signal("placable", get_collision_point(), get_collision_normal())
