extends Node2D

signal triggered

@export var prefabToSpawn : PackedScene
@export var count : int = 0
@export var positionVariance : float = 0.0

var wasUsed: bool = false

func _process(delta: float) -> void:
	self.position = get_global_mouse_position()


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			for c in range(count):
				var obj = prefabToSpawn.instantiate()
				obj.position = self.position
				if (positionVariance > 0.0):
					obj.position += Vector2.RIGHT.rotated(randf_range(0.0, TAU)) * randf() * positionVariance
				self.get_parent().add_child(obj)
			queue_free()
	pass # Replace with function body.

func _exit_tree() -> void:
	wasUsed = true
	GlobalSignalSingleton.skillUsed.emit()
	triggered.emit()
