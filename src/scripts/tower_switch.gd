class_name TowerSwitch
extends Interactable

## Server-authoritative observatory power switch.

@onready var switch_light: OmniLight3D = get_node_or_null("SwitchLight")
var is_engaged: bool = false

signal main_switch_pulled()

func _ready() -> void:
	is_enabled = false
	prompt_message = "LOCKED - Repair all 3 Antenna Arrays first"
	call_deferred("_update_visuals")

func enable_switch() -> void:
	is_enabled = true
	prompt_message = "PULL MAIN POWER SWITCH [E] to Secure Signal"
	_update_visuals()

func _on_interact(player: Node3D) -> void:
	if not is_enabled or is_engaged:
		return
	var peer_id := player.get_multiplayer_authority()
	if multiplayer.is_server():
		_server_pull(peer_id)
	else:
		request_pull.rpc_id(NetworkManager.SERVER_PEER_ID)

@rpc("any_peer", "call_remote", "reliable")
func request_pull() -> void:
	if multiplayer.is_server():
		_server_pull(multiplayer.get_remote_sender_id())

func _server_pull(peer_id: int) -> void:
	var main := get_tree().get_first_node_in_group("main_game")
	var player := main.get_node_or_null("PlayersContainer/" + str(peer_id)) if main != null else null
	if player == null or player.global_position.distance_to(global_position) > 4.5:
		return
	if not is_enabled or is_engaged:
		return
	apply_switch_pulled.rpc()

@rpc("authority", "call_local", "reliable")
func apply_switch_pulled() -> void:
	if is_engaged:
		return
	is_engaged = true
	is_enabled = false
	prompt_message = "MAIN SWITCH ENGAGED - LOCKDOWN ACTIVE"
	_update_visuals()
	main_switch_pulled.emit()

func _update_visuals() -> void:
	if switch_light == null:
		return
	switch_light.light_color = Color("#00FF66") if is_enabled else Color("#D92B2B")
	switch_light.light_energy = 3.0 if is_enabled else 1.0
