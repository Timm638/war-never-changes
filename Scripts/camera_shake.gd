extends Camera2D

@export var max_shake : float = 5.0
@export var cur_shake : float = 0.0
@export var shake_decay : float = 5.0

var source_position : Vector2

func _ready() -> void:
	GlobalSignalSingleton.craterCreated.connect(_shake_camera)
	
func _process(delta: float) -> void:
	if (cur_shake > 0):
		self.position = source_position + Vector2.RIGHT.rotated(randf_range(0.0, TAU)) * randf() * cur_shake
		cur_shake -= shake_decay * delta
		cur_shake = clampf(cur_shake,0, max_shake)
	
func _shake_camera(_source: Node2D, _radius, _scatter):
	if _source.is_in_group("No Shake"):
		return
	if (cur_shake == 0):
		source_position = self.position
	cur_shake += 2.0
