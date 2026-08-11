class_name AntennaPanel
extends Interactable

## Server-authoritative fuse repair interaction.

@export var antenna_id: int = 1
@export var is_fixed: bool = false
@export var repair_duration: float = 1.5
@export var requires_fuse: bool = true

@onready var status_light: OmniLight3D = get_node_or_null("StatusLight")

var repair_progress: float = 0.0
var repairing_peer_id: int = 0

signal antenna_status_changed(antenna_id: int, is_fixed: bool)

func _ready() -> void:
	_update_prompt()
	call_deferred("_update_visuals")

func _process(delta: float) -> void:
	if not multiplayer.is_server() or is_fixed or repairing_peer_id == 0:
		return
	var player := _get_player(repairing_peer_id)
	if not _can_repair(player):
		_server_stop_repair(repairing_peer_id)
		return
	repair_progress += delta
	_update_prompt()
	if repair_progress >= repair_duration:
		if requires_fuse:
			player.set_fuse_state(false)
		apply_repair_complete.rpc()

func interact(player: Node3D) -> void:
	if is_fixed:
		return
	var peer_id := player.get_multiplayer_authority()
	if multiplayer.is_server():
		_server_begin_repair(peer_id)
	else:
		request_begin_repair.rpc_id(NetworkManager.SERVER_PEER_ID)

func stop_repair() -> void:
	if multiplayer.is_server():
		_server_stop_repair(multiplayer.get_unique_id())
	else:
		request_stop_repair.rpc_id(NetworkManager.SERVER_PEER_ID)

@rpc("any_peer", "call_remote", "reliable")
func request_begin_repair() -> void:
	if multiplayer.is_server():
		_server_begin_repair(multiplayer.get_remote_sender_id())

@rpc("any_peer", "call_remote", "reliable")
func request_stop_repair() -> void:
	if multiplayer.is_server():
		_server_stop_repair(multiplayer.get_remote_sender_id())

func _server_begin_repair(peer_id: int) -> void:
	var player := _get_player(peer_id)
	if _can_repair(player) and (repairing_peer_id == 0 or repairing_peer_id == peer_id):
		repairing_peer_id = peer_id

func _server_stop_repair(peer_id: int) -> void:
	if repairing_peer_id == peer_id:
		repairing_peer_id = 0

func _can_repair(player: Node3D) -> bool:
	if player == null or player.global_position.distance_to(global_position) > 4.5:
		return false
	if requires_fuse and not player.has_fuse:
		return false
	return player.current_state != Player.State.CROUCHING

@rpc("authority", "call_local", "reliable")
func apply_repair_complete() -> void:
	if is_fixed:
		return
	is_fixed = true
	repair_progress = repair_duration
	repairing_peer_id = 0
	_update_prompt()
	_update_visuals()
	antenna_status_changed.emit(antenna_id, true)

func apply_network_state(fixed: bool) -> void:
	is_fixed = fixed
	repair_progress = repair_duration if fixed else 0.0
	repairing_peer_id = 0
	_update_prompt()
	_update_visuals()

func _get_player(peer_id: int) -> Node3D:
	var main := get_tree().get_first_node_in_group("main_game")
	return main.get_node_or_null("PlayersContainer/" + str(peer_id)) if main != null else null

func _update_prompt() -> void:
	if is_fixed:
		prompt_message = "Antenna Array #%d [OPERATIONAL]" % antenna_id
	elif repair_progress > 0.0:
		prompt_message = "Installing Fuse & Repairing #%d [%d%%]" % [
			antenna_id,
			clampi(int(repair_progress / repair_duration * 100.0), 0, 100)
		]
	else:
		prompt_message = "Hold [E] to Repair Antenna Array #%d" % antenna_id

func _update_visuals() -> void:
	if status_light == null:
		return
	status_light.visible = is_fixed
	status_light.light_color = Color("#00FF66")
	status_light.light_energy = 2.5 if is_fixed else 0.0
