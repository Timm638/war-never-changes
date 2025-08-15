class_name TestMove
extends Node2D

var vel:Vector2
var t:float
var t2:float
var parent_trg:Node2D
var spd:float = 5
var interval = 0.2
func _ready() -> void:
	t=0
	t2=randf()*interval
	parent_trg = self.get_parent() as Node2D
	vel = Vector2(randf()-0.5, randf()-0.5)
	
func _physics_process(delta: float) -> void:
	t+=delta
	t2+=delta
	if t>0.5:
		vel = Vector2(randf()-0.5, randf()-0.5)
		vel = vel.normalized()*spd
		t=0
		
	if t2>interval:
		t2=0
		parent_trg.position += vel
