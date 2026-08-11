class_name TowerConsoleButton
extends Interactable

## Server-authoritative sector floodlight button.

@export var sector_name: String = "NORTH"
@export var cooldown_duration: float = 10.0

var cooldown_timer: float = 0.0

func _ready() -> void:
	_update_prompt()

func _process(delta: float) -> void:
	if multiplayer.is_server() and cooldown_timer > 0.0:
		cooldown_timer = maxf(cooldown_timer - delta, 0.0)
		if cooldown_timer == 0.0:
			apply_cooldown.rpc(0.0)

func interact(player: Node3D) -> void:
	var peer_id := player.get_multiplayer_authority()
	if multiplayer.is_server():
		_server_trigger(peer_id)
	else:
		request_trigger.rpc_id(NetworkManager.SERVER_PEER_ID)

@rpc("any_peer", "call_remote", "reliable")
func request_trigger() -> void:
	if multiplayer.is_server():
		_server_trigger(multiplayer.get_remote_sender_id())

func _server_trigger(peer_id: int) -> void:
	var main := get_tree().get_first_node_in_group("main_game")
	var player := main.get_node_or_null("PlayersContainer/" + str(peer_id)) if main != null else null
	if player == null or player.global_position.distance_to(global_position) > 4.5:
		return
	if cooldown_timer > 0.0:
		return
	apply_cooldown.rpc(cooldown_duration)
	for floodlight in get_tree().get_nodes_in_group("floodlights"):
		if floodlight.sector_name == sector_name:
			floodlight.server_activate()

@rpc("authority", "call_local", "reliable")
func apply_cooldown(duration: float) -> void:
	cooldown_timer = maxf(duration, 0.0)
	_update_prompt()

func _update_prompt() -> void:
	if cooldown_timer > 0.0:
		prompt_message = "%s Floodlight Recharging... [%ds]" % [sector_name, ceili(cooldown_timer)]
	else:
		prompt_message = "Press [E] to Fire %s Sector Floodlight" % sector_name
