extends VBoxContainer

@onready var body: Panel = $body

@onready var quest_titel: Label = $Header/MarginContainer/HBoxContainer/QuestTitel
@onready var flavor_text: RichTextLabel = $body/MarginContainer/Body/FlavorText


func _ready() -> void:
	body.hide()

func setup() -> void:
	pass

func _on_header_pressed() -> void:
	body.visible = not body.visible
