class_name FusePickup
extends Interactable

## Server-authoritative fuse pickup.

func _ready() -> void:
	prompt_message = "Take Electrical Fuse Kit [E]"

func _on_interact(player: Node3D) -> void:
	var peer_id := player.get_multiplayer_authority()
	if multiplayer.is_server():
		_server_pickup(peer_id)
	else:
		request_pickup.rpc_id(NetworkManager.SERVER_PEER_ID)

@rpc("any_peer", "call_remote", "reliable")
func request_pickup() -> void:
	if multiplayer.is_server():
		_server_pickup(multiplayer.get_remote_sender_id())

func _server_pickup(peer_id: int) -> void:
	var main := get_tree().get_first_node_in_group("main_game")
	var player := main.get_node_or_null("PlayersContainer/" + str(peer_id)) if main != null else null
	if player == null or player.global_position.distance_to(global_position) > 4.5 or player.has_fuse:
		return
	player.set_fuse_state(true)
	apply_picked_up.rpc()

@rpc("authority", "call_local", "reliable")
func apply_picked_up() -> void:
	is_enabled = false
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
