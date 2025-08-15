extends Area2D

@export var start_height: float = 300.0  # pixels above origin
@export var fall_speed: float = 50.0    # pixels per second

@export var sprite: Node2D

signal triggered
var wasUsed: bool = false

func _ready():
	sprite.position.y = -start_height
	self.position.x = 1920 / 2
	self.position.y = 1080 / 2
	

func _process(delta):
	# Move sprite down
	sprite.position.y += fall_speed * delta

	# Check if sprite has reached or passed origin
	if sprite.position.y >= 0:
		triggered.emit()
		GlobalSignalSingleton.endGame.emit()
		queue_free()  
