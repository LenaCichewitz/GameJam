extends Control

signal mermaid_pressed(id: int)

@onready var mermaid_id: Label = $VBoxContainer/MermaidID
@onready var mermaid_icon: TextureButton = $VBoxContainer/MermaidIcon

func _ready() -> void:
	mermaid_id.hide()

func _on_mermaid_icon_pressed() -> void:
	if mermaid_id.text.strip_edges().is_empty():
		return
	
	mermaid_pressed.emit(mermaid_id.text.to_int())
