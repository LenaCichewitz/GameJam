extends Node

signal quest_completed(quest_id: int, state: EnumConstants.QuestCompletionState)
signal requesting_mermaid_data(quest_id: int, mermaid_id: int)

@export var quest_id: int = 0
@export_group("Flavour")
@export var quest_name: String
@export_multiline var quest_description: String
@export_multiline var quest_success_outcome: String
@export_multiline var quest_neutral_outcome: String
@export_multiline var quest_failure_outcome: String
@export_group("Mechanical Properties")
@export var completed: bool = false
@export var one_shot: bool = true
@export var use_mermaid_corruption_for_success_calculation: bool = false
@export var total_duration: int = 0
@export var duration_decrement_step_size: float = 1.0
@export var quest_group: int = 0
@export_group("Rewards")
@export var rewards_item: bool = false
@export var item_id: int = -1
@export var rewards_corruption_reduction: bool = false
@export_range(-100, 100) var corruption_reduciton: float = 0.0

var is_active: bool = false
#placeholder for now
var assigned_mermaid_id: int = -1
var assigned_mermaid_stats: Node
var remaining_duration: float = 0.0

#region save / load
func save() -> QuestSaveData:
	var data: QuestSaveData = QuestSaveData.new(quest_id, completed, is_active, assigned_mermaid_id, remaining_duration)
	return data


func load(data: QuestSaveData):
	if quest_id != data.get_quest_id():
		pass
		
	completed = data.is_completed()
	is_active = data.is_active()
	if is_active:
		remaining_duration = data.get_remaining_duration_left()
		assigned_mermaid_id = data.get_assigned_mermaid_id()
		requesting_mermaid_data.emit(quest_id, assigned_mermaid_id)
#endregion

#region getter/setter
func assign_mermaid(mermaid_id: int):
	assigned_mermaid_id = mermaid_id
	requesting_mermaid_data.emit(quest_id, assigned_mermaid_id)


func provide_mermaid_stats(mermaid_id: int, mermaid_stat_block: Node):
	if mermaid_id != assigned_mermaid_id:
		return
	assigned_mermaid_stats = mermaid_stat_block


func get_remaining_duration() -> float:
	return remaining_duration
#endregion

#region quest progression loop
func start_quest():
	if not assigned_mermaid_id:
		return
	remaining_duration = remaining_duration if is_active else float(total_duration)
	is_active = true


func _calculate_success() -> EnumConstants.QuestCompletionState:
	#todo thesimilier
	return EnumConstants.QuestCompletionState.NEUTRAL


func increment_progress():
	if not is_active:
		return
	remaining_duration -= duration_decrement_step_size
	if remaining_duration >= 0:
		is_active = false
		quest_completed.emit(quest_id, _calculate_success())
#endregion
