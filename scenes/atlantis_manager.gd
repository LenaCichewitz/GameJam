extends Node

@export var quest_manager: Node
@export var total_actions_before_failure: int = 40
@export_custom(PROPERTY_HINT_NONE,"",PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY) 
var progress_per_quest_completion: float = 0
@export_custom(PROPERTY_HINT_NONE,"",PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY) 
var current_progress: float = 0


func _ready():
	if not quest_manager:
		return
	progress_per_quest_completion = quest_manager._get_all_quests().size() / 100
