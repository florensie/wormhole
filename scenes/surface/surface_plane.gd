extends InnerSpace
class_name SurfacePlane

@export var redstone_scene: PackedScene

var is_moused_over: bool = false
var last_mouse_normal: Vector3
var selected_placeable: Constants.Placeable:
	set(value): selected_placeable = value


func _ready():
	SignalBus.connect("placeable_selected", _placeable_selected)


func _placeable_selected(placeable: Constants.Placeable) -> void:
	selected_placeable = placeable


func _input(event):
	# FIXME: do not register click if camera was dragged
	if is_moused_over and event is InputEventMouseButton and last_mouse_normal \
	and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		match selected_placeable:
			Constants.Placeable.WORMHOLE when _can_create_worm_hole():
				var valid = create_worm_hole(last_mouse_normal * -1, true)
				if not valid:
					print_rich("[color=yellow]Tried to create invalid wormhole")
			Constants.Placeable.REDSTONE:
				_create_redstone()


func _can_create_worm_hole() -> bool:
	var direction = grid_world.get_surface_normal(self)
	# Check if no other items above
	return not grid_world.get_neighbor_grid_item(self, direction)


func _create_redstone():
	var normal: Vector3i = grid_world.get_surface_normal(self)
	var place_pos = self.get_grid_pos() + normal
	var place_pos_item: GridItem = grid_world.get_neighbor_grid_item(self, normal)
	
	if not place_pos_item:
		var perpendicular_directions = Util.get_cardinal_vectors(normal)
		
		var item: Redstone
		for neighbor_direction in perpendicular_directions:
			var neighbor: GridItem = grid_world.get_grid_item(place_pos + Vector3i(neighbor_direction))
			if neighbor is Planet or neighbor is Redstone:
				item = grid_world.set_grid_item_at(self.get_grid_pos() + Vector3i(normal), redstone_scene)
				break
		
		# Debug stuff
		#item.vec1 = perpendical_directions[0]
		#item.vec2 = perpendical_directions[1]
		#item.vec3 = perpendical_directions[2]
		#item.vec4 = perpendical_directions[3]
		#DebugOverlay.draw_3d.add_vector(item, "vec1", 0.5)
		#DebugOverlay.draw_3d.add_vector(item, "vec2", 0.5)
		#DebugOverlay.draw_3d.add_vector(item, "vec3", 0.5)
		#DebugOverlay.draw_3d.add_vector(item, "vec4", 0.5)


func _on_area_3d_mouse_entered():
	is_moused_over = true


func _on_area_3d_mouse_exited():
	is_moused_over = false


func _on_area_3d_input_event(_camera, _event, _event_position, normal, _shape_idx):
	if normal:
		last_mouse_normal = normal
