extends Control

signal mermaid_pressed

@onready var mermaid_id: Label = $VBoxContainer/MermaidID

func _ready() -> void:
	mermaid_id.hide()

func _on_mermaid_icon_pressed() -> void:
	mermaid_pressed.emit(mermaid_id.text)
