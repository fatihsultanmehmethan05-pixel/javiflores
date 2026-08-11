class_name FuseSpawner
extends Node3D

## Server-authoritative random fuse pickup spawner.
## Spawns fuses at random (X, Z) coordinates within specified bounds, keeping original Y height intact.

@export var min_x: float = -55.0
@export var max_x: float = 37.0
@export var min_z: float = -112.0
@export var max_z: float = 8.0

var fuses: Array[FusePickup] = []
var shift_initialized: bool = false
var fuse_positions: Dictionary = {} # Mapping of fuse node name to Vector3 position

func _ready() -> void:
	add_to_group("fuse_spawners")
	for child in get_children():
		if child is FusePickup:
			fuses.append(child)
	
	# Standalone / single-player fallback (runs if no multiplayer peer is configured)
	if not multiplayer.has_multiplayer_peer():
		_randomize_positions_local()

func start_server_shift() -> void:
	if not multiplayer.is_server() or shift_initialized:
		return
	_randomize_positions_server()

func _randomize_positions_local() -> void:
	for fuse in fuses:
		if fuse.name == "FusePickup1":
			fuse.global_position = Vector3(0.0, 10.2, 1.5)
		else:
			var original_y: float = fuse.global_position.y
			var rand_x: float = randf_range(min_x, max_x)
			var rand_z: float = randf_range(min_z, max_z)
			fuse.global_position = Vector3(rand_x, original_y, rand_z)

func _randomize_positions_server() -> void:
	fuse_positions.clear()
	var new_positions: Dictionary = {}
	
	for fuse in fuses:
		if fuse.name == "FusePickup1":
			new_positions[fuse.name] = Vector3(0.0, 10.2, 1.5)
		else:
			var original_y: float = fuse.global_position.y
			var rand_x: float = randf_range(min_x, max_x)
			var rand_z: float = randf_range(min_z, max_z)
			var target_pos := Vector3(rand_x, original_y, rand_z)
			new_positions[fuse.name] = target_pos

	apply_fuse_positions.rpc(new_positions)

func send_snapshot_to(peer_id: int) -> void:
	if not multiplayer.is_server() or fuse_positions.is_empty():
		return
	apply_fuse_positions.rpc_id(peer_id, fuse_positions)

@rpc("authority", "call_local", "reliable")
func apply_fuse_positions(positions: Dictionary) -> void:
	fuse_positions = positions
	for fuse in fuses:
		if fuse.name in positions:
			var pos: Vector3 = positions[fuse.name]
			fuse.global_position = pos
	shift_initialized = true
