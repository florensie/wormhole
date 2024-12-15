extends GridItem
class_name InnerSpace
## Blocks that build up the inside of the level.

@export var wormhole_scene: PackedScene


## Try to replace self with wormhole, returns true if the wormhole position is valid and was created
func create_worm_hole(direction: Vector3i, is_initial: bool = false, rotato = null) -> bool:
	var is_valid = true
	var neighbor: GridItem = grid_world.get_neighbor_grid_item(self, direction)
	if rotato == null:
		# Wormhole entry
		rotato = self.basis
	
	# Recurse until no more neighbors are found
	if neighbor:
		is_valid = neighbor.create_worm_hole(direction, false, rotato) if neighbor is InnerSpace else false
	else:
		# Wormhole exit
		rotato = self.basis
	
	if is_valid:
		var wormhole_instance = grid_world.replace_grid_item(self, wormhole_scene)
		wormhole_instance.transform.basis = rotato
	
	return is_valid
