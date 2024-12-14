extends Node3D

# TODO: these should probably all be @exports

const ZOOM_SPEED: float = 0.8
const ZOOM_MIN: float = 7
const ZOOM_MAX: float = 15

## The speed of dragging, higher is slower
const DRAG_SPEED: float = 200
## How much to speed up dragging at the max zoom level.
## The value in interpolated for anything in between min and max zoom
const DRAG_ZOOM_FACTOR: float = 3

var dragging: bool = false


func _unhandled_input(event: InputEvent):
	
	if event is InputEventMouseButton:
		var zoom_delta: float = 0
		
		# TODO: tween zooming
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.is_pressed():
			zoom_delta = ZOOM_SPEED
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.is_pressed():
			zoom_delta = -ZOOM_SPEED
		elif event.button_index == MOUSE_BUTTON_LEFT:
			get_viewport().set_input_as_handled()
			dragging = true if event.is_pressed() else false
			
		$Camera3D.position.z = clamp($Camera3D.position.z + zoom_delta, ZOOM_MIN, ZOOM_MAX)
		
	elif event is InputEventMouseMotion and dragging:
		var upside_down_multiplier: int = 1 if rotation_degrees.z == 180 else -1
		var zoom_factor: float = lerp(1.0, DRAG_ZOOM_FACTOR, inverse_lerp(ZOOM_MIN, ZOOM_MAX, $Camera3D.position.z))
		
		rotate_object_local(Vector3.RIGHT, -event.relative.y / DRAG_SPEED * zoom_factor)
		rotate(Vector3.UP, event.relative.x * upside_down_multiplier / DRAG_SPEED * zoom_factor)
