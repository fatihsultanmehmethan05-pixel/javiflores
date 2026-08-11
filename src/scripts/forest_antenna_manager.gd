class_name ForestAntennaManager
extends Node3D

## Server-authoritative procedural antenna state.

@export var damaged_antenna_count: int = 5

var all_antennae: Array[Node3D] = []
var active_damaged_antennae: Array[Node3D] = []
var repaired_count: int = 0
var shift_initialized: bool = false

signal antenna_repaired_count_changed(current: int, total: int)
signal all_damaged_repaired()

func _ready() -> void:
	for child in get_children():
		if child is AntennaPanel:
			all_antennae.append(child)
			child.antenna_status_changed.connect(_on_antenna_status_changed)

func start_server_shift() -> void:
	if not multiplayer.is_server() or shift_initialized:
		return
	var shuffled := all_antennae.duplicate()
	shuffled.shuffle()
	var damaged_names: Array[String] = []
	for index in range(mini(damaged_antenna_count, shuffled.size())):
		damaged_names.append(shuffled[index].name)
	apply_shift_state.rpc(damaged_names, [])

func get_state_snapshot() -> Dictionary:
	var damaged_names: Array[String] = []
	var repaired_names: Array[String] = []
	for antenna in active_damaged_antennae:
		damaged_names.append(antenna.name)
		if antenna.is_fixed:
			repaired_names.append(antenna.name)
	return {"damaged": damaged_names, "repaired": repaired_names}

func send_snapshot_to(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	var snapshot := get_state_snapshot()
	apply_shift_state.rpc_id(peer_id, snapshot.damaged, snapshot.repaired)

@rpc("authority", "call_local", "reliable")
func apply_shift_state(damaged_names: Array, repaired_names: Array) -> void:
	active_damaged_antennae.clear()
	repaired_count = 0
	for antenna in all_antennae:
		var was_damaged := antenna.name in damaged_names
		var repaired := antenna.name in repaired_names
		antenna.apply_network_state(not was_damaged or repaired)
		if was_damaged:
			active_damaged_antennae.append(antenna)
			if repaired:
				repaired_count += 1
	shift_initialized = true
	antenna_repaired_count_changed.emit(repaired_count, active_damaged_antennae.size())
	if not active_damaged_antennae.is_empty() and repaired_count >= active_damaged_antennae.size():
		all_damaged_repaired.emit()

func _on_antenna_status_changed(_antenna_id: int, is_fixed: bool) -> void:
	if not is_fixed:
		return
	repaired_count = 0
	for antenna in active_damaged_antennae:
		if antenna.is_fixed:
			repaired_count += 1
	antenna_repaired_count_changed.emit(repaired_count, active_damaged_antennae.size())
	if not active_damaged_antennae.is_empty() and repaired_count >= active_damaged_antennae.size():
		all_damaged_repaired.emit()
