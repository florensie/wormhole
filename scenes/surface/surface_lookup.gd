extends Node3D
class_name SurfaceLookup


func rotation_for_normal(normal: Vector3) -> Basis:
	var reference: Node3D = find_child(str(normal.round()), false, false)
	return reference.basis if reference else Basis.IDENTITY
