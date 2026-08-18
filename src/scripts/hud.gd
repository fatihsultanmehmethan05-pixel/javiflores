class_name HUD
extends CanvasLayer

## HUD controller for Signal Array 04

@onready var prompt_label: Label = $MarginContainer/PromptLabel
@onready var battery_bar: ProgressBar = $MarginContainer/VBoxContainerLeft/BatteryBar
@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainerLeft/HealthBar
@onready var status_label: Label = $MarginContainer/StatusLabel
@onready var stealth_label: Label = get_node_or_null("MarginContainer/VBoxContainerLeft/StealthLabel")
@onready var radio_label: Label = get_node_or_null("MarginContainer/VBoxContainerLeft/RadioLabel")
@onready var debug_label: Label = get_node_or_null("MarginContainer/DebugLabel")
@onready var crosshair: Control = $Crosshair

@onready var health_bar_label: Label = get_node_or_null("MarginContainer/VBoxContainerLeft/HealthBarLabel")
@onready var battery_bar_label: Label = get_node_or_null("MarginContainer/VBoxContainerLeft/BatteryLabel")
@onready var stamina_bar: ProgressBar = get_node_or_null("MarginContainer/VBoxContainerLeft/StaminaBar")
@onready var stamina_label: Label = get_node_or_null("MarginContainer/VBoxContainerLeft/StaminaLabel")

func update_multiplayer_debug(debug_text: String) -> void:
	if debug_label:
		debug_label.text = debug_text

@onready var overlay_panel: PanelContainer = $OverlayPanel
@onready var overlay_title: Label = $OverlayPanel/VBoxContainer/TitleLabel
@onready var overlay_sub: Label = $OverlayPanel/VBoxContainer/SubLabel

func _ready() -> void:
	if overlay_panel:
		overlay_panel.visible = false
	update_battery(100.0, 100.0)
	update_health(100.0, 100.0)
	update_stamina(100.0, 100.0, false)
	set_hud_visible(false)

func set_hud_visible(is_visible: bool) -> void:
	var margin = get_node_or_null("MarginContainer")
	if margin:
		margin.visible = is_visible
	if crosshair:
		crosshair.visible = is_visible

func update_stealth_status(_is_hidden: bool) -> void:
	pass

func update_radio_status(_closest_antenna_dist: float, _closest_threat_dist: float) -> void:
	pass

func update_stamina(current: float, max_val: float, is_exhausted: bool = false) -> void:
	if stamina_bar:
		stamina_bar.max_value = max_val
		stamina_bar.value = current
		var ratio: float = clamp(current / maxf(max_val, 1.0), 0.0, 1.0)
		var color := Color("#00E5FF")
		if is_exhausted:
			color = Color("#FF3333")
		else:
			var cyan := Color("#00E5FF")
			var yellow := Color("#FFD700")
			var orange := Color("#FF8C00")
			if ratio > 0.5:
				color = yellow.lerp(cyan, (ratio - 0.5) * 2.0)
			else:
				color = orange.lerp(yellow, ratio * 2.0)

		_apply_bar_color(stamina_bar, color)

		if stamina_label:
			if is_exhausted:
				stamina_label.text = "STAMINA [EXHAUSTED]"
				stamina_label.add_theme_color_override("font_color", Color("#FF3333"))
			else:
				stamina_label.text = "STAMINA"
				stamina_label.add_theme_color_override("font_color", color)

func set_prompt(text: String) -> void:
	if prompt_label:
		prompt_label.text = text
		prompt_label.visible = text != ""

func update_battery(current: float, max_val: float) -> void:
	if battery_bar:
		battery_bar.max_value = max_val
		battery_bar.value = current
		var ratio: float = clamp(current / maxf(max_val, 1.0), 0.0, 1.0)
		var color := _get_status_color(ratio)
		_apply_bar_color(battery_bar, color)
		if battery_bar_label:
			battery_bar_label.add_theme_color_override("font_color", color)

func update_health(current: float, max_val: float) -> void:
	if health_bar:
		health_bar.max_value = max_val
		health_bar.value = current
		var ratio: float = clamp(current / maxf(max_val, 1.0), 0.0, 1.0)
		var color := _get_status_color(ratio)
		_apply_bar_color(health_bar, color)
		if health_bar_label:
			health_bar_label.add_theme_color_override("font_color", color)

func _get_status_color(ratio: float) -> Color:
	var green := Color("#00FF66")
	var yellow := Color("#FFB000")
	var red := Color("#FF1A1A")
	
	if ratio > 0.5:
		var t := (ratio - 0.5) * 2.0
		return yellow.lerp(green, t)
	else:
		var t := ratio * 2.0
		return red.lerp(yellow, t)

func _apply_bar_color(bar: ProgressBar, color: Color) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.corner_radius_top_left = 2
	sb.corner_radius_top_right = 2
	sb.corner_radius_bottom_right = 2
	sb.corner_radius_bottom_left = 2
	bar.add_theme_stylebox_override("fill", sb)

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
