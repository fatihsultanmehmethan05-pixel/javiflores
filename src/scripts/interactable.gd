class_name Interactable
extends Node3D

## Base class for all interactable objects in Signal Array 04

@export var prompt_message: String = "Interact [E]"
@export var is_enabled: bool = true

signal interacted(player: Node3D)

func interact(player: Node3D) -> void:
	if not is_enabled:
		return
	emit_signal("interacted", player)
	_on_interact(player)

func _on_interact(_player: Node3D) -> void:
	# Virtual method to be overridden by child nodes (doors, switches, antennas)
	pass
