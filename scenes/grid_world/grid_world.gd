extends Node
class_name GridWorld

@export var size: int = 5
@export var edge_scene: PackedScene
@export var corner_scene: PackedScene
@export var plane_scene: PackedScene
@export var box_size: int = 1

@onready var surface_lookup: SurfaceLookup = $SurfaceLookup

# 0 = nothing
# 1 = obstacle
# 2 = planet
# TODO: implement
const faces = [
	[
		[0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0],
	],
	[
		[0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0],
	],
	[
		[0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0],
	],
	[
		[0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0],
	],
]
var item_name_format = RegEx.create_from_string("\\((-?\\d+),\\s*(-?\\d+),\\s*(-?\\d+)\\)")


func _ready():
	# Fill
	for pos in Util.vector3i_range(Vector3i.ONE * size):
		var world_pos: Vector3 = _to_local_position(pos)
		var normal: Vector3 = _get_surface_normal(world_pos)
		var boundaries: int = Util.count_nonzero(normal.abs())
		var scene: PackedScene = plane_scene
		
		if boundaries == 2:
			scene = edge_scene
		elif boundaries == 3:
			scene = corner_scene
		
		var rotation: Basis = surface_lookup.rotation_for_normal(normal)
		var grid_item = set_grid_item_at(pos, scene, rotation)
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
func set_grid_item_at(pos: Vector3i, scene: PackedScene, rotation: Basis = Basis.IDENTITY) -> GridItem:
	var existing_item = get_grid_item(pos)
	if existing_item:
		remove_child(existing_item)
	
	var item_instance: GridItem
	if scene:
		item_instance = scene.instantiate()
		item_instance.position = _to_local_position(pos)
		item_instance.transform.basis = rotation
		item_instance.name = str(pos)
		item_instance.grid_world = self
		add_child(item_instance)
	
	return item_instance


func replace_grid_item(item: GridItem, scene: PackedScene) -> GridItem:
	return set_grid_item_at(_name_to_vec(item.name), scene)


## Remove a grid item by node reference
func remove_grid_item(item: GridItem) -> void:
	remove_child(item)


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


func _get_surface_normal(pos: Vector3) -> Vector3:
	var center = Vector3.ZERO  # Center of the cube
	var vec = pos - center
	var abs_vec = Vector3(abs(vec.x), abs(vec.y), abs(vec.z))
	var max_abs = max(abs_vec.x, abs_vec.y, abs_vec.z)
	var epsilon = 0.001  # Small tolerance for floating point comparisons
	var normal = Vector3()

	# Retain components that are approximately equal to the maximum
	if abs(abs_vec.x - max_abs) < epsilon:
		normal.x = vec.x
	else:
		normal.x = 0.0
	if abs(abs_vec.y - max_abs) < epsilon:
		normal.y = vec.y
	else:
		normal.y = 0.0
	if abs(abs_vec.z - max_abs) < epsilon:
		normal.z = vec.z
	else:
		normal.z = 0.0

	normal = normal.normalized()
	return normal


func _compute_rotation(normal: Vector3) -> Basis:
	if normal == Vector3.ZERO:
		return Basis.IDENTITY
	else:
		# Compute rotation that aligns the model's up vector (0, 1, 0) with the normal
		const MODEL_UP: Vector3 = Vector3.UP
		var rotation_axis = MODEL_UP.cross(normal)

		if rotation_axis.length_squared() == 0:
			# Vectors are parallel or opposite
			if MODEL_UP.dot(normal) > 0:
				# Same direction
				return Basis.IDENTITY
			else:
				# Opposite direction; rotate 180 degrees around any perpendicular axis
				rotation_axis = MODEL_UP.inverse().normalized()
				return Basis(rotation_axis, PI)
		else:
			var angle = acos(clamp(MODEL_UP.dot(normal), -1.0, 1.0))
			rotation_axis = rotation_axis.normalized()
			return Basis(rotation_axis, angle)


func _is_on_surface(pos: Vector3i) -> bool:
	var max_index = size - 1
	return pos.x == 0 or pos.y == 0 or pos.z == 0 \
		or pos.x == max_index or pos.y == max_index or pos.z == max_index
