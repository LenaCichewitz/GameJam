extends Node


@onready var game_loop: GameLoop = $GameLoop

var _game_over: bool = false
var _won: bool = false

@export var tick_interval: float = 5.0

var _time_paused: bool = false
var _game_timer: Timer
var _pending_quest_outcomes: Array[Dictionary] = []

func _ready() -> void:
	$QuestManager.final_quest_completed.connect(func(): _won = true)
	$MermaidManager.no_mermaids_left.connect(func(): _game_over = true)
	$QuestManager.reporting_quest_outcome.connect(_on_quest_outcome_reported)

	_game_timer = Timer.new()
	_game_timer.wait_time = tick_interval
	_game_timer.one_shot = false
	_game_timer.timeout.connect(_on_game_timer_timeout)
	add_child(_game_timer)
	_game_timer.start()
	
func _on_game_timer_timeout() -> void:
	if _time_paused or _game_over or _won:
		return
	print("NIN: you time is tick tick ticking away")
	_tick()
	
func _on_quest_outcome_reported(
	_quest_id: int,
	_mermaid_id: int,
	_outcome: EnumConstants.QuestCompletionState
) -> void:
	_time_paused = true
	
func start_round() -> void:
	if not game_loop.is_day() or _game_over or _won:
		return

	if not $QuestManager.has_startable_quests():
		return

	$QuestManager.start_all_quests()

	if not $QuestManager.has_active_quests():
		return

	_tick()
	_tick_until_something_to_do()

	if _game_over or _won:
		return

	game_loop.end_day()

func finish_visual_novel() -> void:
	game_loop.finish_visual_novel()

func _tick() -> void:
	$QuestManager.increment_progress()
	$MermaidManager.increment_progress()


func _has_something_to_do() -> bool:
	return $QuestManager.is_action_available() and $MermaidManager.is_action_available()


func _tick_until_something_to_do() -> void:
	var safety: int = 1000

	while not (_game_over or _won) \
	and not _has_something_to_do() \
	and $QuestManager.has_active_quests() \
	and safety > 0:
		_tick()
		safety -= 1

	print("active quest ", $QuestManager.has_active_quests())
