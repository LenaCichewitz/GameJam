extends VBoxContainer

@onready var body: PanelContainer = $Body

@onready var quest_title: Label = $Header/MarginContainer/HBoxContainer/QuestTitle
@onready var description: RichTextLabel = $Body/Margins/Content/Description
@onready var quest_id: Label = $Body/Margins/Content/Data/Row/QuestId
@onready var overlay: Control = $Body/Overlay
@onready var selecting_mermaid: VBoxContainer = $Body/Overlay/MarginContainer/SelectMermaid
@onready var mermaid_button: TextureButton = $Body/Margins/Content/Data/Row/Mermaid


signal mermaid_and_quest_choosen

func _ready() -> void:
	body.hide()
	quest_id.hide()
	overlay.hide()

func setup(quest: Object) -> void:
	quest_title.text = quest.quest_name
	description.text = quest.quest_description
	quest_id.text = str(quest.quest_id)

func select_mermaid(available_mermaids: Array[Node]):
	if available_mermaids.is_empty():
		return
	
	for available_mermaid in available_mermaids:
		var button = Button.new()
		var label = Label.new()
		button.text = available_mermaid.mermaid_name
		label.text = str(available_mermaid.mermaid_id)
		label.hide()
		button.add_child(label)
		selecting_mermaid.add_child(button)
		button.pressed.connect(_on_mermaid_button_pressed.bind(available_mermaid))

func _on_header_pressed() -> void:
	body.visible = not body.visible

func _on_select_mermaid_pressed() -> void:
	overlay.show()

func _on_mermaid_button_pressed(mermaid: Node) -> void:
	var mermaid_id = mermaid.mermaid_id
	var mermaid_icon = mermaid.mermaid_icon
	mermaid_button.texture_normal = mermaid_icon
	mermaid_and_quest_choosen.emit(quest_id.text.to_int(), mermaid_id)
