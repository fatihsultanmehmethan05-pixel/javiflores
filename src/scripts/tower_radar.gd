class_name TowerRadar
extends Node3D

## CRT Observatory Radar Display Controller for Signal Array 04

@onready var status_display_label: Label3D = get_node_or_null("StatusDisplayLabel")
@onready var screen_light: OmniLight3D = get_node_or_null("ScreenLight")

var antenna_manager_ref: Node3D = null

func _ready() -> void:
	call_deferred("_initialize_radar")

func _initialize_radar() -> void:
	var managers = get_tree().get_nodes_in_group("antenna_managers")
	if managers.size() > 0:
		antenna_manager_ref = managers[0]
	else:
		antenna_manager_ref = get_node_or_null("../AntennaManager")

	_update_radar_display()

func _process(delta: float) -> void:
	# Periodic update for radar screen
	_update_radar_display()

func _update_radar_display() -> void:
	if not status_display_label:
		return

	var text_lines: Array[String] = []
	text_lines.append("=== OBSERVATORY RADAR STATUS ===")
	text_lines.append("SWEEP: ACTIVE [360 DEG]")
	text_lines.append("--------------------------------")

	var damaged_found: int = 0
	
	if antenna_manager_ref and "active_damaged_antennae" in antenna_manager_ref:
		var damaged_nodes = antenna_manager_ref.active_damaged_antennae
		for antenna in damaged_nodes:
			if "is_fixed" in antenna and not antenna.is_fixed:
				damaged_found += 1
				var ant_id = antenna.antenna_id if "antenna_id" in antenna else "?"
				var pos_vec: Vector3 = antenna.global_position
				var dir_str: String = _get_direction_string(pos_vec)
				text_lines.append("[!] ANTENNA #" + str(ant_id) + ": DAMAGED (" + dir_str + ")")

	if damaged_found == 0:
		text_lines.append("ALL ARRAYS OPERATIONAL!")
		text_lines.append("RETURN TO TOWER TO LOCK SIGNAL")

	status_display_label.text = "\n".join(text_lines)

	if screen_light:
		if damaged_found > 0:
			screen_light.light_color = Color("#FFB000") # CRT Amber Warning
			screen_light.light_energy = 1.5
		else:
			screen_light.light_color = Color("#00FF66") # Phosphor Green
			screen_light.light_energy = 2.5

func _get_direction_string(pos: Vector3) -> String:
	var dir_x = pos.x
	var dir_z = pos.z
	var cardinal = ""
	
	if dir_z < -5.0:
		cardinal += "NORTH"
	elif dir_z > 5.0:
		cardinal += "SOUTH"
		
	if dir_x > 5.0:
		cardinal += "-EAST"
	elif dir_x < -5.0:
		cardinal += "-WEST"
		
	return cardinal if cardinal != "" else "CENTER"
