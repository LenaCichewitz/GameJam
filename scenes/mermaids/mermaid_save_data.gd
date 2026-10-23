extends Object
class_name MermaidSaveData
var _mermaid_id: int = 0
var _alive: bool = false
var _recruited: bool = false
var _is_exploring: bool = false
var _corruption: float = 0.0

func _init(mermaid_id: int, alive: bool, recruited: bool, is_exploring_val: bool, corruption: float):
	_mermaid_id = mermaid_id
	_alive = alive
	_recruited = recruited
	_is_exploring = is_exploring_val
	_corruption = corruption


func get_mermaid_id() -> int:
	return _mermaid_id


func is_alive() -> bool:
	return _alive


func is_recruited() -> bool:
	return _recruited


func is_exploring() -> bool:
	return _is_exploring


func get_corruption() -> float:
	return _corruption
