extends Node

@export var _agility: Curve
@export var _combat: Curve
@export var _awareness: Curve
@export var _eldritch_knowledge: Curve
@export var _map_layout_knowledge: Curve
@export var _mental_clarity: Curve
@export_range(0, 100) var _corruption: float


func _normalize_stat(stat: float) -> float:
	return float(int(stat * 10))


func _normalize_corruption(corruption: float) -> float:
	return corruption / 100.0


func get_agility_for_corruption(corruption: float) -> float:
	return _normalize_stat(_agility.sample(_normalize_corruption(corruption)))


func get_agility() -> float:
	return get_agility_for_corruption(get_corruption())


func get_agility_for_zero_corruption() -> float:
	return get_agility_for_corruption(0)


func get_combat_for_corruption(corruption: float) -> float:
	return _normalize_stat(_combat.sample(_normalize_corruption(corruption)))


func get_combat() -> float:
	return get_combat_for_corruption(get_corruption())


func get_combat_for_zero_corruption() -> float:
	return get_combat_for_corruption(0)


func get_awareness_for_corruption(corruption: float) -> float:
	return _normalize_stat(_awareness.sample(_normalize_corruption(corruption)))


func get_awareness() -> float:
	return get_awareness_for_corruption(get_corruption())


func get_awareness_for_zero_corruption() -> float:
	return get_awareness_for_corruption(0)


func get_eldritch_knowledge_for_corruption(corruption: float) -> float:
	return _normalize_stat(_eldritch_knowledge.sample(_normalize_corruption(corruption)))


func get_eldritch_knowledge() -> float:
	return get_eldritch_knowledge_for_corruption(get_corruption())


func get_eldritch_knowledge_for_zero_corruption() -> float:
	return get_eldritch_knowledge_for_corruption(0)


func get_map_layout_knowledge_for_corruption(corruption: float) -> float:
	return _normalize_stat(_map_layout_knowledge.sample(_normalize_corruption(corruption)))


func get_map_layout_knowledge() -> float:
	return get_map_layout_knowledge_for_corruption(get_corruption())


func get_map_layout_knowledge_for_zero_corruption() -> float:
	return get_map_layout_knowledge_for_corruption(0)


func get_mental_clarity_for_corruption(corruption: float) -> float:
	return _normalize_stat(_mental_clarity.sample(_normalize_corruption(corruption)))


func get_mental_clarity() -> float:
	return get_mental_clarity_for_corruption(get_corruption())


func get_mental_clarity_for_zero_corruption() -> float:
	return get_mental_clarity_for_corruption(0)


func get_corruption() -> float:
	return _corruption


func set_corruption(new_val: float):
	_corruption = new_val


func add_corruption(amount: float):
	_corruption += amount


func get_stats_as_dictionary() -> Dictionary:
	var output: Dictionary
	output["agility"] = max(get_agility(), 0)
	output["combat"] = max(get_combat(), 0)
	output["awareness"] = max(get_awareness(), 0)
	output["eldritch_knowledge"] = max(get_eldritch_knowledge(), 0)
	output["map_layout_knowledge"] = max(get_map_layout_knowledge(), 0)
	output["mental_clarity"] = max(get_mental_clarity(), 0)
	output["corruption"] = max(get_corruption(), 0)
	return output

func compare_against_stats(stats: Node, use_own_corruption_for_source_sampling: bool) -> bool:
	var relevant_corruption = get_corruption() if use_own_corruption_for_source_sampling else stats.get_corruption()
	return (get_agility() >= stats.get_agility_for_corruption(relevant_corruption) 
		and get_combat() >= stats.get_combat_for_corruption(relevant_corruption)
		and get_awareness() >= stats.get_awareness_for_corruption(relevant_corruption)
		and get_eldritch_knowledge() >= stats.get_eldritch_knowledge_for_corruption(relevant_corruption)
		and get_map_layout_knowledge() >= stats.get_map_layout_knowledge_for_corruption(relevant_corruption)
		and get_mental_clarity() >= stats.get_mental_clarity_for_corruption(relevant_corruption))


func compare_against_stats_dictionary(stats: Dictionary, use_source_corruption_for_own_sampling: bool) -> bool:
	var relevant_corruption = stats.get("corruption", 0) if use_source_corruption_for_own_sampling else get_corruption()
	return (get_agility_for_corruption(relevant_corruption) <= stats.get("agility", 0) 
		and get_combat_for_corruption(relevant_corruption) <= stats.get("combat", 0)
		and get_awareness_for_corruption(relevant_corruption) <= stats.get("awareness", 0)
		and get_eldritch_knowledge_for_corruption(relevant_corruption) <= stats.get("eldritch_knowledge", 0)
		and get_map_layout_knowledge_for_corruption(relevant_corruption) <= stats.get("map_layout_knowledge", 0)
		and get_mental_clarity_for_corruption(relevant_corruption) <= stats.get("mental_clarity", 0))
