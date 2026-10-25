extends Node


signal reequip_to_mermaid(item_id: int, mermaid_id: int)
signal reequip_to_lost_quest(item_id: int, quest_id: int)

@export var item_id: int = 0
@export var item_name: String
@export var item_picture: Texture2D
@export_multiline var item_description: String
@export var use_corruption_for_stat_changes: bool = false
@export var is_repaired: bool = false
@export var is_obtained: bool = false

var _assigned_mermaid_id: int = -1
var _lost_on_quest_id: int = -1


#region save/load
func save() -> ItemSaveData:
	SaveManager.register("item", self)
	
	return ItemSaveData.new(item_id, is_repaired, is_obtained, _assigned_mermaid_id, _lost_on_quest_id)


func load_data(data: ItemSaveData):
	if item_id != data.get_item_id():
		return
	is_repaired = data.is_repaired()
	is_obtained = data.is_obtained()
	if data.get_assigned_mermaid_id() >= 0 and data.get_lost_on_quest_id() >= 0:
		push_error("[item loading]: item was assigned to both mermaids and lost on quest. Can't identify wich so we do either")
		return
	_assigned_mermaid_id = data.get_assigned_mermaid_id()
	_lost_on_quest_id = data.get_lost_on_quest_id()
	if _assigned_mermaid_id >= 0:
		reequip_to_mermaid.emit(item_id, _assigned_mermaid_id)
	elif _lost_on_quest_id >= 0:
		reequip_to_lost_quest.emit(item_id, _lost_on_quest_id)

#endregion

#region getter/setter
func assign_mermaid(mermaid_id: int):
	_assigned_mermaid_id = mermaid_id
	_lost_on_quest_id = -1


func lost_on_quest(quest_id: int):
	_assigned_mermaid_id = -1
	_lost_on_quest_id = quest_id


func release():
	_assigned_mermaid_id = -1
	_lost_on_quest_id = -1


func is_assigned() -> bool:
	return _assigned_mermaid_id >= 0 || _lost_on_quest_id >= 0


func get_assigned_mermaid_id() -> int:
	return _assigned_mermaid_id

func get_lost_on_quest_id() -> int:
	return _lost_on_quest_id
#endregion


func calculate_stats_from_node(stats: Node) -> Dictionary:
	var output: Dictionary
	var relevant_corruption: float = stats.get_corruption() if use_corruption_for_stat_changes else 0
	output["agility"] = max(stats.get_agility() + $Stats.get_agility_for_corruption(relevant_corruption), 0)
	output["combat"] = max(stats.get_combat() + $Stats.get_combat_for_corruption(relevant_corruption), 0)
	output["awareness"] = max(stats.get_awareness() + $Stats.get_awareness_for_corruption(relevant_corruption), 0)
	output["eldritch_knowledge"] = max(stats.get_eldritch_knowledge() + $Stats.get_eldritch_knowledge_for_corruption(relevant_corruption), 0)
	output["map_layout_knowledge"] = max(stats.get_map_layout_knowledge() + $Stats.get_map_layout_knowledge_for_corruption(relevant_corruption), 0)
	output["mental_clarity"] = max(stats.get_mental_clarity() + $Stats.get_mental_clarity_for_corruption(relevant_corruption), 0)
	output["corruption"] = max(stats.get_corruption(), 0)
	return output


func calculate_stats_from_dictionary(stats: Dictionary) -> Dictionary:
	var output: Dictionary
	var relevant_corruption: float = stats.get("corruption", 0) if use_corruption_for_stat_changes else 0
	output["agility"] = max(stats.get("agility", 0) + $Stats.get_agility_for_corruption(relevant_corruption), 0)
	output["combat"] = max(stats.get("combat", 0) + $Stats.get_combat_for_corruption(relevant_corruption), 0)
	output["awareness"] = max(stats.get("awareness", 0) + $Stats.get_awareness_for_corruption(relevant_corruption), 0)
	output["eldritch_knowledge"] = max(stats.get("eldritch_knowledge", 0) + $Stats.get_eldritch_knowledge_for_corruption(relevant_corruption), 0)
	output["map_layout_knowledge"] = max(stats.get("map_layout_knowledge", 0) + $Stats.get_map_layout_knowledge_for_corruption(relevant_corruption), 0)
	output["mental_clarity"] = max(stats.get("mental_clarity", 0) + $Stats.get_mental_clarity_for_corruption(relevant_corruption), 0)
	output["corruption"] = max(stats.get("corruption", 0), 0)
	return output
