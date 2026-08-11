class_name SectorFloodlight
extends Node3D

## Server-authoritative replicated sector floodlight.

@export var sector_name: String = "NORTH"
@export var active_duration: float = 12.0

@onready var spotlight: SpotLight3D = get_node_or_null("SpotLight3D")
@onready var omni_light: OmniLight3D = get_node_or_null("OmniLight3D")

var is_active: bool = false
var _active_timer: float = 0.0

func _ready() -> void:
	add_to_group("floodlights")
	_set_lights_visible(false)

func server_activate() -> void:
	if multiplayer.is_server():
		apply_active.rpc(true, active_duration)

@rpc("authority", "call_local", "reliable")
func apply_active(state: bool, duration: float = 0.0) -> void:
	is_active = state
	_active_timer = maxf(duration, 0.0)
	_set_lights_visible(state)

func _process(delta: float) -> void:
	if not multiplayer.is_server() or not is_active:
		return
	_active_timer -= delta
	if _active_timer <= 0.0:
		apply_active.rpc(false, 0.0)

func _set_lights_visible(value: bool) -> void:
	if spotlight:
		spotlight.visible = value
		spotlight.light_energy = 45.0 if value else 0.0
	if omni_light:
		omni_light.visible = value
		omni_light.light_energy = 15.0 if value else 0.0
