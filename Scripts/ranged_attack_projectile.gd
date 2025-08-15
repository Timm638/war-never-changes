class_name RangedAttackProjectile
extends Area2D


@export var attack_interval = 0.5
@export var projectile_prefab: PackedScene
@export var attack_range = 10.0

var t:float
var me:Unit
var firing_at:Node2D
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

	if needs_new_target():
		firing_at = await acquire_target()
	if firing_at:
		me.state = Unit.State.ATTACK
		var projectile = projectile_prefab.instantiate()
		projectile.source = get_parent()
		projectile.target = firing_at
		get_parent().add_child(projectile)
	if !firing_at && me.state == Unit.State.ATTACK:
		me.state = Unit.State.MOVE
	

func needs_new_target() -> bool:
	if !firing_at:
		return true
	
	var outp:bool = firing_at.is_queued_for_deletion()
	if firing_at is Unit:
		outp = outp || (firing_at as Unit).state == Unit.State.DYING 
	outp = outp || (firing_at.position - me.position).length_squared() > rs
	return outp

func acquire_target() -> Node2D:
	monitoring = true
	await get_tree().physics_frame
	var areas = get_overlapping_areas()
	for hit in areas:
		if hit.get_parent() is Unit || hit.get_parent() is Castle:
			var other := hit.get_parent() as Node2D
			if other.controlled_by != me.controlled_by:
				return other
			
	monitoring = false
	return null
