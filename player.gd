extends Node3D
@onready var forward_zone = $Area3D;
@onready var debug_target_line = $DebugTargetLocator;

var jump_timer = 0.0;
var objects_in_forward_zone = {};
var closest_object;

func _process(delta):
	if (!objects_in_forward_zone.is_empty() && objects_in_forward_zone.values().size() > 1):
		var min_distance = 10^50;
		for i in objects_in_forward_zone.values():
			var distance = i.global_position.distance_to(global_position);
			if distance < min_distance:
				min_distance = distance;
				closest_object = i; 
		pass;
	
	if (!objects_in_forward_zone.is_empty()):
		debug_target_line.transform = Transform3D.IDENTITY.scaled(Vector3(1,1,1) * debug_target_line.global_position.distance_to(objects_in_forward_zone.values()[0].global_position)); 
		debug_target_line.position += Vector3(0,2,0);
		debug_target_line.look_at(objects_in_forward_zone.values()[0].global_position);
	else:
		debug_target_line.transform = Transform3D.IDENTITY.translated(Vector3(0,2,0));
	
	if (jump_timer > 0.0):
		jump_timer = clamp(jump_timer - delta, 0.0, 100.0); 
	elif (Input.is_key_pressed(KEY_SPACE)):
		position += Vector3(3.0, 0, 0);
		jump_timer = 0.3;
	elif (Input.is_key_pressed(KEY_SHIFT)):
		position -= Vector3(3.0, 0, 0);
		jump_timer = 0.3;
	elif (Input.is_key_pressed(KEY_W) && !objects_in_forward_zone.is_empty()):
		position = objects_in_forward_zone.values()[0].global_position;

func _on_forward_zone_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	objects_in_forward_zone[area_rid] = area.shape_owner_get_owner(area_shape_index);
	print("Object entered zone.");

func _on_forward_zone_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	objects_in_forward_zone.erase(area_rid);
	print("Object left zone.");
