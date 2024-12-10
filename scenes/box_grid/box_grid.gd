@tool

extends Node

@export var size: int = 5:
	get:
		return size
	set(value):
		size = value
		_on_size_changed(value)
		
@export var box_scene: PackedScene
@export var box_size: int = 1


func _ready():
	_on_size_changed(size)


func _on_size_changed(size: int):
	for child in get_children():
		remove_child(child)
		
	if not box_scene:
		return
	
	for x in range(size):
		for y in range(size):
			for z in range(size):
				var box: Node3D = box_scene.instantiate()
				var offset: float = float(size-1 * box_size) / 2
				print(offset)
				box.position = Vector3(x - offset, y, z - offset)
				add_child(box)
