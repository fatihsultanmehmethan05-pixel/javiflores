class_name SignalDecoder
extends CanvasLayer

## Frequency Wavelength Decoder Mini-Game for Signal Array 04

@export var tolerance: float = 15.0 # Frequency match window in Hz

var target_frequency: float = 440.0
var current_frequency: float = 200.0
var match_progress: float = 0.0
var is_active: bool = false
var is_decoded: bool = false

@onready var panel: PanelContainer = get_node_or_null("PanelContainer")
@onready var freq_label: Label = get_node_or_null("PanelContainer/VBoxContainer/FreqLabel")
@onready var match_bar: ProgressBar = get_node_or_null("PanelContainer/VBoxContainer/MatchBar")
@onready var cassette_label: Label = get_node_or_null("PanelContainer/VBoxContainer/CassetteLabel")
@onready var hint_label: Label = get_node_or_null("PanelContainer/VBoxContainer/HintLabel")

signal signal_decoded(cassette_title: String)
signal decoder_closed()

func _ready() -> void:
	if panel:
		panel.visible = false
	_randomize_frequencies()

func _randomize_frequencies() -> void:
	target_frequency = randf_range(200.0, 800.0)
	var offset := randf_range(150.0, 350.0)
	if randf() > 0.5:
		current_frequency = clamp(target_frequency + offset, 100.0, 900.0)
	else:
		current_frequency = clamp(target_frequency - offset, 100.0, 900.0)
	match_progress = 0.0

func open_decoder() -> void:
	if is_decoded:
		return
	_randomize_frequencies()
	is_active = true
	if panel:
		panel.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_update_labels()

func close_decoder() -> void:
	is_active = false
	if panel:
		panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	emit_signal("decoder_closed")

func _unhandled_input(event: InputEvent) -> void:
	if is_active and event.is_action_pressed("ui_cancel"):
		close_decoder()

func _process(delta: float) -> void:
	if not is_active or is_decoded:
		return

	# Adjust frequency with A / D or Left / Right
	if Input.is_action_pressed("move_left"):
		current_frequency -= 140.0 * delta
	elif Input.is_action_pressed("move_right"):
		current_frequency += 140.0 * delta

	current_frequency = clamp(current_frequency, 100.0, 800.0)

	var freq_diff: float = abs(current_frequency - target_frequency)
	if freq_diff <= tolerance:
		match_progress += delta * 60.0
	else:
		match_progress = max(match_progress - delta * 30.0, 0.0)

	if match_bar:
		match_bar.value = match_progress

	_update_labels()

	if match_progress >= 100.0:
		_on_signal_matched()

func _update_labels() -> void:
	if freq_label:
		var freq_diff: float = abs(current_frequency - target_frequency)
		if freq_diff <= tolerance:
			freq_label.text = "FREQUENCY: " + str(int(current_frequency)) + " Hz [MATCHING WAVELENGTH...]"
			freq_label.add_theme_color_override("font_color", Color("#00FF66"))
		else:
			freq_label.text = "FREQUENCY: " + str(int(current_frequency)) + " Hz (Use [A] / [D] to Tune, [Esc] to Exit)"
			freq_label.add_theme_color_override("font_color", Color("#FFB000"))

func _on_signal_matched() -> void:
	is_decoded = true
	var titles = [
		"Signal #04: Deep Space Pulsar (Sector 7)",
		"Signal #09: Lost Operator Distress Transmission",
		"Signal #12: Atmospheric Resonance Anomaly",
		"Signal #18: Sub-Zero Horizon Pulse",
		"Signal #23: Quantum Resonance Cascade"
	]
	var captured_title: String = titles[randi() % titles.size()]
	
	if cassette_label:
		cassette_label.text = "DECODED: " + captured_title
		cassette_label.visible = true
	if hint_label:
		hint_label.text = "SIGNAL LOCKED TO ARCHIVE! Shift completed."
		hint_label.add_theme_color_override("font_color", Color("#00FF66"))

	emit_signal("signal_decoded", captured_title)
	print("SIGNAL CAPTURED TO ARCHIVE: ", captured_title)

	await get_tree().create_timer(2.5).timeout
	close_decoder()
