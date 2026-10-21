extends Node


signal requesting_mermaid_data(mermaid_id: int)
signal reporting_quest_outcome(quest_id: int, mermaid_id: int, outcome: EnumConstants.QuestCompletionState)

var quest_to_mermaid_request_mapping: Dictionary

#region save / load
func save() -> Array[QuestSaveData]:
	var quest_data: Array[QuestSaveData]
	var quests = _get_all_quests()
	for quest in quests:
		quest_data.append(quest.save())
	return quest_data


func load(data: Array[QuestSaveData]):
	var quests = _get_all_quests()
	for quest in quests:
		var quest_data_for_quest_id = data.filter(func(obj): return obj.get_quest_id() == quest.quest_id)
		if quest_data_for_quest_id.is_empty():
			continue
		if quest_data_for_quest_id.size() > 1:
			push_error("[Loading]: Multiple quest save data for a given quest id were found. Can't uniquely identify which quest to load. ID:" + str(quest.quest_id))
			continue
		var quest_save_data: QuestSaveData = quest_data_for_quest_id.front()
		quest.load(quest_save_data)
		if quest.is_active:
			quest.reparent($ActiveQuests)
		elif quest.completed:
			quest.reparent($CompletedQuests)


#endregion

#region getter / setter
func _get_all_quests() -> Array[Node]:
	var quests: Array[Node]
	quests.append($AvailableQuests.get_children())
	quests.append($ActiveQuests.get_children())
	quests.append($CompletedQuests.get_children())
	return quests
#endregion


func _find_node_with_id(quest_id: int) -> Node:
	var quests = _get_all_quests()
	var filtered_quests: Array[Node] = quests.filter(func(obj): return obj.quest_id == quest_id)
	if filtered_quests.size() > 1:
		push_error("[find_node_with_id]: Found multiple quests with given id. Can't uniquely identify a quest. ID:" + str(quest_id))
	return filtered_quests.front()


func _get_requesting_quest_ids_for_mermaid_id(mermaid_id: int) -> Array[int]:
	var requesting_quests: Array[int]
	for quest: int in quest_to_mermaid_request_mapping:
		if mermaid_id == quest_to_mermaid_request_mapping[quest]:
			requesting_quests.append(quest)
	return requesting_quests

func _on_quest_completed(quest_id: int, state: EnumConstants.QuestCompletionState) -> void:
	pass # Replace with function body.


func _on_requesting_mermaid_data(quest_id: int, mermaid_id: int) -> void:
	quest_to_mermaid_request_mapping[quest_id] = mermaid_id
	requesting_mermaid_data.emit(mermaid_id)
