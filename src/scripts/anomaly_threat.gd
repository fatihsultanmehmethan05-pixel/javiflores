class_name AnomalyThreat
extends Area3D

## Dynamic Patrol & Chase Anomaly Threat AI

@export var move_speed: float = 2.4
@export var detection_radius: float = 9.0
@export var damage_per_second: float = 65.0
@export var patrol_radius: float = 18.0

@onready var light_indicator: OmniLight3D = get_node_or_null("IndicatorLight")

var player_ref: Node3D = null
var start_position: Vector3 = Vector3.ZERO
var current_patrol_target: Vector3 = Vector3.ZERO
var patrol_wait_timer: float = 0.0

var is_chasing: bool = false
var is_suspicious: bool = false
var suspicion_timer: float = 0.0
var stationary_timer: float = 0.0

func _ready() -> void:
	start_position = global_position
	_pick_new_patrol_target()
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_ref = body

func _process(delta: float) -> void:
	if not multiplayer.is_server():
		_update_visuals()
		return
	if not is_instance_valid(player_ref) or not player_ref.is_inside_tree():
		player_ref = null
		_find_player()

	# Check if game is in Decoding or Victory Phase -> Safe Zone active!
	if _is_in_safe_phase():
		is_chasing = false
		is_suspicious = false
		_move_towards(start_position, delta * 0.5)
		_update_visuals()
		return

	var dist_to_player: float = 999.0
	var is_player_hidden: bool = true
	
	if is_instance_valid(player_ref) and player_ref.is_inside_tree():
		dist_to_player = global_position.distance_to(player_ref.global_position)
		is_player_hidden = _check_player_hidden()

	# AI Decision State Machine
	if dist_to_player <= detection_radius:
		if is_player_hidden:
			is_chasing = false
			is_suspicious = false
			suspicion_timer = 0.0
			stationary_timer = 0.0
			_handle_patrol(delta)
		else:
			stationary_timer = 0.0
			suspicion_timer += delta
			
			if suspicion_timer < 1.2:
				is_suspicious = true
				is_chasing = false
				_move_towards(player_ref.global_position, delta * 0.3)
			else:
				is_suspicious = false
				is_chasing = true
				_move_towards(player_ref.global_position, delta)
		
		# Deal damage on contact during chase ONLY when NOT hidden
		if dist_to_player <= 2.0 and is_chasing and not is_player_hidden:
			if player_ref.has_method("take_damage"):
				player_ref.call("take_damage", damage_per_second * delta)
	else:
		stationary_timer = 0.0
		suspicion_timer = 0.0
		is_chasing = false
		is_suspicious = false
		_handle_patrol(delta)

	_update_visuals()

func _is_in_safe_phase() -> bool:
	var main_nodes = get_tree().get_nodes_in_group("main_game")
	if main_nodes.size() > 0:
		var mg = main_nodes[0]
		if "current_game_state" in mg:
			# 2: DECODING_PHASE, 4: VICTORY
			return mg.current_game_state == 2 or mg.current_game_state == 4
	return false

func _handle_patrol(delta: float) -> void:
	if patrol_wait_timer > 0.0:
		patrol_wait_timer -= delta
		return

	var dist_to_target: float = global_position.distance_to(current_patrol_target)
	if dist_to_target <= 1.0:
		patrol_wait_timer = randf_range(1.5, 3.0)
		_pick_new_patrol_target()
	else:
		_move_towards(current_patrol_target, delta * 0.6)

func _pick_new_patrol_target() -> void:
	var random_offset = Vector3(
		randf_range(-patrol_radius, patrol_radius),
		0,
		randf_range(-patrol_radius, patrol_radius)
	)
	current_patrol_target = start_position + random_offset

func _find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	var closest_p: Node3D = null
	var min_d: float = 9999.0
	for p in players:
		if "current_health" in p and p.current_health <= 0:
			continue
		var d: float = global_position.distance_to(p.global_position)
		if d < min_d:
			min_d = d
			closest_p = p
	player_ref = closest_p

func _check_player_hidden() -> bool:
	if not player_ref:
		return true
	
	var is_crouching: bool = false
	if "current_state" in player_ref:
		is_crouching = (player_ref.current_state == 3) # CROUCHING State
	if not is_crouching and player_ref.has_method("is_local_player") and player_ref.is_local_player():
		is_crouching = Input.is_action_pressed("crouch")
		
	var is_flashlight_on: bool = false
	var flashlight = player_ref.get_node_or_null("Head/Camera3D/Flashlight")
	if flashlight and "is_on" in flashlight:
		is_flashlight_on = flashlight.is_on

	return is_crouching and not is_flashlight_on

func _move_towards(target_pos: Vector3, delta: float) -> void:
	var dir: Vector3 = (target_pos - global_position).normalized()
	dir.y = 0
	global_position += dir * move_speed * delta

func _update_visuals() -> void:
	var light = light_indicator if light_indicator else get_node_or_null("IndicatorLight")
	if light:
		if is_chasing:
			light.light_color = Color("#D92B2B") # Crimson Red (Chasing)
			light.light_energy = 3.5
		elif is_suspicious:
			light.light_color = Color("#FFB000") # CRT Amber (Suspicious Warning)
			light.light_energy = 2.0
		else:
			light.light_color = Color("#4A00E0") # Deep Purple (Active Patrol)
			light.light_energy = 1.2
