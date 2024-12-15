@tool
extends GridItem

@onready var scene_switcher: SceneSwitcher = $SceneSwitcher

func _ready():
	scene_switcher.set_random()
