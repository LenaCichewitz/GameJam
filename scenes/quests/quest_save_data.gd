extends Object
class_name QuestSaveData
var _quest_id: int = 0
var _completed: bool = false
var _is_active: bool = false
var _assigned_mermaid_id: int = 0
var _remaining_time_left: float = 0


func _init(quest_id: int, completed: bool, is_currently_active: bool, assigned_mermaid_id: int, remaining_time_left: float):
	_quest_id = quest_id
	_completed = completed
	_is_active = is_currently_active
	_assigned_mermaid_id = assigned_mermaid_id
	_remaining_time_left = remaining_time_left


func get_quest_id() -> int:
	return _quest_id


func is_completed() -> bool:
	return _completed


func is_active() -> bool:
	return _is_active


func get_assigned_mermaid_id() -> int:
	return _assigned_mermaid_id


func get_remaining_time_left() -> float:
	return _remaining_time_left
