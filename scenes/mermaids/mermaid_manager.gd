extends Node


signal no_mermaids_left()
signal mermaid_lost_to_corruption(mermaid_id: int)

@export var quest_manager: Node


func _ready() -> void:
	SaveManager.register("mermaid_manager", self)
	
	for mermaid in _get_all_mermaids():
		if not mermaid.mermaid_capped_corruption.is_connected(_on_mermaid_reporting_corruption_capped):
			mermaid.mermaid_capped_corruption.connect(_on_mermaid_reporting_corruption_capped)


#region save/load
func save() -> Array[MermaidSaveData]:
	var data: Array[MermaidSaveData]
	var mermaids = _get_all_mermaids()
	for mermaid in mermaids:
		data.append(mermaid.save())
	return data

func load_data(data: Array[MermaidSaveData]):
	var mermaids = _get_all_mermaids()
	for mermaid in mermaids:
		var mermaid_data_for_mermaid_id = data.filter(func(obj): return obj.get_mermaid_id() == mermaid.mermaid_id)
		if mermaid_data_for_mermaid_id.is_empty():
			continue
		if mermaid_data_for_mermaid_id.size() > 1:
			push_error("[loading]: Multiple mermaids found for mermaid id. Can't uniquely identify with mermaid to load. ID:" + str(mermaid.mermaid_id))
			continue
		var mermaid_data = mermaid_data_for_mermaid_id.front()
		mermaid.load_data(mermaid_data)
		if not mermaid_data.is_alive():
			mermaid.reparent($LostMermaids)
		elif mermaid_data.is_recruited():
			mermaid.reparent($RecruitedMermaids)
		else:
			mermaid.reparent($AvailableMermaids)
#endregion

#region getter/setter
func is_action_available() -> bool:
	var mermaids = $RecruitedMermaids.get_children()
	if mermaids.is_empty():
		return false
	for mermaid in mermaids:
		if !mermaid.is_exploring():
			return true
	return false


func has_recruitable_mermaids() -> bool:
	return !$AvailableMermaids.get_children().is_empty()


func get_recruitable_mermaids() -> Array[Node]:
	return $AvailableMermaids.get_children()


func get_all_equipped_items() -> Array[Node]:
	var items: Array[Node]
	var mermaids = _get_all_mermaids()
	for mermaid in mermaids:
		items.append_array(mermaid.get_items())
	return items


func get_mermaid_for_id(mermaid_id: int) -> Node:
	return _get_mermaid_for_id(mermaid_id)


func get_idle_recruited_mermaids() -> Array[Node]:
	var idle: Array[Node]
	for mermaid in $RecruitedMermaids.get_children():
		if not mermaid.is_exploring():
			idle.append(mermaid)
	return idle


func _get_mermaid_for_id(mermaid_id: int) -> Node:
	var mermaids = _get_all_mermaids()
	var filtered_mermaids = mermaids.filter(func(obj): return obj.mermaid_id == mermaid_id)
	if filtered_mermaids.size() > 1:
		push_error("[get_mermaid_for_id]: Found multiple mermaids for id " + str(mermaid_id) + ". Can't uniquely identify mermaid to get.")
		return
	return filtered_mermaids.front()


func _get_all_mermaids() -> Array[Node]:
	var mermaids: Array[Node]
	mermaids.append_array($RecruitedMermaids.get_children())
	mermaids.append_array($AvailableMermaids.get_children())
	mermaids.append_array($LostMermaids.get_children())
	return mermaids


func _get_all_recruited_mermaids() -> Array[Node]:
	var mermaids: Array[Node]
	mermaids.append_array($RecruitedMermaids.get_children())
	return mermaids


func _apply_corruption_reward(quest_id: int, mermaid: Node) -> void:
	if not quest_manager:
		return
	var quest = quest_manager.get_quest_for_id(quest_id)
	if quest and quest.rewards_corruption_reduction:
		mermaid.reduce_corruption(quest.reward_corruption_reduction)
#endregion

func increment_progress():
	var mermaids = _get_all_recruited_mermaids()
	for mermaid in mermaids:
		mermaid.increment_progress()


func _on_mermaid_reporting_corruption_capped(mermaid_id: int):
	var mermaid = _get_mermaid_for_id(mermaid_id)
	if not mermaid:
		return
	mermaid.reparent($LostMermaids)
	mermaid_lost_to_corruption.emit(mermaid_id)
	if $RecruitedMermaids.get_children().is_empty():
		no_mermaids_left.emit()
	


func _on_quest_manager_reporting_quest_outcome(quest_id: int, mermaid_id: int, outcome: EnumConstants.QuestCompletionState) -> void:
	var mermaid = _get_mermaid_for_id(mermaid_id)
	if not mermaid:
		return
	if outcome == EnumConstants.QuestCompletionState.FAILURE:
		mermaid.alive = false
		mermaid.reparent($LostMermaids)
		if $RecruitedMermaids.get_children().is_empty():
			no_mermaids_left.emit()
		return
	if outcome == EnumConstants.QuestCompletionState.SUCCESS or outcome == EnumConstants.QuestCompletionState.FINAL_SUCCESS:
		_apply_corruption_reward(quest_id, mermaid)
	mermaid.set_mermaid_exploring(false)


func _on_quest_manager_requesting_mermaid_data(mermaid_id: int) -> void:
	if not quest_manager:
		return
	
	var mermaid = _get_mermaid_for_id(mermaid_id)
	if not mermaid:
		return
	
	var stats = mermaid.get_calculated_stats()
	quest_manager.provide_mermaid_stats(mermaid_id, stats)


func _on_quest_manager_reporting_mermaid_as_exploring(mermaid_id: int) -> void:
	var mermaid = _get_mermaid_for_id(mermaid_id)
	if not mermaid:
		return
	mermaid.set_mermaid_exploring(true)
