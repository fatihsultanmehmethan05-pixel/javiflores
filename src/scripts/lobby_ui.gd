class_name LobbyUI
extends CanvasLayer

## Multiplayer Host / Join Lobby Overlay UI

@onready var panel: PanelContainer = get_node_or_null("PanelContainer")
@onready var host_button: Button = get_node_or_null("PanelContainer/VBoxContainer/HostButton")
@onready var join_button: Button = get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/JoinButton")
@onready var address_input: LineEdit = get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/AddressInput")
@onready var status_label: Label = get_node_or_null("PanelContainer/VBoxContainer/StatusLabel")

signal host_requested()
signal join_requested(address: String)

func _ready() -> void:
	layer = 10 # High render priority
	call_deferred("_setup_ui")

func _setup_ui() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if host_button:
		if not host_button.pressed.is_connected(_on_host_pressed):
			host_button.pressed.connect(_on_host_pressed)
			
	if join_button:
		if not join_button.pressed.is_connected(_on_join_pressed):
			join_button.pressed.connect(_on_join_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if panel and panel.visible:
		# Ensure mouse cursor stays visible while LobbyUI panel is active
		if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_host_pressed() -> void:
	print("Lobby UI: Host Shift Button Clicked!")
	if status_label:
		status_label.text = "Creating Host Server (Tower Operator)..."
		status_label.add_theme_color_override("font_color", Color("#00FF66"))
	emit_signal("host_requested")

func _on_join_pressed() -> void:
	var addr: String = "127.0.0.1"
	if address_input and address_input.text.strip_edges() != "":
		addr = address_input.text.strip_edges()
		
	print("Lobby UI: Join Shift Button Clicked for Address: ", addr)
	if status_label:
		status_label.text = "Connecting to " + addr + "..."
		status_label.add_theme_color_override("font_color", Color("#FFB000"))
	emit_signal("join_requested", addr)

func hide_lobby() -> void:
	if panel:
		panel.visible = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func show_lobby(message: String = "") -> void:
	visible = true
	if panel:
		panel.visible = true
	if status_label and not message.is_empty():
		status_label.text = message
		status_label.add_theme_color_override("font_color", Color("#D92B2B"))
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
