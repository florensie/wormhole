@tool
extends Node
class_name SceneSwitcher

var _current_index = 0


func _ready():
	if get_child_count() == 0:
		return
	
	for child: Node3D in get_children():
		child.visible = false
	
	var new_mesh: Node3D = get_child(_current_index)
	assert(new_mesh)
	new_mesh.visible = true


## Switch mesh to a new index, returns true is succesful
func update_type(index: int) -> bool:
	if index < 0 or index >= get_child_count():
		return false
	
	var previous_mesh: Node3D = get_child(_current_index)
	previous_mesh.visible = false
	
	var new_mesh: Node3D = get_child(index)
	assert(new_mesh)
	new_mesh.visible = true
	
	_current_index = index
	return true


func set_random():
	update_type(randi_range(0, get_child_count() - 1))
