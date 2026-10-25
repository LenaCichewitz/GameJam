extends VBoxContainer

@onready var body: PanelContainer = $Body

@onready var quest_title: Label = $Header/MarginContainer/HBoxContainer/QuestTitle
@onready var description: RichTextLabel = $Body/Margins/Content/Description

func _ready() -> void:
	body.visible = false

func setup(quest: Object) -> void:
	quest_title.text = quest.quest_name
	description.text = quest.quest_description

func _on_header_pressed() -> void:
	body.visible = not body.visible
