extends Node

@export var _agility: Curve
@export var _combat: Curve
@export var _awareness: Curve
@export var _eldritch_knowledge: Curve
@export var _map_layout_knowledge: Curve
@export var _mental_clarity: Curve
@export_range(0, 100) var _corruption: float


func get_agility_for_corruption(corruption: float) -> float:
	return _agility.sample(corruption)


func get_agility() -> float:
	return get_agility_for_corruption(get_corruption())


func get_agility_for_zero_corruption() -> float:
	return get_agility_for_corruption(0)


func get_combat_for_corruption(corruption: float) -> float:
	return _combat.sample(corruption)


func get_combat() -> float:
	return get_combat_for_corruption(get_corruption())


func get_combat_for_zero_corruption() -> float:
	return get_combat_for_corruption(0)


func get_awareness_for_corruption(corruption: float) -> float:
	return _awareness.sample(corruption)


func get_awareness() -> float:
	return get_awareness_for_corruption(get_corruption())


func get_awareness_for_zero_corruption() -> float:
	return get_awareness_for_corruption(0)


func get_eldritch_knowledge_for_corruption(corruption: float) -> float:
	return _eldritch_knowledge.sample(corruption)


func get_eldritch_knowledge() -> float:
	return get_eldritch_knowledge_for_corruption(get_corruption())


func get_eldritch_knowledge_for_zero_corruption() -> float:
	return get_eldritch_knowledge_for_corruption(0)


func get_map_layout_knowledge_for_corruption(corruption: float) -> float:
	return _map_layout_knowledge.sample(corruption)


func get_map_layout_knowledge() -> float:
	return get_map_layout_knowledge_for_corruption(get_corruption())


func get_map_layout_knowledge_for_zero_corruption() -> float:
	return get_map_layout_knowledge_for_corruption(0)


func get_mental_clarity_for_corruption(corruption: float) -> float:
	return _mental_clarity.sample(corruption)


func get_mental_clarity() -> float:
	return get_mental_clarity_for_corruption(get_corruption())


func get_mental_clarity_for_zero_corruption() -> float:
	return get_mental_clarity_for_corruption(0)


func get_corruption() -> float:
	return _corruption
