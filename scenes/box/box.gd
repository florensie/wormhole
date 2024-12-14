extends GridItem
class_name Box
## Blocks that build up the inside of the level.

@export var wormhole_inside_scene: PackedScene

var is_moused_over: bool = false
var last_mouse_normal: Vector3


func _input(event):
	if is_moused_over and event is InputEventMouseButton and last_mouse_normal \
	and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() \
	and _can_create_worm_hole():
		var valid = _create_worm_hole(self, last_mouse_normal * -1)
		if not valid:
			print_rich("[color=yellow]Tried to create invalid wormhole")


func _can_create_worm_hole() -> bool:
	# TODO: 1. this box MUST be in the surface
	#       2. this box CANNOT be on an edge
	return true


## Try to create a wormhole, returns true if the wormhole position is valid and was created
func _create_worm_hole(item: Node3D, direction: Vector3i) -> bool:
	var is_valid = true # TODO: not yet checking for intersecting with empty tiles
	var neighbor: Node3D = grid_world.get_neighbor_grid_item(item, direction)
	
	# Recurse until no more neighbors are found
	if neighbor:
		is_valid = _create_worm_hole(neighbor, direction) if neighbor is Box else false
	
	if is_valid:
		grid_world.replace_grid_item(item, wormhole_inside_scene)
	
	return is_valid


func _on_area_3d_mouse_entered():
	is_moused_over = true


func _on_area_3d_mouse_exited():
	is_moused_over = false


func _on_area_3d_input_event(camera, event, event_position, normal, shape_idx):
	if normal:
		last_mouse_normal = normal
