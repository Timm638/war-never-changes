extends CanvasLayer

func _ready() -> void:
	for c in get_tree().get_nodes_in_group("Pause on Start"):
		if c is Actor:
			c.paused = true
		elif c is CanvasLayer:
			c.visible = false
		
func begin_game() -> void:
	self.visible = false
	GlobalSignalSingleton.startGame.emit()
	for c in get_tree().get_nodes_in_group("Pause on Start"):
		if c is Actor:
			c.paused = false
		elif c is CanvasLayer:
			c.visible = true
