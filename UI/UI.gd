extends Control

#@onready var icon_draw: Sprite2D = $"Button Draw/IconDraw"
#@onready var icon_wormhole: Sprite2D = $"Button Wormhole/IconWormhole"
#@onready var icon_invert: Sprite2D = $"Button Invert/IconInvert"
#@onready var icon_reset: Sprite2D = $"Button Reset/IconReset"
const SPACE_MAT = preload("res://Space mat instance.tres")
const INVERT_PARAM = &"Invert"


func _on_button_draw_pressed() -> void:
	SignalBus.emit_signal(&"placeable_selected", Constants.Placeable.REDSTONE)


func _on_button_wormhole_pressed() -> void:
	SignalBus.emit_signal(&"placeable_selected", Constants.Placeable.WORMHOLE)

 
func _on_button_invert_pressed() -> void:
	var new_param_value = not SPACE_MAT.get_shader_parameter(INVERT_PARAM)
	SPACE_MAT.set_shader_parameter(INVERT_PARAM, new_param_value)


func _on_button_reset_pressed() -> void:
	SPACE_MAT.set_shader_parameter(INVERT_PARAM, false)
	DebugOverlay.draw_3d.vectors.clear()
	get_tree().reload_current_scene()
