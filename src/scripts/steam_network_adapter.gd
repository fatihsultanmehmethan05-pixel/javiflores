class_name SteamNetworkAdapter
extends RefCounted

## Optional GodotSteam MultiplayerPeer bridge.
## This parses without the extension; runtime methods fail clearly until installed.

const STEAM_PEER_CLASS := "SteamMultiplayerPeer"

static func is_available() -> bool:
	return ClassDB.class_exists(STEAM_PEER_CLASS) and ClassDB.can_instantiate(STEAM_PEER_CLASS)

static func create_host_peer(virtual_port: int = 0) -> Dictionary:
	var steam_peer := _new_peer()
	if steam_peer == null:
		return _missing_extension_result()
	var error: int = steam_peer.call("create_host", virtual_port)
	return {"error": error, "peer": steam_peer}

static func create_client_peer(host_steam_id: int, virtual_port: int = 0) -> Dictionary:
	if host_steam_id <= 0:
		return {"error": ERR_INVALID_PARAMETER, "peer": null}
	var steam_peer := _new_peer()
	if steam_peer == null:
		return _missing_extension_result()
	var error: int = steam_peer.call("create_client", host_steam_id, virtual_port)
	return {"error": error, "peer": steam_peer}

static func start_host(network_manager: NetworkManager, virtual_port: int = 0) -> Error:
	var result := create_host_peer(virtual_port)
	return result.error if result.error != OK else network_manager.start_host_with_peer(result.peer)

static func start_client(network_manager: NetworkManager, host_steam_id: int, virtual_port: int = 0) -> Error:
	var result := create_client_peer(host_steam_id, virtual_port)
	return result.error if result.error != OK else network_manager.start_client_with_peer(result.peer)

static func _new_peer() -> MultiplayerPeer:
	return ClassDB.instantiate(STEAM_PEER_CLASS) as MultiplayerPeer if is_available() else null

static func _missing_extension_result() -> Dictionary:
	push_error("SteamMultiplayerPeer is not installed. ENet remains available for local testing.")
	return {"error": ERR_UNAVAILABLE, "peer": null}
