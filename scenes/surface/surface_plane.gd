extends InnerSpace
class_name SurfacePlane


var is_moused_over: bool = false
var last_mouse_normal: Vector3


func _input(event):
	if is_moused_over and event is InputEventMouseButton and last_mouse_normal \
	and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() \
	and _can_create_worm_hole():
		var valid = create_worm_hole(last_mouse_normal * -1, true)
		if not valid:
			print_rich("[color=yellow]Tried to create invalid wormhole")


func _can_create_worm_hole() -> bool:
	# TODO: Check not covered by anything else
	return true


func _on_area_3d_mouse_entered():
	is_moused_over = true


func _on_area_3d_mouse_exited():
	is_moused_over = false


func _on_area_3d_input_event(_camera, _event, _event_position, normal, _shape_idx):
	if normal:
		last_mouse_normal = normal
