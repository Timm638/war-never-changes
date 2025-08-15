class_name RangedAttackHitscan
extends Area2D


@export var attack_interval = 0.5
@export var damage = 10
@export var attack_range = 10.0

var t:float
var me:Unit
var firing_at:Unit
var rs

func _ready():
	t = randf() * attack_interval
	me = get_parent() as Unit
	collision_mask = me.controlled_by.enemy.unit_layer
	pass

func _physics_process(delta: float) -> void:
	if !(me.state == Unit.State.ATTACK || me.state == Unit.State.MOVE):
		return
	t += delta

	if t >= attack_interval:
		t = 0
		process_attack()


func process_attack() -> void:
	rs = attack_range*attack_range
	if firing_at:
		me.state = Unit.State.ATTACK
		firing_at.take_damage(damage,me)

	if !firing_at || firing_at.is_queued_for_deletion() || (firing_at.position - me.position).length_squared() > rs:
		firing_at = await acquire_target()
	
	if !firing_at && me.state == Unit.State.ATTACK:
		me.state = Unit.State.MOVE
	


func acquire_target() -> Unit:
	monitoring = true
	await get_tree().physics_frame
	var areas = get_overlapping_areas()
	for hit in areas:
		if hit.get_parent() is Unit:
			var other := hit.get_parent() as Unit
			if other.controlled_by != me.controlled_by:
				return other
	monitoring = false
	return null
