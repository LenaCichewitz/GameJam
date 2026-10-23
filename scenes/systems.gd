extends Node


var _game_over: bool = false
var _won: bool = false


func _ready() -> void:
	$QuestManager.final_quest_completed.connect(func(): _won = true)
	$MermaidManager.no_mermaids_left.connect(func(): _game_over = true)


func start_round() -> void:   # the future button
	if not $QuestManager.has_startable_quests():
		return
	_tick()
	$QuestManager.start_all_quests()
	_tick_until_something_to_do()


func _tick() -> void:
	$QuestManager.increment_progress()
	$MermaidManager.increment_progress()


func _has_something_to_do() -> bool:
	return $QuestManager.is_action_available() and $MermaidManager.is_action_available()


func _tick_until_something_to_do() -> void:
	var safety: int = 1000
	while not (_game_over or _won) and not _has_something_to_do() and $QuestManager.has_active_quests() and safety > 0:
		_tick()
		safety -= 1
