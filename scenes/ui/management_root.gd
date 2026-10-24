extends Control

@export var mermaid_manager : Node
@export var quest_manager: Node


#region import... stuffy... thingies(idk)
@onready var management_root: Control = $"."

@onready var mermaid_information: Panel = $Mermaid_Information

@onready var mermaid_list_item: Control = $"Mermaid_Management/MermaidDetailsRoot/Panel/VBoxContainer/Mermaids/Mermaid List Row1/MermaidListItem"
@onready var mermaid_list_item_2: Control = $"Mermaid_Management/MermaidDetailsRoot/Panel/VBoxContainer/Mermaids/Mermaid List Row1/MermaidListItem2"
@onready var mermaid_list_item_3: Control = $"Mermaid_Management/MermaidDetailsRoot/Panel/VBoxContainer/Mermaids/Mermaid List Row1/MermaidListItem3"
@onready var mermaid_list_item_4: Control = $"Mermaid_Management/MermaidDetailsRoot/Panel/VBoxContainer/Mermaids/Mermaid List Row2/MermaidListItem4"
@onready var mermaid_list_item_5: Control = $"Mermaid_Management/MermaidDetailsRoot/Panel/VBoxContainer/Mermaids/Mermaid List Row2/MermaidListItem5"

@onready var quest_list_content: VBoxContainer = $Mermaid_Management/QuestInterfaceRoot/QuestSelection/QuestBodyMargins/QuestListScroll/QuestListContent
#endregion

func _ready() -> void:
	_on_management_root_requesting_all_recruited_mermaids()
	add_quest()
	mermaid_information.hide()

func _on_management_root_requesting_all_recruited_mermaids() -> void:
	if not mermaid_manager:
		return
	
	var ListItem = [mermaid_list_item, mermaid_list_item_2, mermaid_list_item_3, mermaid_list_item_4, mermaid_list_item_5]
	
	var mermaids:Array = mermaid_manager._get_all_recruited_mermaids()
	
	var index = 0
	
	for mermaid in mermaids:
		if index >= ListItem.size():
			break
		var item = ListItem[index]
		var mermaid_id = mermaid.mermaid_id
		var mermaid_name = mermaid.mermaid_name
		var mermaid_icon = mermaid.mermaid_head_shot
		
		item.get_node("VBoxContainer/MermaidName").text = mermaid_name
		item.get_node("VBoxContainer/MermaidIcon").texture_normal = mermaid_icon
		item.get_node("VBoxContainer/MermaidID").text = str(mermaid_id)
		item.visible = true
		
		index += 1

func _on_management_root_requesting_quest() -> Array:
	if not quest_manager:
		return []
	var quest:Array = quest_manager.get_all_available_quests()
	return quest
	
func add_quest() -> void:
	var quests = _on_management_root_requesting_quest()
	var quest_scene = load("res://scenes/ui/components/quest_list_item.tscn")
	
	for quest in quests:
		var quest_ui = quest_scene.instantiate()
		quest_list_content.add_child(quest_ui)
		quest_ui.setup(quest)
	

func import_mermaid_by_id(id:int) -> void:
	if not mermaid_manager:
		return
	
	var mermaid = mermaid_manager.get_mermaid_for_id(id)
	mermaid_information.get_node("MarginContainer/VBoxContainer/body/first child/Header/MarginContainer/Name").text = mermaid.mermaid_name
	mermaid_information.get_node("MarginContainer/VBoxContainer/body/first child/MarginContainer/Mermaid_Picture").texture = mermaid.mermaid_full_body
	mermaid_information.get_node("MarginContainer/VBoxContainer/body/second child/MarginContainer/Story/VBoxContainer/RichTextLabel").text = mermaid.mermaid_description
	mermaid_information.get_node("MarginContainer/VBoxContainer/body/third child/ProgressBar").value = mermaid.corruption_increase_per_increment
	
	mermaid_information.show()

#region buttons
func _on_restauration_button_pressed() -> void:
	management_root.hide()

func _on_close_button_mermaid_info_pressed() -> void:
	mermaid_information.hide()

func _on_mermaid_list_item_mermaid_pressed(id: int) -> void:
	import_mermaid_by_id(id)

func _on_mermaid_list_item_2_mermaid_pressed(id: int) -> void:
	import_mermaid_by_id(id)

func _on_mermaid_list_item_3_mermaid_pressed(id: int) -> void:
	import_mermaid_by_id(id)

func _on_mermaid_list_item_4_mermaid_pressed(id: int) -> void:
	import_mermaid_by_id(id)

func _on_mermaid_list_item_5_mermaid_pressed(id: int) -> void:
	import_mermaid_by_id(id)
#endregion
