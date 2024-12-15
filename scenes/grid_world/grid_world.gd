extends Node
class_name GridWorld

@export var size: int = 7
@export var inner_scene: PackedScene
@export var edge_scene: PackedScene
@export var corner_scene: PackedScene
@export var plane_scene: PackedScene
@export var planet_scene: PackedScene
@export var obstacle_scene: PackedScene
@export var box_size: int = 1

@onready var surface_lookup: SurfaceLookup = $SurfaceLookup

## 0 = nothing
## 1 = obstacle
## 2 = planet1
## 3 = planet2
## 4 = planet3
## Size of arrays should be size of grid - 2 (for the edges)
# TODO: unhardcode using resources/json/whatever
const faces = {
	Vector3.MODEL_REAR: [
		[0, 0, 0, 4, 0],
		[1, 0, 0, 1, 0],
		[0, 2, 1, 0, 0],
		[0, 0, 0, 3, 0],
		[0, 1, 0, 0, 1],
	],
	Vector3.MODEL_TOP: [
		[0, 0, 0, 4, 0],
		[1, 0, 0, 1, 0],
		[0, 2, 1, 0, 0],
		[0, 0, 0, 3, 0],
		[0, 1, 0, 0, 1],
	],
	Vector3.MODEL_FRONT: [
		[0, 0, 0, 4, 0],
		[1, 0, 0, 1, 0],
		[0, 2, 1, 0, 0],
		[0, 0, 0, 3, 0],
		[0, 1, 0, 0, 1],
	],
	Vector3.MODEL_BOTTOM: [
		[0, 0, 0, 4, 0],
		[1, 0, 0, 1, 0],
		[0, 2, 1, 0, 0],
		[0, 0, 0, 3, 0],
		[0, 1, 0, 0, 1],
	],
	Vector3.MODEL_LEFT: [
		[0, 0, 0, 4, 0],
		[1, 0, 0, 1, 0],
		[0, 2, 1, 0, 0],
		[0, 0, 0, 3, 0],
		[0, 1, 0, 0, 1],
	],
	Vector3.MODEL_RIGHT: [
		[0, 0, 0, 4, 0],
		[1, 0, 0, 1, 0],
		[0, 2, 1, 0, 0],
		[0, 0, 0, 3, 0],
		[0, 1, 0, 0, 1],
	],
}
var item_name_format = RegEx.create_from_string("\\((-?\\d+),\\s*(-?\\d+),\\s*(-?\\d+)\\)")


func _ready():
	# Build level
	for pos in Util.vector3i_range(Vector3i.ONE * size):
		var world_pos: Vector3 = _to_local_position(pos)
		var normal: Vector3 = _get_surface_normal(world_pos)
		var boundaries: int = Util.count_nonzero(normal.abs())
		var scene: PackedScene = inner_scene
		
		if _is_on_surface(pos):
			if boundaries == 2:
				scene = edge_scene
			elif boundaries == 3:
				scene = corner_scene
			else:
				scene = plane_scene
				var object_pos = pos + Vector3i(normal)
				match _get_face_value(normal, pos):
					1: set_grid_item_at(object_pos, obstacle_scene)
					var idx when idx in range(2, 5):
						var planet: Planet = set_grid_item_at(object_pos, planet_scene)
						planet.type = idx - 2
		
		var grid_item = set_grid_item_at(pos, scene)
		# TODO: add debug toggle
		#if grid_item:
			#grid_item.normal = normal
			#if _is_on_surface(pos):
				#DebugOverlay.draw_3d.add_vector(grid_item, "normal", 1, 2)


## Get the node in a grid position, null if none
func get_grid_item(pos: Vector3i) -> GridItem:
	return find_child(str(pos), false, false)


func get_neighbor_grid_item(item: GridItem, direction: Vector3i) -> GridItem:
	assert(Util.is_cardinal_direction(direction), "must be a cardinal direction")
	
	var position: Vector3i = _name_to_vec(item.name)
	var neighbor_pos = position + direction
	return get_grid_item(neighbor_pos)


## Sets a grid item to a given scene
## Returns the instantiated scene.
## If scene is null, the grid position is cleared, and no node is returned.
func set_grid_item_at(pos: Vector3i, scene: PackedScene) -> GridItem:
	var existing_item = get_grid_item(pos)
	if existing_item:
		remove_child(existing_item)
	
	var item_instance: GridItem
	if scene:
		var world_pos: Vector3 = _to_local_position(pos)
		var normal: Vector3 = _get_surface_normal(world_pos)
		
		item_instance = scene.instantiate()
		item_instance.position = world_pos
		item_instance.transform.basis = surface_lookup.rotation_for_normal(normal)
		item_instance.name = str(pos)
		item_instance.grid_world = self
		add_child(item_instance)
	
	return item_instance


func replace_grid_item(item: GridItem, scene: PackedScene) -> GridItem:
	return set_grid_item_at(_name_to_vec(item.name), scene)


## Remove a grid item by node reference
func remove_grid_item(item: GridItem) -> void:
	remove_child(item)


func rotation_for_pos(pos: Vector3i) -> Basis:
	var world_pos: Vector3 = _to_local_position(pos)
	var normal: Vector3 = _get_surface_normal(world_pos)
	return surface_lookup.rotation_for_normal(normal)


func _to_local_position(pos: Vector3i) -> Vector3:
	var offset: float = float(size-1 * box_size) / 2
	return Vector3(pos.x - offset, pos.y - offset, pos.z - offset) # TODO: simplify


func _name_to_vec(name: String) -> Vector3i:
	var result: RegExMatch = item_name_format.search(name)
	assert(result, "regex did not match")
	return Vector3i(int(result.get_string(1)), int(result.get_string(2)), int(result.get_string(3)))


func _count_position_boundaries(pos: Vector3i, size: Vector3i) -> int:
	# Check if exactly two components are at the boundary
	var at_boundary = [pos.x == 0 or pos.x == size.x - 1,
					   pos.y == 0 or pos.y == size.y - 1,
					   pos.z == 0 or pos.z == size.z - 1]
	return at_boundary.count(true)


func _get_surface_normal(world_pos: Vector3) -> Vector3:
	const epsilon: float = 0.001  # Small tolerance for floating point comparisons
	const center: Vector3 = Vector3.ZERO  # Center of the cube
	
	var vec: Vector3 = world_pos - center
	var abs_vec: Vector3 = vec.abs()
	var max_abs: float = abs_vec[abs_vec.max_axis_index()]
	var normal: Vector3 = Vector3()

	# Retain components that are approximately equal to the maximum
	# TODO: do we need this?
	if abs(abs_vec.x - max_abs) < epsilon:
		normal.x = vec.x
	if abs(abs_vec.y - max_abs) < epsilon:
		normal.y = vec.y
	if abs(abs_vec.z - max_abs) < epsilon:
		normal.z = vec.z

	normal = normal.normalized()
	return normal


func _is_on_surface(pos: Vector3i) -> bool:
	var max_index = size - 1
	return pos.x == 0 or pos.y == 0 or pos.z == 0 \
		or pos.x == max_index or pos.y == max_index or pos.z == max_index


# TODO: there's probably a better way to do this
func _get_face_value(normal: Vector3, pos: Vector3i) -> int:
	var x_index: int
	var y_index: int
	
	pos = pos - Vector3i.ONE
	
	if normal == Vector3.MODEL_REAR:
		x_index = pos.x
		y_index = pos.y
	elif normal == Vector3.MODEL_FRONT:
		x_index = size - 3 - pos.x
		y_index = pos.y
	elif normal == Vector3.MODEL_LEFT:
		x_index = size - 3 - pos.z
		y_index = pos.y
	elif normal == Vector3.MODEL_RIGHT:
		x_index = pos.z
		y_index = pos.y
	elif normal == Vector3.MODEL_TOP:
		x_index = pos.x
		y_index = pos.z
	elif normal == Vector3.MODEL_BOTTOM:
		x_index = pos.x
		y_index = size - 3 - pos.z

	return faces[normal][y_index][x_index]
