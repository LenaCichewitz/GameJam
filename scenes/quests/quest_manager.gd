extends Node

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
			push_error("[Loading]: Multiple quest save data for a given quest id were found. Can't uniquely identify which quest to load.")
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
