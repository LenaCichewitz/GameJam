extends Object
class_name MermaidSaveData
var _mermaid_id: int = 0
var _alive: bool = false
var _recruited: bool = false
var _corruption: float = 0.0

func _init(mermaid_id: int, alive: bool, recruited: bool, corruption: float):
	_mermaid_id = mermaid_id
	_alive = alive
	_recruited = recruited
	_corruption = corruption


func get_mermaid_id() -> int:
	return _mermaid_id


func is_alive() -> bool:
	return _alive


func is_recruited() -> bool:
	return _recruited


func get_corruption() -> float:
	return _corruption
