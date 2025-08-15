extends Area2D
var GetUnitsAround = preload("res://Scripts/Static/GetUnitsAround.gd")

@export var dragging : bool = false
@export var dragged_objects = []

signal triggered
var wasUsed: bool = false

func _process(delta: float) -> void:
	var prev_position = self.position
	self.position = get_global_mouse_position()
	if dragging:
		var delta_position = (self.position - prev_position)
		for obj in dragged_objects:
			if obj != null:
				obj.global_position += delta_position


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			dragged_objects = GetUnitsAround.getUnitsAround(self)
			# To do if start being grabbed
			for unit in dragged_objects:
				unit.state = Unit.State.GRABBED
		dragging = event.pressed
		if not event.pressed:
			# To do on not being dragged anymore
			for c in dragged_objects:
				if c:
					c.state = Unit.State.ATTACK
			queue_free()
	pass # Replace with function body.

func _exit_tree() -> void:
	wasUsed = true
	GlobalSignalSingleton.skillUsed.emit()
	triggered.emit()
