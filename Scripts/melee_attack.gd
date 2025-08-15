class_name MeleeAttack
extends Area2D

@export var attack_interval = 0.5
@export var damage = 10


var me:Unit
var t:float

func _ready() -> void:
	t = 0
	me = get_parent() as Unit
	collision_mask = me.controlled_by.enemy.unit_layer

func _physics_process(delta: float) -> void:
	if !(me.state == Unit.State.MOVE || me.state == Unit.State.ATTACK):
		return
	t += delta
	
	if t > attack_interval:
		t = 0
		try_do_attack()
		

func try_do_attack() -> void:
	self.monitoring = true
	await get_tree().physics_frame
	var hits := self.get_overlapping_areas()
	var any_enemy = false
	for hit in hits:
		if hit.get_parent() is Unit:
			var other := hit.get_parent() as Unit
			if other.controlled_by != me.controlled_by:
				me.base_animations.play("attack_melee")
				me.state = Unit.State.ATTACK
				any_enemy = true
				other.take_damage(damage, me)
				
		if hit.get_parent() is Castle:
			var other := hit.get_parent() as Castle
			if other.controlled_by != me.controlled_by:
				me.state = Unit.State.ATTACK
				any_enemy = true
				other.take_damage(damage, me)
				me.queue_free()
				break
	if !any_enemy && me.state == Unit.State.ATTACK:
		me.state = Unit.State.MOVE
	await get_tree().physics_frame
	self.monitoring = false
	
