extends Control

@export var mermaid_manager : Node
@export var quest_manager: Node
@onready var management_root: Control = $"."

@onready var mermaid_information: Panel = $Mermaid_Information

@onready var mermaid_list_item: Control = $"HBoxContainer/MermaidDetailsRoot/Panel/VBoxContainer/Mermaids/Mermaid List Row1/MermaidListItem"
@onready var mermaid_list_item_2: Control = $"HBoxContainer/MermaidDetailsRoot/Panel/VBoxContainer/Mermaids/Mermaid List Row1/MermaidListItem2"
@onready var mermaid_list_item_3: Control = $"HBoxContainer/MermaidDetailsRoot/Panel/VBoxContainer/Mermaids/Mermaid List Row1/MermaidListItem3"
@onready var mermaid_list_item_4: Control = $"HBoxContainer/MermaidDetailsRoot/Panel/VBoxContainer/Mermaids/Mermaid List Row2/MermaidListItem4"
@onready var mermaid_list_item_5: Control = $"HBoxContainer/MermaidDetailsRoot/Panel/VBoxContainer/Mermaids/Mermaid List Row2/MermaidListItem5"


func _ready() -> void:
	_on_management_root_requesting_all_recruited_mermaids()
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
		var mermaid_name = mermaid.mermaid_name
		var mermaid_icon = mermaid.mermaid_head_shot
		
		item.get_node("VBoxContainer/MermaidName").text = mermaid_name
		item.get_node("VBoxContainer/MermaidIcon").texture = mermaid_icon
		item.visible = true
		
		index += 1

func _on_management_root_requesting_quest() -> void:
	if not quest_manager:
		return
	
	var quest:Array = quest_manager.get_all_available_quests()

func _on_restauration_button_pressed() -> void:
	management_root.hide()

func _on_close_button_mermaid_info_pressed() -> void:
	mermaid_information.hide()
