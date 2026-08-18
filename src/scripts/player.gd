class_name Player
extends CharacterBody3D

## FPS Player Controller for Signal Array 04 (Multiplayer Authority Ready)

@export_group("Movement Speeds")
@export var walk_speed: float = 3.5
@export var sprint_speed: float = 5.5
@export var crouch_speed: float = 1.8

@export_group("Physics & Sensitivity")
@export var accel: float = 10.0
@export var air_accel: float = 2.0
@export var friction: float = 12.0
@export var mouse_sensitivity: float = 0.002
@export var gravity: float = 9.8

@export_group("Inventory / Tools")
@export var has_fuse: bool = false

@export_group("Health System")
@export var max_health: float = 100.0
var current_health: float = 100.0

@export_group("Interaction")
@export var interact_distance: float = 3.5

# States
enum State { IDLE, WALKING, SPRINTING, CROUCHING }
var current_state: State = State.IDLE

# Node References
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var interact_raycast: RayCast3D = $Head/Camera3D/InteractRayCast
@onready var ceiling_raycast: RayCast3D = $CeilingRayCast
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var flashlight: Node3D = $Head/Camera3D/Flashlight
@onready var nametag_label: Label3D = get_node_or_null("NameTagLabel3D")
@onready var mesh_instance: MeshInstance3D = get_node_or_null("MeshInstance3D")

func set_player_display_name(p_name: String) -> void:
	if nametag_label:
		nametag_label.text = p_name

func set_player_identity(index: int) -> void:
	var colors = [
		Color("#00FF66"), # Host (Player 1): Green
		Color("#FF3333"), # 1st Joiner (Player 2): Red
		Color("#3399FF"), # 2nd Joiner (Player 3): Blue
		Color("#FFD700")  # 3rd Joiner (Player 4): Yellow
	]
	var display_name = "PLAYER " + str(index)
	var color_idx = clamp(index - 1, 0, colors.size() - 1)
	var player_c = colors[color_idx]
	
	if nametag_label:
		nametag_label.text = display_name
		nametag_label.modulate = player_c

	if mesh_instance:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = player_c
		mat.roughness = 0.4
		mesh_instance.material_override = mat

# Private Variables
var _camera_rotation: Vector2 = Vector2.ZERO
var _standing_height: float = 1.8
var _crouch_height: float = 1.1
var _standing_cam_y: float = 1.6
var _crouch_cam_y: float = 0.9
var _bob_time: float = 0.0
var _focused_interactable: Node3D = null
var _is_dead: bool = false
var _interaction_was_pressed: bool = false

signal focused_interactable_changed(interactable: Node3D)
signal health_changed(current_health: float, max_health: float)
signal player_died()

func is_local_player() -> bool:
	if not name.is_valid_int():
		return false
	var local_peer_id := multiplayer.get_unique_id()
	return name.to_int() == local_peer_id and get_multiplayer_authority() == local_peer_id

func can_process_local_input() -> bool:
	return is_local_player()

func _enter_tree() -> void:
	if name.is_valid_int():
		set_multiplayer_authority(name.to_int(), true)

func _ready() -> void:
	add_to_group("player")
	current_health = max_health
	_setup_fallback_inputs()
	if collision_shape and collision_shape.shape:
		collision_shape.shape = collision_shape.shape.duplicate()
	
	var is_local = is_local_player()
	set_physics_process(is_local)
	set_process_unhandled_input(is_local)
	if camera and is_local:
		camera.make_current()

	# Hide body capsule and eyes in First Person view for local player
	if mesh_instance and is_local:
		mesh_instance.visible = false

	if interact_raycast:
		interact_raycast.target_position = Vector3(0, 0, -interact_distance)

	_load_viewmodels()

@export_group("Left Hand - Anomaly Detector")
@export var detector_position: Vector3 = Vector3(-0.30, -0.20, -0.45)
@export var detector_rotation: Vector3 = Vector3(-45, 180, 0)
@export var detector_scale: Vector3 = Vector3(0.85, 0.85, 0.85)

@export_group("Right Hand - Flashlight")
@export var flashlight_position: Vector3 = Vector3(0.35, -0.16, -0.52)
@export var flashlight_model_rotation: Vector3 = Vector3(0, -90, 0)
@export var flashlight_model_scale: Vector3 = Vector3(0.85, 0.85, 0.85)

func _load_viewmodels() -> void:
	if not is_local_player():
		return

	var left_hand = get_node_or_null("Head/Camera3D/LeftHand")
	if left_hand:
		left_hand.position = detector_position

	var detector_mesh = load_obj_as_mesh("res://assets/models/signal_array_anomaly_detector.obj")
	if detector_mesh:
		var detector_node = get_node_or_null("Head/Camera3D/LeftHand/AnomalyDetector")
		if detector_node and detector_node is MeshInstance3D:
			detector_node.mesh = detector_mesh
			detector_node.rotation_degrees = detector_rotation
			detector_node.scale = detector_scale

	var right_hand = get_node_or_null("Head/Camera3D/RightHand")
	if right_hand:
		right_hand.position = flashlight_position

	var light_mesh = load_obj_as_mesh("res://assets/models/sa_light.obj")
	if light_mesh:
		var light_node = get_node_or_null("Head/Camera3D/RightHand/SALightMesh")
		if light_node and light_node is MeshInstance3D:
			light_node.mesh = light_mesh
			light_node.rotation_degrees = flashlight_model_rotation
			light_node.scale = flashlight_model_scale

@onready var detector_light: OmniLight3D = get_node_or_null("Head/Camera3D/LeftHand/DetectorLight")
var _detector_pulse_time: float = 0.0

func update_detector_light(closest_antenna_dist: float, closest_threat_dist: float, delta: float) -> void:
	if not detector_light:
		detector_light = get_node_or_null("Head/Camera3D/LeftHand/DetectorLight")
		if not detector_light:
			return

	_detector_pulse_time += delta

	# Priority 1: Monster Threat Nearby -> RED Warning
	if closest_threat_dist < 12.0:
		detector_light.light_color = Color("#FF1A1A")
		var pulse: float = (sin(_detector_pulse_time * 16.0) + 1.0) * 0.5
		detector_light.light_energy = lerpf(1.2, 5.0, pulse)

	# Priority 2: Damaged Antenna Nearby -> GREEN Proximity (shines brighter/fuller as player gets closer)
	elif closest_antenna_dist < 20.0:
		var ratio: float = clamp(1.0 - (closest_antenna_dist / 20.0), 0.0, 1.0)
		var pale_green := Color(0.02, 0.3, 0.1)
		var full_green := Color("#00FF66")
		detector_light.light_color = pale_green.lerp(full_green, ratio)
		detector_light.light_energy = lerpf(0.6, 4.2, ratio)

	# Priority 3: Normal / Default State -> BLUE Hum
	else:
		detector_light.light_color = Color("#00A2FF")
		detector_light.light_energy = 1.8

static func load_obj_as_mesh(obj_path: String) -> ArrayMesh:
	if not FileAccess.file_exists(obj_path):
		return null
	var file := FileAccess.open(obj_path, FileAccess.READ)
	if not file:
		return null
	
	var vertices: Array[Vector3] = []
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.begins_with("v "):
			var parts := line.split(" ", false)
			if parts.size() >= 4:
				vertices.append(Vector3(parts[1].to_float(), parts[2].to_float(), parts[3].to_float()))
		elif line.begins_with("f "):
			var parts := line.split(" ", false)
			if parts.size() >= 4:
				var face_indices: Array[int] = []
				for i in range(1, 4):
					var idx_str := parts[i].split("/")[0]
					var idx := idx_str.to_int() - 1
					if idx >= 0 and idx < vertices.size():
						face_indices.append(idx)
				if face_indices.size() == 3:
					# Front face
					st.add_vertex(vertices[face_indices[0]])
					st.add_vertex(vertices[face_indices[1]])
					st.add_vertex(vertices[face_indices[2]])
					# Back face for solid double-sided rendering
					st.add_vertex(vertices[face_indices[2]])
					st.add_vertex(vertices[face_indices[1]])
					st.add_vertex(vertices[face_indices[0]])
	
	st.generate_normals()
	return st.commit()

func _setup_fallback_inputs() -> void:
	var actions = {
		"move_forward": KEY_W,
		"move_backward": KEY_S,
		"move_left": KEY_A,
		"move_right": KEY_D,
		"sprint": KEY_SHIFT,
		"crouch": KEY_CTRL,
		"interact": KEY_E,
		"toggle_flashlight": KEY_F
	}
	for action_name in actions:
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
			var ev = InputEventKey.new()
			ev.physical_keycode = actions[action_name]
			InputMap.action_add_event(action_name, ev)

func take_damage(amount: float) -> void:
	if not multiplayer.is_server():
		return
	_apply_damage.rpc(amount)

@rpc("any_peer", "call_local", "reliable")
func _apply_damage(amount: float) -> void:
	var sender := multiplayer.get_remote_sender_id()
	if sender != 0 and sender != NetworkManager.SERVER_PEER_ID:
		return
	if _is_dead:
		return
	current_health = maxf(current_health - maxf(amount, 0.0), 0.0)
	health_changed.emit(current_health, max_health)
	if current_health <= 0.0:
		_is_dead = true
		player_died.emit()

func set_fuse_state(state: bool) -> void:
	if not multiplayer.is_server():
		return
	_apply_fuse_state.rpc(state)

@rpc("any_peer", "call_local", "reliable")
func _apply_fuse_state(state: bool) -> void:
	var sender := multiplayer.get_remote_sender_id()
	if sender != 0 and sender != NetworkManager.SERVER_PEER_ID:
		return
	has_fuse = state

func add_battery(amount: float = 50.0) -> void:
	if flashlight and flashlight.has_method("add_battery"):
		flashlight.call("add_battery", amount)

func _unhandled_input(event: InputEvent) -> void:
	if not can_process_local_input() or _is_dead:
		return

	# ESC key toggles mouse mode between CAPTURED and VISIBLE
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_viewport().set_input_as_handled()
		return

	# Left-Click anywhere on 3D game screen captures mouse back into FPS mode!
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_viewport().set_input_as_handled()
			return

	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	if event is InputEventMouseMotion:
		_camera_rotation.x -= event.relative.y * mouse_sensitivity
		_camera_rotation.y -= event.relative.x * mouse_sensitivity
		_camera_rotation.x = clamp(_camera_rotation.x, deg_to_rad(-85.0), deg_to_rad(85.0))
		
		if head:
			head.rotation.x = _camera_rotation.x
		rotation.y = _camera_rotation.y

	if event.is_action_pressed("toggle_flashlight") and flashlight and flashlight.has_method("toggle"):
		flashlight.call("toggle")

func _physics_process(delta: float) -> void:
	if not can_process_local_input():
		return

	if _is_dead or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		_apply_gravity(delta)
		velocity.x = lerp(velocity.x, 0.0, friction * delta)
		velocity.z = lerp(velocity.z, 0.0, friction * delta)
		move_and_slide()
		return

	_apply_gravity(delta)
	_handle_crouch(delta)
	_handle_movement(delta)
	_handle_head_bob(delta)
	_check_interaction()
	_handle_hold_interaction()
	move_and_slide()

func _handle_hold_interaction() -> void:
	var is_pressed := Input.is_action_pressed("interact")
	if is_pressed and not _interaction_was_pressed and _focused_interactable:
		if _focused_interactable.has_method("interact"):
			_focused_interactable.interact(self)
	elif not is_pressed and _interaction_was_pressed:
		if _focused_interactable and _focused_interactable.has_method("stop_repair"):
			_focused_interactable.stop_repair()
	_interaction_was_pressed = is_pressed

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

func _handle_crouch(delta: float) -> void:
	var wants_crouch: bool = Input.is_action_pressed("crouch")
	var is_ceiling_blocked: bool = ceiling_raycast.is_colliding() if ceiling_raycast else false

	var is_crouching: bool = wants_crouch or is_ceiling_blocked
	if is_crouching:
		current_state = State.CROUCHING
		_update_height(_crouch_height, _crouch_cam_y, delta)
	else:
		if current_state == State.CROUCHING:
			current_state = State.IDLE
		_update_height(_standing_height, _standing_cam_y, delta)

func _update_height(target_height: float, target_cam_y: float, delta: float) -> void:
	if collision_shape and collision_shape.shape is CapsuleShape3D:
		var capsule = collision_shape.shape as CapsuleShape3D
		capsule.height = lerp(capsule.height, target_height, 10.0 * delta)
	if head:
		head.position.y = lerp(head.position.y, target_cam_y, 10.0 * delta)

# Stamina System Variables
@export var max_stamina: float = 100.0
@export var stamina_drain_rate: float = 25.0
@export var stamina_regen_rate: float = 15.0
@export var stamina_regen_delay: float = 1.0

var current_stamina: float = 100.0
var _stamina_delay_timer: float = 0.0
var _is_exhausted: bool = false

func _handle_movement(delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var wants_sprint: bool = Input.is_action_pressed("sprint") and input_dir.y < 0 and current_state != State.CROUCHING and not _is_exhausted and current_stamina > 0.0

	var speed: float = walk_speed
	if current_state == State.CROUCHING:
		speed = crouch_speed
	else:
		if wants_sprint:
			speed = sprint_speed
			current_state = State.SPRINTING
			current_stamina = maxf(current_stamina - stamina_drain_rate * delta, 0.0)
			_stamina_delay_timer = stamina_regen_delay
			if current_stamina <= 0.0:
				_is_exhausted = true
		elif input_dir.length() > 0:
			current_state = State.WALKING
		else:
			current_state = State.IDLE

	# Stamina Recovery
	if not wants_sprint:
		_stamina_delay_timer = maxf(_stamina_delay_timer - delta, 0.0)
		if _stamina_delay_timer <= 0.0:
			current_stamina = minf(current_stamina + stamina_regen_rate * delta, max_stamina)
			if _is_exhausted and current_stamina >= 25.0:
				_is_exhausted = false

	var current_accel: float = accel if is_on_floor() else air_accel
	if direction != Vector3.ZERO:
		velocity.x = lerp(velocity.x, direction.x * speed, current_accel * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, current_accel * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction * delta)
		velocity.z = lerp(velocity.z, 0.0, friction * delta)

func _handle_head_bob(delta: float) -> void:
	if not camera or not is_on_floor() or velocity.length() < 0.5:
		_bob_time = 0.0
		if camera:
			camera.transform.origin.y = lerp(camera.transform.origin.y, 0.0, 10.0 * delta)
		return

	var bob_freq: float = 14.0 if current_state == State.SPRINTING else 10.0
	var bob_amp: float = 0.08 if current_state == State.SPRINTING else 0.04
	
	_bob_time += delta * velocity.length()
	var y_offset: float = sin(_bob_time * bob_freq * 0.5) * bob_amp
	camera.transform.origin.y = y_offset

func _check_interaction() -> void:
	if not interact_raycast:
		return

	var new_focused: Node3D = null
	if interact_raycast.is_colliding():
		var collider = interact_raycast.get_collider()
		if collider and collider.has_method("interact"):
			new_focused = collider
		elif collider and collider.get_parent() and collider.get_parent().has_method("interact"):
			new_focused = collider.get_parent() as Node3D

	if new_focused != _focused_interactable:
		if _focused_interactable and _focused_interactable.has_method("stop_repair"):
			_focused_interactable.call("stop_repair")
		_focused_interactable = new_focused
		emit_signal("focused_interactable_changed", _focused_interactable)
