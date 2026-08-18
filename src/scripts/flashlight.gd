class_name Flashlight
extends SpotLight3D

## Owner-controlled flashlight; only its player authority may publish state.

@export var max_battery: float = 100.0
@export var drain_rate: float = 0.8
@export var low_battery_threshold: float = 20.0

var current_battery: float = 100.0
var is_on: bool = true:
	set(value):
		is_on = value
		visible = is_on

signal battery_changed(current: float, max_value: float)

func _ready() -> void:
	current_battery = max_battery
	visible = is_on

func toggle() -> void:
	if not is_multiplayer_authority() or current_battery <= 0.0:
		return
	apply_flashlight_state.rpc(not is_on)

@rpc("authority", "call_local", "reliable")
func apply_flashlight_state(state: bool) -> void:
	is_on = state and current_battery > 0.0

func _process(delta: float) -> void:
	if not is_multiplayer_authority() or not is_on:
		return
	current_battery = maxf(current_battery - drain_rate * delta, 0.0)
	battery_changed.emit(current_battery, max_battery)
	if current_battery <= 0.0:
		apply_flashlight_state.rpc(false)
	elif current_battery <= low_battery_threshold:
		light_energy = randf_range(0.8, 2.5)
	else:
		light_energy = 2.5
