extends Object
class_name ItemSaveData
var _item_id: int = 0
var _is_repaired: bool = false
var _is_obtained: bool = false
var _assigned_mermaid_id: int = -1
var _lost_on_quest_id: int = -1


func _init(item_id: int, repaired: bool, obtained: bool, assigned_mermaid_id: int, lost_on_quest_id: int):
	_item_id = item_id
	_is_repaired = repaired
	_is_obtained = obtained
	if assigned_mermaid_id >= 0 and lost_on_quest_id >= 0:
		push_error("[item saving]: item has non-default ids for both mermaid and lost quest. Not storing either to avoid loading issues.")
		return 
	_assigned_mermaid_id = assigned_mermaid_id
	_lost_on_quest_id = lost_on_quest_id


func get_item_id() -> int:
	return _item_id


func is_repaired() -> bool:
	return _is_repaired


func is_obtained() -> bool:
	return _is_obtained


func get_assigned_mermaid_id() -> int:
	return _assigned_mermaid_id


func get_lost_on_quest_id() -> int:
	return _lost_on_quest_id
