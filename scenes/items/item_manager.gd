extends Node


signal item_obtained(item_id: int)
signal item_repaired(item_id: int)
signal item_equipped(item_id: int, mermaid_id: int)
signal item_unequipped(item_id: int)
signal items_lost_on_quest(quest_id: int)
signal items_reclaimed_from_quest(quest_id: int)

@export var mermaid_manager: Node
@export var quest_manager: Node


func _ready() -> void:
	for item in _get_all_items():
		_connect_item_signals(item)


#region save/load
func save() -> Array[ItemSaveData]:
	var data: Array[ItemSaveData]
	for item in _get_all_items():
		data.append(item.save())
	return data


func load_data(data: Array[ItemSaveData]):
	for item in _get_all_items():
		var item_data_for_item_id = data.filter(func(obj): return obj.get_item_id() == item.item_id)
		if item_data_for_item_id.is_empty():
			continue
		if item_data_for_item_id.size() > 1:
			push_error("[item loading]: Multiple save entries found for item id. Can't uniquely identify which to load. ID:" + str(item.item_id))
			continue
		# Assigned items re-place themselves via the reequip_* signals emitted inside item.load()
		item.load_data(item_data_for_item_id.front())
		if not item.is_assigned():
			_place_unassigned_item(item)
#endregion

#region getter/setter
func has_unrepaired_items() -> bool:
	return !$UnrepairedItems.get_children().is_empty()


func has_unequipped_items() -> bool:
	return !$UnequippedItems.get_children().is_empty()


func get_unrepaired_items() -> Array[Node]:
	return $UnrepairedItems.get_children()


func get_unequipped_items() -> Array[Node]:
	return $UnequippedItems.get_children()


func get_item_for_id(item_id: int) -> Node:
	return _find_item_with_id(item_id)


func _get_all_items() -> Array[Node]:
	var items: Array[Node]
	items.append_array($UnobtainedItems.get_children())
	items.append_array($UnrepairedItems.get_children())
	items.append_array($UnequippedItems.get_children())
	if mermaid_manager:
		items.append_array(mermaid_manager.get_all_equipped_items())
	if quest_manager:
		items.append_array(quest_manager.get_all_lost_items())
	return items


func _find_item_with_id(item_id: int) -> Node:
	var items = _get_all_items()
	var filtered_items = items.filter(func(obj): return obj.item_id == item_id)
	if filtered_items.size() > 1:
		push_error("[find_item_with_id]: Found multiple items with id " + str(item_id) + ". Can't uniquely identify item.")
		return null
	return filtered_items.front()


func _get_mermaid(mermaid_id: int) -> Node:
	if not mermaid_manager:
		return null
	return mermaid_manager.get_mermaid_for_id(mermaid_id)


func _get_quest(quest_id: int) -> Node:
	if not quest_manager:
		return null
	return quest_manager.get_quest_for_id(quest_id)
#endregion

#region item actions
func obtain_item(item_id: int) -> void:
	var item = _find_item_with_id(item_id)
	if item:
		_obtain(item)


func repair_item(item_id: int) -> void:
	var item = _find_item_with_id(item_id)
	if not item or item.get_parent() != $UnrepairedItems:
		return
	item.is_repaired = true
	item.reparent($UnequippedItems)
	item_repaired.emit(item_id)


func equip_item(item_id: int, mermaid_id: int) -> void:
	var item = _find_item_with_id(item_id)
	if not item or item.get_parent() != $UnequippedItems:
		return
	var mermaid = _get_mermaid(mermaid_id)
	# Only recruited, living, idle mermaids can change gear. Drop this guard if you disagree.
	if not mermaid or not mermaid.recruited or not mermaid.alive or mermaid.is_exploring():
		return
	item.assign_mermaid(mermaid_id)
	mermaid.assign_item(item)
	item_equipped.emit(item_id, mermaid_id)


func unequip_item(item_id: int) -> void:
	var item = _find_item_with_id(item_id)
	if not item:
		return
	var mermaid_id: int = item.get_assigned_mermaid_id()
	if mermaid_id < 0:
		return
	var mermaid = _get_mermaid(mermaid_id)
	if mermaid and mermaid.is_exploring():
		return
	item.release()
	item.reparent($UnequippedItems)
	item_unequipped.emit(item_id)
#endregion

#region internals
func _connect_item_signals(item: Node) -> void:
	if not item.reequip_to_mermaid.is_connected(_on_item_reequip_to_mermaid):
		item.reequip_to_mermaid.connect(_on_item_reequip_to_mermaid)
	if not item.reequip_to_lost_quest.is_connected(_on_item_reequip_to_lost_quest):
		item.reequip_to_lost_quest.connect(_on_item_reequip_to_lost_quest)


func _place_unassigned_item(item: Node) -> void:
	if not item.is_obtained:
		item.reparent($UnobtainedItems)
	elif not item.is_repaired:
		item.reparent($UnrepairedItems)
	else:
		item.reparent($UnequippedItems)


func _lose_items_on_quest(quest: Node, mermaid_id: int) -> void:
	var mermaid = _get_mermaid(mermaid_id)
	if not mermaid:
		return
	var items: Array[Node] = mermaid.get_items()
	if items.is_empty():
		return
	for item in items:
		item.lost_on_quest(quest.quest_id)
	quest.assign_lost_items(items)
	items_lost_on_quest.emit(quest.quest_id)


func _obtain(item: Node) -> void:
	if item.is_obtained:
		return
	item.release()
	item.is_obtained = true
	item.reparent($UnequippedItems if item.is_repaired else $UnrepairedItems)
	item_obtained.emit(item.item_id)


func _reclaim_lost_items(quest: Node) -> void:
	var lost_items: Array[Node] = quest.get_lost_items()
	if lost_items.is_empty():
		return
	for item in lost_items:
		item.release()
		_place_unassigned_item(item)
	items_reclaimed_from_quest.emit(quest.quest_id)
#endregion


func _on_item_reequip_to_mermaid(item_id: int, mermaid_id: int) -> void:
	var item = _find_item_with_id(item_id)
	if not item:
		return
	var mermaid = _get_mermaid(mermaid_id)
	if not mermaid:
		push_error("[item loading]: Mermaid " + str(mermaid_id) + " not found for item " + str(item_id) + ". Releasing item.")
		item.release()
		_place_unassigned_item(item)
		return
	mermaid.assign_item(item)


func _on_item_reequip_to_lost_quest(item_id: int, quest_id: int) -> void:
	var item = _find_item_with_id(item_id)
	if not item:
		return
	var quest = _get_quest(quest_id)
	if not quest:
		push_error("[item loading]: Quest " + str(quest_id) + " not found for item " + str(item_id) + ". Releasing item.")
		item.release()
		_place_unassigned_item(item)
		return
	var items: Array[Node] = [item]
	quest.assign_lost_items(items)


func _on_quest_manager_reporting_quest_outcome(quest_id: int, mermaid_id: int, outcome: EnumConstants.QuestCompletionState) -> void:
	var quest = _get_quest(quest_id)
	if not quest:
		return
	match outcome:
		EnumConstants.QuestCompletionState.FAILURE:
			_lose_items_on_quest(quest, mermaid_id)
		EnumConstants.QuestCompletionState.SUCCESS, EnumConstants.QuestCompletionState.FINAL_SUCCESS:
			_reclaim_lost_items(quest)
			if quest.rewards_item:
				obtain_item(quest.reward_item_id)
