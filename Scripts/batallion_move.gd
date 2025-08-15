class_name BatallionMove
extends Node2D

@export var separation_radius:float = 8.0
@export var separation_force:float = 200.0
@export var interval:float = 0.2
@export var acceleration:float = 5.0
@export var speed:float = 90.0

var batallion:Batallion
var trg:Vector2
var me:Unit
var t = 0
var interval_offset = randf()*interval
var active
var last_pos:Vector2
func _ready() -> void:
	me = get_parent() as Unit
	me.vel = Vector2.ZERO
	t = interval_offset
	last_pos = get_parent().position

func _physics_process(delta: float) -> void:

	t+=delta
	if t > interval:
		t = 0
		if me.state == Unit.State.MOVE:
			handle_move(delta)
			var d = get_parent().position - last_pos
			(get_parent() as Node2D).scale.x = sign(d.x)
			last_pos = get_parent().position

func handle_move(delta:float) -> void:
	trg = get_target()
	var local_avoidance:Vector2 = get_local_avoidance(batallion)
	var dir:Vector2 = get_move_dir(trg)
	var steer:Vector2 = get_steer(local_avoidance, dir)
	me.vel += steer * delta * acceleration
	var vlen :float= me.vel.length()
	if vlen > speed:
		me.vel = me.vel * (speed / vlen)
	me.position += me.vel * delta / interval

func get_target() -> Vector2:
	if me.batallion.target != null:
		return batallion.target.position
	return trg

func get_steer(local_avoidance:Vector2, direction:Vector2) -> Vector2:
	return (direction - me.vel + local_avoidance)

func get_move_dir(target:Vector2) -> Vector2:
	var dir = target - me.position
	dir = dir.normalized()
	
	return dir * speed

func get_local_avoidance(battalion:Batallion) -> Vector2:
	var count := 0
	var sep := Vector2.ZERO
	
	for ally:Node2D in battalion.units:
		if !ally:
			continue
		var d := ally.position - me.position
		var dist2 := d.length_squared()
		if dist2 <= 0.0001: continue
		var r = separation_radius
		if dist2 < (r * r * 4.0):
			sep -= d / max(8.0, dist2) # push away
			count += 1
	if count > 0:
		sep = sep.normalized() * separation_force
		
	return sep
