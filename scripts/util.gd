extends Node
class_name Util
## Static utilities to use in scripts.
## This class is not autoloaded into the game.


## Given a Vector3i representing the size of a box,
## returns an array of all positions in that box.
static func vector3i_range(vec: Vector3i) -> Array[Vector3i]:
	var result: Array[Vector3i] = []
	for x in vec.x:
		for y in vec.y:
			for z in vec.z:
				result.append(Vector3i(x, y, z))
	return result


## Checks if a given vector is in any cardinal direction.
## Should work with any vector type.
static func is_cardinal_direction(vec) -> bool:
	return vec.sign().abs().length() == 1


## Returns the amount of non-zero components in the vector
static func count_nonzero(vec) -> int:
	vec = vec.sign().abs()
	return vec.x + vec.y + vec.z


## Returns a color value for a vector, useful for debugging
static func vector3_to_color(vector: Vector3) -> Color:
	var normalized_vector = vector.normalized()
	
	var r = (normalized_vector.x + 1.0) * 0.5
	var g = (normalized_vector.y + 1.0) * 0.5
	var b = (normalized_vector.z + 1.0) * 0.5
	
	return Color(r, g, b)


## Returns vectors perpendicular to the given normal, in 4 cardinal directions
static func get_cardinal_vectors(plane_normal: Vector3) -> Array:
	var tangent1 = Vector3.UP if abs(plane_normal.dot(Vector3.UP)) < 0.99 else Vector3.FORWARD
	var tangent2 = plane_normal.cross(tangent1).normalized()
	
	return [
		tangent1,
		-tangent1,
		tangent2,
		-tangent2
	]
