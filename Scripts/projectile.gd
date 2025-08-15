extends Node2D
class_name Projectile

var source: Node2D
var last_source_pos: Vector2
var target: Node2D
var last_target_pos: Vector2
var initial_distance: float
var initial_direction: Vector2

# In seconds
@export var travel_duration: float = 1.0
@export var travel_arc: Curve
@export var cutoff_distance: float = 100.0
# In seconds
@export var interval:float = 0.2
var t = 0

var travel_perc: float = 0.0

func _ready() -> void:
	initial_distance = source.position.distance_to(target.position)
	initial_direction = source.position - target.position

func _physics_process(delta: float) -> void:
	t += delta
	if t <= interval:
		return
	delta = t
	var prev_position = self.global_position
	if source:
		last_source_pos = source.position
	if target:
		last_target_pos = target.position
	if cutoff_distance * cutoff_distance < last_source_pos.distance_squared_to(last_target_pos):
		queue_free()
		return
	travel_perc = min(travel_perc + delta / travel_duration, 1.0)
	self.global_position = last_source_pos.lerp(last_target_pos, travel_perc)
	self.global_position.y -= travel_arc.sample(travel_perc) * initial_distance
	self.rotation = (self.global_position - prev_position).angle()
	if (travel_perc >= 1.0):
		target_reached()
	t = 0

func target_reached() -> void:
	queue_free()
	
