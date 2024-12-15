@tool
extends Control
class_name DebugDraw3D

const WIDTH = 5
const COLOR = Color(0, 1, 0)

var vectors: Array[DebugVector] = []

func _process(_delta):
	queue_redraw()


func _draw():
	if not is_visible_in_tree():
		return
	
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	for vector in vectors:
		vector.draw(self, camera)


func draw_triangle(pos, dir, size, color):
	var a = pos + dir * size
	var b = pos + dir.rotated(2*PI/3) * size
	var c = pos + dir.rotated(4*PI/3) * size
	var points = PackedVector2Array([a, b, c])
	self.draw_polygon(points, PackedColorArray([color]))


func add_vector(node: Node, property: StringName, scale: float, width: float):
	vectors.append(DebugVector.new(node, property, scale, width))


class DebugVector:
	var node: Node
	var property: StringName
	var scale: float
	var width: float

	func _init(_node: Node, _property: StringName, _scale: float, _width: float):
		node = _node
		property = _property
		scale = _scale
		width = _width

	func draw(debug_draw: DebugDraw3D, camera: Camera3D):
		var world_vector: Vector3 = node.get(property)
		var start_coord: Vector2 = camera.unproject_position(node.global_transform.origin)
		var end_coord: Vector2 = camera.unproject_position(node.global_transform.origin + world_vector * scale)
		var color = Util.vector3_to_color(world_vector)
		
		debug_draw.draw_line(start_coord, end_coord, color, width)
		debug_draw.draw_triangle(end_coord, start_coord.direction_to(end_coord), width*2, color)
