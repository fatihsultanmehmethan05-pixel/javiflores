class_name MainGame
extends Node3D

## Main Game Loop Manager for Signal Array 04 Single-Player & Multiplayer Prototype

enum GameState { PLAYING, EXTRACTION_PHASE, DECODING_PHASE, GAME_OVER, VICTORY }
var current_game_state: GameState = GameState.PLAYING

@export var total_antennas: int = 5

@onready var hud: CanvasLayer = $HUD
@onready var tower_switch: Node3D = get_node_or_null("TowerSwitch")
@onready var tower_spotlight: SpotLight3D = get_node_or_null("TowerSpotlight")
@onready var antenna_manager: Node3D = get_node_or_null("AntennaManager")
@onready var fuse_spawner: Node3D = get_node_or_null("Pickups")
@onready var signal_decoder: CanvasLayer = get_node_or_null("SignalDecoder")
@onready var lobby_ui: CanvasLayer = get_node_or_null("LobbyUI")

var network_mgr: Node = null
var fixed_antennas_count: int = 0
var last_captured_cassette: String = ""

func _ready() -> void:
	add_to_group("main_game")
	current_game_state = GameState.PLAYING
	
	var net_script = load("res://src/scripts/network_manager.gd")
	if net_script:
		network_mgr = net_script.new()
		add_child(network_mgr)
		network_mgr.server_started.connect(_on_network_server_started)
		network_mgr.client_connected.connect(_on_network_client_connected)
		network_mgr.player_joined.connect(_on_network_player_joined)
		network_mgr.connection_failed.connect(_on_network_error)
		network_mgr.session_closed.connect(_on_network_error)

	if tower_spotlight:
		tower_spotlight.visible = false

	if lobby_ui:
		if lobby_ui.has_signal("host_requested"):
			lobby_ui.connect("host_requested", Callable(self, "_on_host_requested"))
		if lobby_ui.has_signal("join_requested"):
			lobby_ui.connect("join_requested", Callable(self, "_on_join_requested"))

	if tower_switch and tower_switch.has_signal("main_switch_pulled"):
		tower_switch.connect("main_switch_pulled", Callable(self, "_on_tower_switch_pulled"))

	if signal_decoder:
		if signal_decoder.has_signal("signal_decoded"):
			signal_decoder.connect("signal_decoded", Callable(self, "_on_signal_decoded"))
		if signal_decoder.has_signal("decoder_closed"):
			signal_decoder.connect("decoder_closed", Callable(self, "_on_decoder_closed"))

	if antenna_manager:
		if antenna_manager.has_signal("antenna_repaired_count_changed"):
			antenna_manager.connect("antenna_repaired_count_changed", Callable(self, "_on_antenna_repaired_count_changed"))
		if antenna_manager.has_signal("all_damaged_repaired"):
			antenna_manager.connect("all_damaged_repaired", Callable(self, "_start_extraction_phase"))

	if hud:
		if hud.has_method("update_antenna_status"):
			hud.call("update_antenna_status", fixed_antennas_count, total_antennas)
		if hud.has_method("set_prompt"):
			hud.call("set_prompt", "")

func get_local_player() -> Node3D:
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		if p.has_method("is_local_player"):
			if p.is_local_player():
				return p
		elif p.is_multiplayer_authority():
			return p
	return null

func _on_host_requested() -> void:
	if network_mgr and network_mgr.create_host() == OK and lobby_ui:
		lobby_ui.hide_lobby()

func _on_join_requested(address: String) -> void:
	if network_mgr:
		network_mgr.join_game(address)

func _on_network_server_started() -> void:
	if antenna_manager:
		antenna_manager.start_server_shift()
	if fuse_spawner and fuse_spawner.has_method("start_server_shift"):
		fuse_spawner.start_server_shift()

func _on_network_client_connected() -> void:
	if lobby_ui:
		lobby_ui.hide_lobby()

func _on_network_player_joined(peer_id: int) -> void:
	if multiplayer.is_server():
		if antenna_manager:
			antenna_manager.call_deferred("send_snapshot_to", peer_id)
		if fuse_spawner and fuse_spawner.has_method("send_snapshot_to"):
			fuse_spawner.call_deferred("send_snapshot_to", peer_id)

func _on_network_error(message: String) -> void:
	if lobby_ui:
		lobby_ui.show_lobby(message)

func _unhandled_input(event: InputEvent) -> void:
	if current_game_state == GameState.GAME_OVER or current_game_state == GameState.VICTORY:
		if event is InputEventKey and event.pressed and event.physical_keycode == KEY_R:
			get_tree().reload_current_scene()

func _process(_delta: float) -> void:
	_update_multiplayer_debug_overlay()
	var player = get_local_player()
	if (current_game_state == GameState.PLAYING or current_game_state == GameState.EXTRACTION_PHASE) and player and hud:
		var is_crouching: bool = false
		if "current_state" in player:
			is_crouching = (player.current_state == 3) # CROUCHING
		
		var is_flashlight_on: bool = false
		var flashlight = player.get_node_or_null("Head/Camera3D/Flashlight")
		if flashlight and "is_on" in flashlight:
			is_flashlight_on = flashlight.is_on
		
		var is_hidden: bool = is_crouching and not is_flashlight_on
		if hud.has_method("update_stealth_status"):
			hud.call("update_stealth_status", is_hidden)

		var focused = player.get("_focused_interactable")
		if focused and "prompt_message" in focused and "is_enabled" in focused and focused.is_enabled:
			if hud.has_method("set_prompt"):
				hud.call("set_prompt", focused.prompt_message)
		elif focused == null and hud.has_method("set_prompt"):
			hud.call("set_prompt", "")

		_process_radio_proximity()

func _update_multiplayer_debug_overlay() -> void:
	if not hud or not hud.has_method("update_multiplayer_debug"):
		return

	var lines: Array[String] = []
	var my_id: int = 1
	if multiplayer.has_multiplayer_peer() and multiplayer.multiplayer_peer and multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
		my_id = multiplayer.get_unique_id()
	lines.append("=== MULTIPLAYER DEBUG (Peer: " + str(my_id) + ") ===")
	
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		var p_name = p.name
		var p_auth = p.get_multiplayer_authority() if p.has_method("get_multiplayer_authority") else 1
		var is_local = p.is_local_player() if p.has_method("is_local_player") else false
		var pos = p.global_position
		var tag = p.nametag_label.text if ("nametag_label" in p and p.nametag_label) else p_name
		
		var line = "[%s] Node:%s Auth:%d Local:%s Pos:(%.1f,%.1f)" % [
			str(tag), str(p_name), p_auth, str(is_local).to_upper(), pos.x, pos.z
		]
		lines.append(line)
		

	hud.call("update_multiplayer_debug", "\n".join(lines))

func _process_radio_proximity() -> void:
	var player = get_local_player()
	if not player or not hud:
		return

	var player_pos: Vector3 = player.global_position
	
	# Find closest unfixed antenna distance
	var min_antenna_dist: float = 999.0
	for child in get_tree().get_nodes_in_group("antennas"):
		if "is_fixed" in child and not child.is_fixed:
			var d: float = player_pos.distance_to(child.global_position)
			if d < min_antenna_dist:
				min_antenna_dist = d

	# Find closest threat distance
	var min_threat_dist: float = 999.0
	for threat in get_tree().get_nodes_in_group("threats"):
		var d: float = player_pos.distance_to(threat.global_position)
		if d < min_threat_dist:
			min_threat_dist = d

	if hud.has_method("update_radio_status"):
		hud.call("update_radio_status", min_antenna_dist, min_threat_dist)

func _on_player_focused_interactable_changed(interactable: Node3D) -> void:
	if current_game_state == GameState.GAME_OVER or current_game_state == GameState.VICTORY:
		return
	if hud and hud.has_method("set_prompt"):
		if interactable and "prompt_message" in interactable and "is_enabled" in interactable and interactable.is_enabled:
			hud.call("set_prompt", interactable.prompt_message)
		else:
			hud.call("set_prompt", "")

func _on_flashlight_battery_changed(current: float, max_val: float) -> void:
	if hud and hud.has_method("update_battery"):
		hud.call("update_battery", current, max_val)

func _on_player_health_changed(current: float, max_val: float) -> void:
	if hud and hud.has_method("update_health"):
		hud.call("update_health", current, max_val)

func _on_player_died() -> void:
	current_game_state = GameState.GAME_OVER
	if hud and hud.has_method("show_game_over"):
		hud.call("show_game_over")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_antenna_repaired_count_changed(current: int, total: int) -> void:
	fixed_antennas_count = current
	total_antennas = total
	if hud and hud.has_method("update_antenna_status"):
		hud.call("update_antenna_status", fixed_antennas_count, total_antennas)

func _start_extraction_phase() -> void:
	current_game_state = GameState.EXTRACTION_PHASE
	print("ALL DAMAGED ANTENNAS REPAIRED! EXTRACTION PHASE STARTED!")
	
	if tower_spotlight:
		tower_spotlight.visible = true

	if tower_switch and tower_switch.has_method("enable_switch"):
		tower_switch.call("enable_switch")

	if hud and hud.has_method("set_prompt"):
		hud.call("set_prompt", "RETURN TO OBSERVATORY TOWER & PULL MAIN POWER SWITCH [E]!")

func _on_tower_switch_pulled() -> void:
	if signal_decoder and signal_decoder.has_method("open_decoder"):
		current_game_state = GameState.DECODING_PHASE
		signal_decoder.call("open_decoder")
	else:
		_complete_victory()

func _on_decoder_closed() -> void:
	if current_game_state == GameState.DECODING_PHASE and last_captured_cassette == "":
		current_game_state = GameState.EXTRACTION_PHASE
		if hud and hud.has_method("set_prompt"):
			hud.call("set_prompt", "PULL MAIN POWER SWITCH [E] to retry decoding")

func _on_signal_decoded(cassette_title: String) -> void:
	last_captured_cassette = cassette_title
	print("DECODED SIGNAL RECEIVED IN MAIN GAME: ", cassette_title)
	_complete_victory()

func _complete_victory() -> void:
	current_game_state = GameState.VICTORY
	if hud and hud.has_method("show_victory"):
		hud.call("show_victory")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
