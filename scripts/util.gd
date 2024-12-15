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
