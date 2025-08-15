# SpatialHash.gd (Godot 4.x)
extends Resource
class_name SpatialHash

@export var cell_size: float = 32.0

var buckets: = {} # Dictionary<int, PackedInt32Array>

static func _hash_key(cell_x: int, cell_y: int) -> int:
	return (cell_x << 16) ^ cell_y

func _cell_of(p: Vector2) -> Vector2i:
	return Vector2i(floor(p.x / cell_size), floor(p.y / cell_size))

func clear() -> void:
	buckets.clear()

func insert(index: int, p: Vector2) -> void:
	var c := _cell_of(p)
	var key := _hash_key(c.x, c.y)
	var arr: PackedInt32Array = buckets.get(key, PackedInt32Array())
	arr.push_back(index)
	buckets[key] = arr

func neighbors(p: Vector2) -> PackedInt32Array:
	var c := _cell_of(p)
	var result := PackedInt32Array()
	for dy in range(-1,2):
		for dx in range(-1,2):
			var key := _hash_key(c.x + dx, c.y + dy)
			if buckets.has(key):
				result.append_array(buckets[key])
	return result
