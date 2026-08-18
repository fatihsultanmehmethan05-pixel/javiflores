class_name BatterySpawner
extends Node3D

## Server-authoritative random flashlight battery spawner.
## Pins BatteryPickup1 to the Fire Lookout Tower deck, and randomizes all other batteries across the forest.

@export var min_x: float = -55.0
@export var max_x: float = 37.0
@export var min_z: float = -112.0
@export var max_z: float = 8.0

var batteries: Array[BatteryPickup] = []
var shift_initialized: bool = false
var battery_positions: Dictionary = {}

func _ready() -> void:
	add_to_group("battery_spawners")
	for child in get_children():
		if child is BatteryPickup:
			batteries.append(child)
	
	if not multiplayer.has_multiplayer_peer():
		_randomize_positions_local()

func start_server_shift() -> void:
	if not multiplayer.is_server() or shift_initialized:
		return
	_randomize_positions_server()

func _randomize_positions_local() -> void:
	for battery in batteries:
		if battery.name == "BatteryPickup1":
			battery.global_position = Vector3(1.5, 10.2, 0.5)
		else:
			var rand_x: float = randf_range(min_x, max_x)
			var rand_z: float = randf_range(min_z, max_z)
			battery.global_position = Vector3(rand_x, 0.1, rand_z)

func _randomize_positions_server() -> void:
	battery_positions.clear()
	var new_positions: Dictionary = {}
	
	for battery in batteries:
		if battery.name == "BatteryPickup1":
			new_positions[battery.name] = Vector3(1.5, 10.2, 0.5)
		else:
			var rand_x: float = randf_range(min_x, max_x)
			var rand_z: float = randf_range(min_z, max_z)
			new_positions[battery.name] = Vector3(rand_x, 0.1, rand_z)

	apply_battery_positions.rpc(new_positions)

func send_snapshot_to(peer_id: int) -> void:
	if not multiplayer.is_server() or battery_positions.is_empty():
		return
	apply_battery_positions.rpc_id(peer_id, battery_positions)

@rpc("authority", "call_local", "reliable")
func apply_battery_positions(positions: Dictionary) -> void:
	battery_positions = positions
	for battery in batteries:
		if battery.name in positions:
			var pos: Vector3 = positions[battery.name]
			battery.global_position = pos
	shift_initialized = true
