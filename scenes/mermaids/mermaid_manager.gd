extends Node


signal no_mermaids_left()

@export var quest_manager: Node

#region save/load
func save() -> Array[MermaidSaveData]:
	var data: Array[MermaidSaveData]
	var mermaids = _get_all_mermaids()
	for mermaid in mermaids:
		data.append(mermaid.save())
	return data

func load(data: Array[MermaidSaveData]):
	var mermaids = _get_all_mermaids()
	for mermaid in mermaids:
		var mermaid_data_for_mermaid_id = data.filter(func(obj): return obj.get_mermaid_id() == mermaid.mermaid_id)
		if mermaid_data_for_mermaid_id.is_empty():
			continue
		if mermaid_data_for_mermaid_id.size() > 1:
			push_error("[loading]: Multiple mermaids found for mermaid id. Can't uniquely identify with mermaid to load. ID:" + str(mermaid.mermaid_id))
			continue
		var mermaid_data = mermaid_data_for_mermaid_id.front()
		mermaid.load(mermaid_data)
		if not mermaid_data.is_alive():
			mermaid.reparent($LostMermaids)
		elif mermaid_data.is_recruited():
			mermaid.reparent($RecruitedMermaids)
		else:
			mermaid.reparent($AvailableMermaids)
#endregion

#region getter/setter
func _get_all_mermaids() -> Array[Node]:
	var mermaids: Array[Node]
	mermaids.append($RecruitedMermaids.get_children())
	mermaids.append($AvailableMermaids.get_children())
	mermaids.append($LostMermaids.get_children())
	return mermaids

func _get_all_recruited_mermaids() -> Array[Node]:
	var mermaids: Array[Node]
	mermaids.append($RecruitedMermaids.get_children())
	return mermaids
#endregion

func increment_progress():
	var mermaids = _get_all_recruited_mermaids()
	for mermaid in mermaids:
		mermaid.increment_progress()


func _on_quest_manager_reporting_quest_outcome(quest_id: int, mermaid_id: int, outcome: EnumConstants.QuestCompletionState) -> void:
	#
	pass # Replace with function body.
