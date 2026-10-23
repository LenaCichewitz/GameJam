extends Node


signal requesting_mermaid_data(mermaid_id: int)
signal reporting_quest_outcome(quest_id: int, mermaid_id: int, outcome: EnumConstants.QuestCompletionState)
signal reporting_mermaid_as_exploring(mermaid_id: int)
signal final_quest_completed()

var quest_to_mermaid_mapping: Dictionary


func _ready() -> void:
	for quest in _get_all_quests():
		if not quest.quest_started.is_connected(_on_quest_started):
			quest.quest_started.connect(_on_quest_started)
		if not quest.quest_completed.is_connected(_on_quest_completed):
			quest.quest_completed.connect(_on_quest_completed)
		if not quest.requesting_mermaid_data.is_connected(_on_requesting_mermaid_data):
			quest.requesting_mermaid_data.connect(_on_requesting_mermaid_data)


#region save / load
func save() -> Array[QuestSaveData]:
	var quest_data: Array[QuestSaveData]
	var quests = _get_all_quests()
	for quest in quests:
		quest_data.append(quest.save())
	return quest_data


func load_data(data: Array[QuestSaveData]):
	var quests = _get_all_quests()
	for quest in quests:
		var quest_data_for_quest_id = data.filter(func(obj): return obj.get_quest_id() == quest.quest_id)
		if quest_data_for_quest_id.is_empty():
			continue
		if quest_data_for_quest_id.size() > 1:
			push_error("[Loading]: Multiple quest save data for a given quest id were found. Can't uniquely identify which quest to load. ID:" + str(quest.quest_id))
			continue
		var quest_save_data: QuestSaveData = quest_data_for_quest_id.front()
		quest.load_data(quest_save_data)
		if quest.is_active:
			quest_to_mermaid_mapping[quest.quest_id] = quest.assigned_mermaid_id
			quest.reparent($ActiveQuests)
		elif quest.completed:
			quest.reparent($CompletedQuests)


#endregion

#region getter / setter
func is_action_available() -> bool:
	return !$AvailableQuests.get_children().is_empty()


func assign_mermaid_to_quest(quest_id: int, mermaid_id: int):
	var quest = _find_quest_with_id(quest_id)
	if not quest:
		return
	
	var current_mermaid_assignments = _get_quest_ids_for_mermaid_id(mermaid_id)
	if current_mermaid_assignments.size() > 0:
		for assigned_quest_id in current_mermaid_assignments:
			quest_to_mermaid_mapping.erase(assigned_quest_id)
	quest_to_mermaid_mapping[quest_id] = mermaid_id
	quest.assign_mermaid(mermaid_id)

func provide_mermaid_stats(mermaid_id: int, stats: Dictionary):
	var quest_idss = _get_quest_ids_for_mermaid_id(mermaid_id)
	for quest_id in quest_idss:
		var quest = _find_quest_with_id(quest_id)
		if not quest:
			continue
		quest.provide_mermaid_stats(mermaid_id, stats)


func get_all_available_quests() -> Array[Node]:
	var all_available_quests = $AvailableQuests.get_children()
	var lowest_group: int = INT32_MAX
	for quest in all_available_quests:
		if quest.quest_group < lowest_group:
			lowest_group = quest.quest_group
	
	var available_quests_of_lowest_group: Array[Node]
	for quest in all_available_quests:
		if quest.quest_group == lowest_group:
			available_quests_of_lowest_group.append(quest)
	
	return available_quests_of_lowest_group


func get_all_lost_items() -> Array[Node]:
	var items: Array[Node]
	var quests = _get_all_quests()
	for quest in quests:
		items.append_array(quest.get_lost_items())
	return items


func get_quest_for_id(quest_id: int) -> Node:
	return _find_quest_with_id(quest_id)


func _get_all_quests() -> Array[Node]:
	var quests: Array[Node]
	quests.append_array($AvailableQuests.get_children())
	quests.append_array($ActiveQuests.get_children())
	quests.append_array($CompletedQuests.get_children())
	return quests


func _get_all_active_quests() -> Array[Node]:
	var quests: Array[Node]
	quests.append_array($ActiveQuests.get_children())
	return quests


func _get_quest_ids_for_mermaid_id(mermaid_id: int) -> Array[int]:
	var quests: Array[int]
	for quest: int in quest_to_mermaid_mapping:
		if mermaid_id == quest_to_mermaid_mapping[quest]:
			quests.append(quest)
	return quests


func _find_quest_with_id(quest_id: int) -> Node:
	var quests = _get_all_quests()
	var filtered_quests: Array[Node] = quests.filter(func(obj): return obj.quest_id == quest_id)
	if filtered_quests.size() > 1:
		push_error("[find_node_with_id]: Found multiple quests with given id. Can't uniquely identify a quest. ID:" + str(quest_id))
	return filtered_quests.front()
#endregion


func start_all_quests():
	var available_quests = get_all_available_quests()
	for quest in available_quests:
		quest.start_quest()


func increment_progress():
	var quests = _get_all_active_quests()
	for quest in quests:
		quest.increment_progress()


func _on_quest_started(quest_id: int, mermaid_id: int) -> void:
	var quest = _find_quest_with_id(quest_id)
	if not quest:
		return
	
	quest.reparent($ActiveQuests)
	reporting_mermaid_as_exploring.emit(mermaid_id)


func _on_quest_completed(quest_id: int, state: EnumConstants.QuestCompletionState) -> void:
	var quest = _find_quest_with_id(quest_id)
	if not quest:
		return
	reporting_quest_outcome.emit(quest_id, quest_to_mermaid_mapping.get(quest_id, -1), state)
	quest_to_mermaid_mapping.erase(quest_id)
	if state == EnumConstants.QuestCompletionState.FINAL_SUCCESS:
		quest.reparent($CompletedQuests)
		final_quest_completed.emit()
		return
	if state == EnumConstants.QuestCompletionState.SUCCESS:
		quest.reparent($CompletedQuests if quest.one_shot else $AvailableQuests)
		return
	if state == EnumConstants.QuestCompletionState.NEUTRAL:
		quest.reparent($AvailableQuests)
		return
	#Failure
	quest.reparent($AvailableQuests)


func _on_requesting_mermaid_data(quest_id: int, mermaid_id: int) -> void:
	quest_to_mermaid_mapping[quest_id] = mermaid_id
	requesting_mermaid_data.emit(mermaid_id)
