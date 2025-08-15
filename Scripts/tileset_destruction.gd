extends TileMapLayer

var tile_set_height : int = 3

func _ready() -> void:
	GlobalSignalSingleton.unitDied.connect(_destroy_tile_on)
	GlobalSignalSingleton.craterCreated.connect(_create_crater)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			var mouse_pos = self.get_local_mouse_position()
			#_degrade_tile_on(local_to_map(mouse_pos))
			
func _degrade_tile_on(cell: Vector2i):
	var new_atlas_coords = self.get_cell_atlas_coords(cell) + Vector2i(0, 1)
	if new_atlas_coords.y < tile_set_height:
		self.set_cell(cell, self.tile_set.get_source_id(0), new_atlas_coords)
		
func _create_crater(origin: Node2D, radius: float, scatter_grade: float):
	_degrades_tiles_to_around(local_to_map(origin.global_position), radius, scatter_grade)
	
func _destroy_tile_on(unit: Unit):
	_degrade_tile_on(local_to_map(unit.global_position))
	
func _degrades_tiles_to_around(origin_cell: Vector2i, radius: float, scatter_grade: float = 1.0):
	var list: Array[Vector2i] = [origin_cell]
	var radius_sq = radius * radius
	for x in range(floor(-radius), ceil(radius)):
		for y in range(floor(-radius), ceil(radius)):
			if x * x + y * y < radius_sq and randf() <= scatter_grade:
				list.append(origin_cell + Vector2i(x, y))
	for tile in list:
		_degrade_tile_on(tile)
	
	
