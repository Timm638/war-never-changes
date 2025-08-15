extends Area2D
var GetUnitsAround = preload("res://Scripts/Static/GetUnitsAround.gd")

@export var damage: float = 10.0
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var blocked:bool=false

signal triggered
var wasUsed: bool = false
@onready var damage_area: CollisionShape2D = $"Damage Area"

func _ready():
	pass

func _process(delta: float) -> void:
	self.position = get_global_mouse_position()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			apply_single_damage()
			await get_tree().create_timer(0.5).timeout
			queue_free()
	pass # Replace with function body.
		
func apply_single_damage():
	animation_player.play("ScytheSwing")
	var unit_list = GetUnitsAround.getUnitsAround(self)
	for obj in unit_list:
		if obj is Unit:
			obj.take_damage(damage, self)
			return
			
func _exit_tree() -> void:
	wasUsed = true
	GlobalSignalSingleton.skillUsed.emit()
	triggered.emit()
