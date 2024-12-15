extends Control

@onready var icon_draw: Sprite2D = $"Button Draw/IconDraw"
@onready var icon_wormhole: Sprite2D = $"Button Wormhole/IconWormhole"
@onready var icon_invert: Sprite2D = $"Button Invert/IconInvert"
@onready var icon_reset: Sprite2D = $"Button Reset/IconReset"
const spaceMat = preload("res://Space mat instance.tres")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_draw_pressed() -> void:
	pass # Replace with function body.


func _on_button_wormhole_pressed() -> void:
	pass # Replace with function body.

 
func _on_button_invert_pressed() -> void:
	#print(spaceMat.shader.get_mode())
	if spaceMat.get_shader_parameter("Invert") == false:
		spaceMat.set_shader_parameter("Invert", true)
	else: spaceMat.set_shader_parameter("Invert", false)
func _on_button_reset_pressed() -> void:
	spaceMat.set_shader_parameter("Invert", false)
	get_tree().reload_current_scene()
