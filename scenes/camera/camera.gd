extends Node3D

var dragging: bool = false


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		dragging = true if event.is_pressed() else false
		
	elif event is InputEventMouseMotion and dragging:
		rotate_object_local(Vector3.RIGHT, -event.relative.y / 100)
		var upside_down_multiplier = 1 if rotation_degrees.z == 180 else -1
		rotate(Vector3.UP, event.relative.x * upside_down_multiplier / 100)
