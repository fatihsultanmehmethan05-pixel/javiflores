class_name HUD
extends CanvasLayer

## HUD controller for Signal Array 04

@onready var prompt_label: Label = $MarginContainer/PromptLabel
@onready var battery_bar: ProgressBar = $MarginContainer/VBoxContainerLeft/BatteryBar
@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainerLeft/HealthBar
@onready var status_label: Label = $MarginContainer/StatusLabel
@onready var stealth_label: Label = $MarginContainer/VBoxContainerLeft/StealthLabel
@onready var radio_label: Label = $MarginContainer/VBoxContainerLeft/RadioLabel
@onready var debug_label: Label = get_node_or_null("MarginContainer/DebugLabel")
@onready var crosshair: Control = $Crosshair

func update_multiplayer_debug(debug_text: String) -> void:
	if debug_label:
		debug_label.text = debug_text
@onready var overlay_panel: PanelContainer = $OverlayPanel
@onready var overlay_title: Label = $OverlayPanel/VBoxContainer/TitleLabel
@onready var overlay_sub: Label = $OverlayPanel/VBoxContainer/SubLabel

func _ready() -> void:
	if overlay_panel:
		overlay_panel.visible = false

func set_prompt(text: String) -> void:
	if prompt_label:
		prompt_label.text = text
		prompt_label.visible = text != ""

func update_battery(current: float, max_val: float) -> void:
	if battery_bar:
		battery_bar.max_value = max_val
		battery_bar.value = current

func update_health(current: float, max_val: float) -> void:
	if health_bar:
		health_bar.max_value = max_val
		health_bar.value = current

func update_stealth_status(is_hidden: bool) -> void:
	if stealth_label:
		if is_hidden:
			stealth_label.text = "STEALTH: HIDDEN [SAFE]"
			stealth_label.add_theme_color_override("font_color", Color("#00FF66")) # Green
		else:
			stealth_label.text = "STEALTH: EXPOSED [ANOMALY RISKS]"
			stealth_label.add_theme_color_override("font_color", Color("#FFB000")) # Amber

func update_radio_status(closest_antenna_dist: float, closest_threat_dist: float) -> void:
	if not radio_label:
		return

	if closest_threat_dist < 12.0:
		radio_label.text = "RADIO: !!! HEAVY STATIC NOISE (THREAT NEARBY) !!!"
		radio_label.add_theme_color_override("font_color", Color("#D92B2B")) # Red Warning
	elif closest_antenna_dist < 15.0:
		var signal_pct: int = clamp(int((1.0 - (closest_antenna_dist / 15.0)) * 100.0), 10, 100)
		radio_label.text = "RADIO SIGNAL: BEEPING [" + str(signal_pct) + "% FREQUENCY LOCK]"
		radio_label.add_theme_color_override("font_color", Color("#00FF66")) # Green Signal
	else:
		radio_label.text = "RADIO: LOW FREQUENCY HUM"
		radio_label.add_theme_color_override("font_color", Color("#AAAAAA")) # Dim Gray

func update_antenna_status(fixed_count: int, total_count: int) -> void:
	if status_label:
		status_label.text = "ANTENNA ARRAYS: " + str(fixed_count) + " / " + str(total_count) + " ONLINE"

func show_game_over() -> void:
	if overlay_panel:
		overlay_panel.visible = true
		if overlay_title:
			overlay_title.text = "SIGNAL LOST - GAME OVER"
			overlay_title.add_theme_color_override("font_color", Color("#D92B2B"))
		if overlay_sub:
			overlay_sub.text = "An anomaly consumed your team. Press [R] to Restart."

func show_victory() -> void:
	if overlay_panel:
		overlay_panel.visible = true
		if overlay_title:
			overlay_title.text = "SHIFT COMPLETE - EXTRACTION SUCCESSFUL!"
			overlay_title.add_theme_color_override("font_color", Color("#00FF66"))
		if overlay_sub:
			overlay_sub.text = "Signal locked & Observatory secured! Press [R] to Replay."
