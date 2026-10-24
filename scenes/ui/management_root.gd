extends Control

@export var mermaid_manger : Node
@onready var management_root: Control = $"."


func _on_restauration_button_pressed() -> void:
	management_root.visible = false
