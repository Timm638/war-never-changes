extends Node2D

@onready var buttonContainer = $CanvasLayer/VBoxContainer/HBoxContainer/CenterSpace/HBoxContainer
const powerButtonPrefab = preload("res://Scenes/Prefabs/UI/power_button.tscn")
@export var soul_counter: RichTextLabel

@export var powerDict : Dictionary[String, Power]
var currentPowerObject : Node2D = null
var currentPower : Power = null

@export var souls : int = 500:
	set(value):
		souls = value
		_update_ui()

func _ready() -> void:
	_update_ui()
	GlobalSignalSingleton.unitDied.connect(onUnitDeath)
	for power in powerDict.values():
		var button = powerButtonPrefab.instantiate()
		#button.icon = power.icon
		(button as PowerButton).set_icon(power.icon)
		button.name = power.name
		button.connect("toggled", _on_hand_button_toggled.bind(power.name))
		button.get_child(0).text = str(power.cost)
		button.get_child(1).text = OS.get_keycode_string(power.hotkey.keycode)
		buttonContainer.add_child(button)
	pass
	
func addSoul(count: int = 1):
	souls += count

func onUnitDeath(_unit: Unit):
	addSoul(1);
	
func _process(delta: float) -> void:
	pass

func _on_hand_button_toggled(toggle_on: bool, powerStr: String) -> void:
	print("Toggled " + powerStr + " " + str(toggle_on))
	var power : Power = self.powerDict.get(powerStr)
	if power == null:
		printerr("Button with unassigned power '" + powerStr + "'")
		return
	_toggle_power(power, toggle_on)
	
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed == true:
			if currentPower and event.keycode == currentPower.hotkey.keycode:
				_toggle_power(currentPower, false)
			else:
				for key in powerDict:
					var pow = powerDict[key]
					if event.keycode != pow.hotkey.keycode:
						continue
					_toggle_power(pow, true)
			

func _toggle_power(newPower: Power, toggle_on: bool):
	# Delete the old power and refund costs
	if currentPowerObject != null and (not toggle_on  or newPower != currentPower or currentPowerObject.wasUsed):
		currentPowerObject.queue_free()
		if not currentPowerObject.wasUsed:
			souls += currentPower.cost
		currentPowerObject = null
		currentPower = null
		_update_buttons()
	# Create new power if possible
	if toggle_on and currentPowerObject == null and souls >= newPower.cost:
		currentPowerObject = newPower.prefab.instantiate()
		currentPowerObject.connect("triggered", _update_buttons)
		add_child.call_deferred(currentPowerObject)
		currentPower = newPower
		souls -= currentPower.cost
	_update_buttons()

func _update_ui():
	if soul_counter:
		soul_counter.text = str(souls)

func _update_buttons():
	for c in buttonContainer.get_children():
		if c is Button:
			c.set_block_signals(true)
			if currentPower and c.name == currentPower.name:
				c.button_pressed = (currentPowerObject != null and not currentPowerObject.wasUsed)
			else:
				c.button_pressed = false
			c.set_block_signals(false)
	if currentPowerObject and currentPowerObject.wasUsed and currentPower.continuous:
		_toggle_power(currentPower, true)
	
