extends Control

@export var mermaid_manager : Node
@export var quest_manager: Node
@export var item_manager: Node

#region import... stuffy... thingies(idk)
@onready var management_root: Control = $"."

@onready var quest_outcome: Panel = $QuestOutcome

@onready var mermaid_information: Panel = $Mermaid_Information
@onready var mermaid_id: Label = $Mermaid_Information/MarginContainer/VBoxContainer/MermaidID

@onready var mermaid_list_item: Control = $"Mermaid_Management/MermaidDetailsRoot/Panel/VBoxContainer/Mermaids/Mermaid List Row1/MermaidListItem"
@onready var mermaid_list_item_2: Control = $"Mermaid_Management/MermaidDetailsRoot/Panel/VBoxContainer/Mermaids/Mermaid List Row1/MermaidListItem2"
@onready var mermaid_list_item_3: Control = $"Mermaid_Management/MermaidDetailsRoot/Panel/VBoxContainer/Mermaids/Mermaid List Row1/MermaidListItem3"
@onready var mermaid_list_item_4: Control = $"Mermaid_Management/MermaidDetailsRoot/Panel/VBoxContainer/Mermaids/Mermaid List Row2/MermaidListItem4"
@onready var mermaid_list_item_5: Control = $"Mermaid_Management/MermaidDetailsRoot/Panel/VBoxContainer/Mermaids/Mermaid List Row2/MermaidListItem5"

@onready var item_button: TextureButton = $"Mermaid_Information/MarginContainer/VBoxContainer/body/third child/Items/TextureButton"
@onready var item_button_2: TextureButton = $"Mermaid_Information/MarginContainer/VBoxContainer/body/third child/Items/TextureButton2"

@onready var itembar: Control = $Itembar
@onready var items_list: HBoxContainer = $Itembar/Panel/HBoxContainer/ScrollContainer/ItemsList


@onready var quest_list_container: VBoxContainer = $Mermaid_Management/QuestInterface/VBoxContainer/MarginContainer2/ScrollContainer/QuestListContainer

#endregion

var item_list_ui = load("res://scenes/ui/components/item_list.tscn").instantiate()
var pending_quest_outcomes: Array[Dictionary] = []
var showing_quest_outcome: bool = false

func _ready() -> void:
	add_mermaids()
	add_quest()
	mermaid_information.hide()
	itembar.hide()
	quest_outcome.hide()
	item_list_ui.item_list_pressed.connect(equip_item)
	if quest_manager:
		if not quest_manager.reporting_quest_outcome.is_connected(
			_on_quest_outcome_reported
		):
			quest_manager.reporting_quest_outcome.connect(_on_quest_outcome_reported)

func _on_management_root_requesting_all_recruited_mermaids() -> Array:
	if not mermaid_manager:
		return []
	
	return mermaid_manager._get_all_recruited_mermaids()
	
func _on_quest_outcome_reported(
	quest_id: int,
	mermaid_id: int,
	outcome: EnumConstants.QuestCompletionState
) -> void:
	pending_quest_outcomes.append({
		"quest_id": quest_id,
		"mermaid_id": mermaid_id,
		"outcome": outcome
	})

	_refresh_quest_list()
	_show_next_quest_outcome()


func _show_next_quest_outcome() -> void:
	if pending_quest_outcomes.is_empty():
		showing_quest_outcome = false
		quest_outcome.hide()

		var systems = get_tree().current_scene.get_node_or_null("Systems")
		if systems:
			systems._time_paused = false

		return

	showing_quest_outcome = true

	var outcome_list: VBoxContainer = quest_outcome.get_node(
		"MarginContainer/VBoxContainer/Body/QuestOutcomeList"
	)

	for child in outcome_list.get_children():
		outcome_list.remove_child(child)
		child.queue_free()

	for result in pending_quest_outcomes:
		var quest = quest_manager.get_quest_for_id(result["quest_id"])

		if quest == null:
			push_warning(
				"Quest mit ID %s für das Ergebnisfenster nicht gefunden."
				% result["quest_id"]
			)
			continue

		var mermaid = mermaid_manager.get_mermaid_for_id(
			result["mermaid_id"]
		)

		var item: Node = null

		if quest.rewards_item:
			item = item_manager.get_item_for_id(quest.reward_item_id)

		var outcome_entry = load(
			"res://scenes/ui/components/quest_outcome_list.tscn"
		).instantiate()

		outcome_list.add_child(outcome_entry)

		outcome_entry.setup(
			quest,
			result["outcome"],
			mermaid,
			item
		)

	quest_outcome.show()

func _refresh_quest_list() -> void:
	for child in quest_list_container.get_children():
		quest_list_container.remove_child(child)
		child.queue_free()

	add_quest()
	
func _on_management_root_requesting_quest() -> Array:
	if not quest_manager:
		return []
	var quest:Array = quest_manager.get_all_available_quests()
	return quest

func _on_management_root_get_all_unequied_items()->void:
	if not item_manager:
		return
	
	var items:Array = item_manager.get_unequipped_items()
	
	for item in items:
		var item_iu =load("res://scenes/ui/components/item_list.tscn").instantiate()
		items_list.add_child(item_iu)
		item_iu.setup(item)

func add_mermaids() ->void:
	var mermaids = _on_management_root_requesting_all_recruited_mermaids()
	var ListItem = [mermaid_list_item, mermaid_list_item_2, mermaid_list_item_3, mermaid_list_item_4, mermaid_list_item_5]
	var index = 0
	
	for mermaid in mermaids:
		if index >= ListItem.size():
			break
		var item = ListItem[index]
		
		item.get_node("VBoxContainer/MermaidName").text = mermaid.mermaid_name
		item.get_node("VBoxContainer/MermaidIcon").texture_normal = mermaid.mermaid_head_shot
		item.get_node("VBoxContainer/MermaidID").text = str(mermaid.mermaid_id)
		item.visible = true
		
		index += 1

func add_quest() -> void:
	var quests = _on_management_root_requesting_quest()
	var quest_scene = load("res://scenes/ui/components/quest_list_item.tscn")
	var availiable_mermaids = _on_management_root_requesting_all_recruited_mermaids()
	
	for quest in quests:
		var quest_ui = quest_scene.instantiate()
		quest_list_container.add_child(quest_ui)
		quest_ui.setup(quest)
		quest_ui.select_mermaid(availiable_mermaids)
		
		quest_ui.mermaid_assigned_to_quest.connect(assign_mermaid_to_quest)

func import_mermaid_by_id(id:int) -> void:
	if not mermaid_manager:
		return
	var index= 0
	var item_slots = [item_button, item_button_2]
	
	var mermaid = mermaid_manager.get_mermaid_for_id(id)
	var items_equiped: Array = mermaid_manager.get_all_equipped_items()
	mermaid_id.text = str(mermaid.mermaid_id)
	mermaid_information.get_node("MarginContainer/VBoxContainer/body/first child/Header/MarginContainer/Name").text = mermaid.mermaid_name
	mermaid_information.get_node("MarginContainer/VBoxContainer/body/first child/MarginContainer/Mermaid_Picture").texture = mermaid.mermaid_full_body
	mermaid_information.get_node("MarginContainer/VBoxContainer/body/second child/MarginContainer/Story/VBoxContainer/RichTextLabel").text = mermaid.mermaid_description
	mermaid_information.get_node("MarginContainer/VBoxContainer/body/third child/ProgressBar").value = mermaid.corruption_increase_per_increment
	for item_equiped in items_equiped:
		if index >= item_slots.size():
			break
			
		var slot = item_slots[index]
		slot.texture = item_equiped.item_picture
		index += 1
	
	mermaid_information.show()

func equip_item(item_id) -> void:
	if not item_manager:
		return
	var current_mermaid_id = mermaid_id.text.to_int()
	
	item_manager.equip_item(item_id, current_mermaid_id) 

func assign_mermaid_to_quest(quest_id, assigned_mermaid_id) -> void: 
	quest_manager.assign_mermaid_to_quest(quest_id, assigned_mermaid_id) 

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

func _on_texture_button_pressed() -> void:
	itembar.show()

func _on_texture_button_2_pressed() -> void:
	itembar.show()

func _on_done_item_pressed() -> void:
	itembar.hide()

func _on_quest_send_pressed() -> void:
	if not quest_manager:
		return

	quest_manager.start_all_quests()

func _on_outcome_button_pressed() -> void:
	pending_quest_outcomes.clear()
	showing_quest_outcome = false
	var systems = get_tree().current_scene.get_node_or_null("Systems")
	if systems:
		systems._time_paused = false
	quest_outcome.hide() 

func _on_back_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
#endregion
