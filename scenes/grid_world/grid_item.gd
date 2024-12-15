extends Node3D
class_name GridItem

var grid_world: GridWorld
var normal: Vector3 # For debug purposes
var item_name_format = RegEx.create_from_string("\\((-?\\d+),\\s*(-?\\d+),\\s*(-?\\d+)\\)")


func get_grid_pos() -> Vector3i:
	var result: RegExMatch = item_name_format.search(name)
	assert(result, "regex did not match")
	return Vector3i(int(result.get_string(1)), int(result.get_string(2)), int(result.get_string(3)))
