extends Node


#TODO: RELEVANT FOR GAMELOOP
signal quest_completed(quest_id: int, state: EnumConstants.QuestCompletionState)
signal quest_started(quest_id: int, mermaid_id: int)
signal requesting_mermaid_data(quest_id: int, mermaid_id: int)

#region inspector properties
@export var quest_id: int = 0
@export_group("Flavour")
@export var quest_name: String
@export_multiline var quest_description: String
@export_multiline var quest_success_outcome: String
@export_multiline var quest_neutral_outcome: String
@export_multiline var quest_failure_outcome: String
@export_group("Mechanical Properties")
@export var is_final_quest: bool = false
@export var completed: bool = false
@export var one_shot: bool = true
@export var use_mermaid_corruption_for_success_calculation: bool = false
@export_range(0.1, 2, 0.1) var corruption_to_failure_chance_ratio: float = 1.0
@export var total_duration: int = 0
@export var duration_decrement_step_size: float = 1.0
@export var quest_group: int = 0
@export_group("Rewards")
@export var rewards_item: bool = false
@export var reward_item_id: int = -1
@export var rewards_corruption_reduction: bool = false
@export_range(-100, 100) var reward_corruption_reduction: float = 0.0

@export_group("Requirements")
@export var required_quest_ids: Array[int] = []
@export var required_item_ids: Array[int] = []
@export var required_items_repaired: bool = false
@export var minimum_stats: Dictionary = {}
@export_range(-1, 100) var minimum_corruption: float = -1.0
@export_range(-1, 100) var maximum_corruption: float = -1.0
#endregion

var is_active: bool = false
var mermaids_were_lost_on_quest: bool = false
var assigned_mermaid_id: int = -1
var assigned_mermaid_stats: Dictionary
var remaining_duration: float = 0.0

func _ready() -> void:
	SaveManager.register("quest", self)



#region save / load
func save() -> QuestSaveData:
	var data: QuestSaveData = QuestSaveData.new(quest_id, completed, is_active, mermaids_were_lost_on_quest, assigned_mermaid_id, remaining_duration)
	return data


func load_data(data: QuestSaveData):
	if quest_id != data.get_quest_id():
		return
		
	completed = data.is_completed()
	is_active = data.is_active()
	mermaids_were_lost_on_quest = data.were_mermaids_lost_on_quest()
	if is_active:
		remaining_duration = data.get_remaining_duration_left()
		assigned_mermaid_id = data.get_assigned_mermaid_id()
		requesting_mermaid_data.emit(quest_id, assigned_mermaid_id)
#endregion

#region getter/setter
func assign_mermaid(mermaid_id: int):
	assigned_mermaid_id = mermaid_id
	requesting_mermaid_data.emit(quest_id, assigned_mermaid_id)


func remove_mermaid_assignment():
	assigned_mermaid_id = -1
	assigned_mermaid_stats.clear()


func provide_mermaid_stats(mermaid_id: int, mermaid_stat_block: Dictionary):
	if mermaid_id != assigned_mermaid_id:
		return
	assigned_mermaid_stats = mermaid_stat_block.duplicate()


func assign_lost_items(items: Array[Node]):
	for item in items:
		item.reparent($LostItems)


func get_lost_items() -> Array[Node]:
	return $LostItems.get_children()


func has_lost_items() -> bool:
	return !$LostItems.get_children().is_empty()


func get_remaining_duration() -> float:
	return remaining_duration


func were_mermaids_lost_on_quest() -> bool:
	return mermaids_were_lost_on_quest


func has_reward() -> bool:
	return rewards_item || rewards_corruption_reduction
#endregion
func are_requirements_met(
	quest_manager: Node,
	item_manager: Node,
	mermaid_stats: Dictionary
) -> bool:
		# Voraussetzungen durch vorherige Quests prüfen.
	for required_id in required_quest_ids:
		var required_quest = quest_manager.get_quest_for_id(required_id)

		if required_quest == null or not required_quest.completed:
			return false

	# Benötigte Gegenstände prüfen.
	for required_id in required_item_ids:
		var item = item_manager.get_item_for_id(required_id)

		if item == null or not item.is_obtained:
			return false

		if required_items_repaired and not item.is_repaired:
			return false

	# Mindestwerte prüfen.
	for stat_name in minimum_stats:
		if float(mermaid_stats.get(stat_name, -1.0)) < float(minimum_stats[stat_name]):
			return false

	# Mindestkorruption prüfen, sofern konfiguriert.
	var corruption := float(mermaid_stats.get("corruption", 0.0))

	if minimum_corruption >= 0.0 and corruption < minimum_corruption:
		return false

	# Höchstkorruption prüfen, sofern konfiguriert.
	if maximum_corruption >= 0.0 and corruption > maximum_corruption:
		return false

	return true
#region quest progression loop
func start_quest():
	if assigned_mermaid_id < 0:
		return
	remaining_duration = remaining_duration if is_active else float(total_duration)
	is_active = true
	quest_started.emit(quest_id, assigned_mermaid_id)


func _calculate_success() -> EnumConstants.QuestCompletionState:
	if assigned_mermaid_stats.is_empty():
		push_error("[quest success calculation]: No mermaid stats at quest completion.")
		return EnumConstants.QuestCompletionState.NEUTRAL
		
	var failure_threshold = assigned_mermaid_stats.get("corruption", 0) * corruption_to_failure_chance_ratio
	if randf() < failure_threshold / 100.0:
		mermaids_were_lost_on_quest = true
		return EnumConstants.QuestCompletionState.FAILURE
	
	if $StatsToClear.compare_against_stats_dictionary(assigned_mermaid_stats, use_mermaid_corruption_for_success_calculation):
		completed = one_shot or is_final_quest
		if is_final_quest:
			return EnumConstants.QuestCompletionState.FINAL_SUCCESS
		return EnumConstants.QuestCompletionState.SUCCESS
	
	return EnumConstants.QuestCompletionState.NEUTRAL


func increment_progress():
	if not is_active:
		return
	remaining_duration -= duration_decrement_step_size
	if remaining_duration <= 0:
		is_active = false
		quest_completed.emit(quest_id, _calculate_success())
		assigned_mermaid_id = -1
		assigned_mermaid_stats.clear()
#endregion
