class_name NetworkManager
extends Node

## Transport-independent listen-server session manager for ENet and Steam peers.
## Gameplay depends only on MultiplayerPeer, never on a concrete transport.

const DEFAULT_PORT: int = 7777
const MAX_PLAYERS: int = 4
const SERVER_PEER_ID: int = 1
const PLAYER_SCENE: PackedScene = preload("res://src/scenes/player.tscn")

var peer: MultiplayerPeer = OfflineMultiplayerPeer.new()
var is_host: bool = false
var connected_players: Dictionary = {}

signal player_joined(peer_id: int)
signal player_left(peer_id: int)
signal server_started()
signal client_connected()
signal connection_failed(message: String)
signal session_closed(message: String)

func _ready() -> void:
	add_to_group("network_manager")
	var player_spawner := _get_player_spawner()
	if player_spawner:
		player_spawner.spawn_function = _spawn_player_from_data
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func create_host(port: int = DEFAULT_PORT) -> Error:
	var enet_peer := ENetMultiplayerPeer.new()
	# create_server counts remote clients; the host is already player one.
	var error := enet_peer.create_server(port, MAX_PLAYERS - 1)
	if error != OK:
		connection_failed.emit("Host could not listen on port %d (error %d)." % [port, error])
		return error
	return start_host_with_peer(enet_peer)

func create_steam_host(virtual_port: int = 0) -> Error:
	return SteamNetworkAdapter.start_host(self, virtual_port)

func join_steam_host(host_steam_id: int, virtual_port: int = 0) -> Error:
	return SteamNetworkAdapter.start_client(self, host_steam_id, virtual_port)

func join_game(address: String = "127.0.0.1", port: int = DEFAULT_PORT) -> Error:
	var enet_peer := ENetMultiplayerPeer.new()
	var error := enet_peer.create_client(address, port)
	if error != OK:
		connection_failed.emit("Could not connect to %s:%d (error %d)." % [address, port, error])
		return error
	return start_client_with_peer(enet_peer)

## Steam integration point: pass a configured GodotSteam MultiplayerPeer here.
func start_host_with_peer(multiplayer_peer: MultiplayerPeer) -> Error:
	if multiplayer_peer == null:
		return ERR_INVALID_PARAMETER
	leave_session(false)
	peer = multiplayer_peer
	multiplayer.multiplayer_peer = peer
	is_host = true
	connected_players = {SERVER_PEER_ID: {"name": "Host (Operator)", "id": SERVER_PEER_ID}}
	_spawn_player_character(SERVER_PEER_ID, Vector3(-1.2, 0.0, 1.0))
	server_started.emit()
	return OK

## Steam integration point: pass a connected GodotSteam MultiplayerPeer here.
func start_client_with_peer(multiplayer_peer: MultiplayerPeer) -> Error:
	if multiplayer_peer == null:
		return ERR_INVALID_PARAMETER
	leave_session(false)
	peer = multiplayer_peer
	multiplayer.multiplayer_peer = peer
	is_host = false
	connected_players.clear()
	return OK

func leave_session(emit_closed: bool = true) -> void:
	_clear_players()
	connected_players.clear()
	is_host = false
	peer = OfflineMultiplayerPeer.new()
	multiplayer.multiplayer_peer = peer
	if emit_closed:
		session_closed.emit("Session closed.")

func _on_peer_connected(id: int) -> void:
	if id <= SERVER_PEER_ID:
		return
	connected_players[id] = {"name": "Player " + str(id), "id": id}
	if multiplayer.is_server():
		var player_index := connected_players.size()
		var spawn_pos := Vector3(-1.2 + 0.8 * float(player_index - 1), 0.0, 1.0)
		_spawn_player_character(id, spawn_pos)
	player_joined.emit(id)

func _spawn_player_character(peer_id: int, spawn_pos: Vector3) -> void:
	if not multiplayer.is_server():
		return
	var container := _get_players_container()
	var player_spawner := _get_player_spawner()
	if container == null or player_spawner == null or container.has_node(str(peer_id)):
		return
	player_spawner.spawn({
		"peer_id": peer_id,
		"position": spawn_pos,
		"identity_index": connected_players.size()
	})

func _spawn_player_from_data(data: Variant) -> Node:
	if not data is Dictionary:
		return null
	var peer_id := int(data.get("peer_id", 0))
	if peer_id <= 0:
		return null
	var player_instance := PLAYER_SCENE.instantiate()
	player_instance.name = str(peer_id)
	player_instance.position = data.get("position", Vector3.ZERO)
	player_instance.set_multiplayer_authority(peer_id, true)
	if player_instance.has_method("set_player_identity"):
		player_instance.set_player_identity(int(data.get("identity_index", 1)))
	return player_instance

func _on_peer_disconnected(id: int) -> void:
	connected_players.erase(id)
	if multiplayer.is_server():
		var container := _get_players_container()
		if container != null and container.has_node(str(id)):
			container.get_node(str(id)).queue_free()
	player_left.emit(id)

func _on_connected_to_server() -> void:
	client_connected.emit()

func _on_connection_failed() -> void:
	leave_session(false)
	connection_failed.emit("Connection to host failed.")

func _on_server_disconnected() -> void:
	leave_session(false)
	session_closed.emit("Host disconnected.")

func _get_player_spawner() -> MultiplayerSpawner:
	var main_node := get_tree().get_first_node_in_group("main_game")
	return main_node.get_node_or_null("MultiplayerSpawner") as MultiplayerSpawner if main_node != null else null

func _get_players_container() -> Node:
	var main_node := get_tree().get_first_node_in_group("main_game")
	return main_node.get_node_or_null("PlayersContainer") if main_node != null else null

func _clear_players() -> void:
	var container := _get_players_container()
	if container == null:
		return
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
