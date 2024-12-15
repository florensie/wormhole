@tool
extends GridItem
class_name Planet

@onready var meshes: SceneSwitcher = $SceneSwitcher

@export var type: int = 0:
	get:
		return type
	set(value):
		if value != type and meshes.update_type(value):
			type = value
