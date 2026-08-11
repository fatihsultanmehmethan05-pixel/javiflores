class_name TowerConsole
extends Interactable

## Tower Operator Control Desk for Remote Sector Floodlights

@export var cooldown_duration: float = 10.0

var selected_sector_index: int = 0
var sectors: Array[String] = ["NORTH", "EAST", "SOUTH", "WEST"]
var cooldown_timer: float = 0.0

@onready var status_light: OmniLight3D = get_node_or_null("StatusLight")

func _ready() -> void:
	_update_prompt()

func _process(delta: float) -> void:
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
		_update_prompt()

func _update_prompt() -> void:
	if cooldown_timer > 0.0:
		prompt_message = "Floodlight Console Recharging... [" + str(int(cooldown_timer)) + "s]"
	else:
		var current_sec: String = sectors[selected_sector_index]
		prompt_message = "Press [E] to Fire " + current_sec + " Sector Floodlight"

func interact(_player: Node3D) -> void:
	if cooldown_timer > 0.0:
		return

	var target_sector: String = sectors[selected_sector_index]
	_trigger_sector_light(target_sector)
	
	# Rotate to next sector
	selected_sector_index = (selected_sector_index + 1) % sectors.size()
	cooldown_timer = cooldown_duration
	_update_prompt()

func _trigger_sector_light(target_sector: String) -> void:
	var floodlights = get_tree().get_nodes_in_group("floodlights")
	for fl in floodlights:
		if "sector_name" in fl and fl.sector_name == target_sector:
			if fl.has_method("activate_floodlight"):
				fl.call("activate_floodlight")
