
extends Node

@onready var game_loop: GameLoop = $GameLoop

enum RoundState {
	READY,
	QUESTS_RUNNING,
	SHOWING_OUTCOMES,
	RESTORING_ITEMS
}

var round_state: RoundState = RoundState.READY

var _game_over: bool = false
var _won: bool = false

@export var tick_interval: float = 5.0

var _time_paused: bool = true
var _game_timer: Timer


func _ready() -> void:
	$QuestManager.final_quest_completed.connect(_on_final_quest_completed)
	$MermaidManager.no_mermaids_left.connect(_on_no_mermaids_left)
	$QuestManager.reporting_quest_outcome.connect(_on_quest_outcome_reported)

	_game_timer = Timer.new()
	_game_timer.wait_time = tick_interval
	_game_timer.one_shot = false
	_game_timer.timeout.connect(_on_game_timer_timeout)
	add_child(_game_timer)

	_game_timer.stop()
	_time_paused = true
	round_state = RoundState.READY

func start_round() -> void:
	if _game_over or _won:
		return

	if round_state != RoundState.READY \
	and round_state != RoundState.RESTORING_ITEMS:
		return

	if not $QuestManager.has_startable_quests():
		return

	_game_timer.stop()
	_time_paused = true
	round_state = RoundState.QUESTS_RUNNING

	$QuestManager.start_all_quests()

	if not $QuestManager.has_active_quests():
		round_state = RoundState.READY
		return

	_tick_until_something_to_do()

func _on_game_timer_timeout() -> void:
	if _time_paused or _game_over or _won:
		return

	if round_state != RoundState.QUESTS_RUNNING:
		return

	print("NIN: you time is tick tick ticking away")
	print("TIMER-TICK: ", Time.get_ticks_msec())
	_tick()


func _on_quest_outcome_reported(
	_quest_id: int,
	_mermaid_id: int,
	_outcome: EnumConstants.QuestCompletionState
) -> void:
	_time_paused = true
	_game_timer.stop()
	round_state = RoundState.SHOWING_OUTCOMES


func finish_quest_outcomes() -> void:
	if round_state != RoundState.SHOWING_OUTCOMES:
		return

	_time_paused = true
	_game_timer.stop()
	round_state = RoundState.RESTORING_ITEMS

	print("Ergebnisse bestätigt. Restaurierungsphase beginnt.")


func _on_final_quest_completed() -> void:
	_won = true
	_time_paused = true
	if _game_timer:
		_game_timer.stop()


func _on_no_mermaids_left() -> void:
	_game_over = true
	_time_paused = true
	if _game_timer:
		_game_timer.stop()


func _tick() -> void:
	if _game_over or _won:
		return

	$QuestManager.increment_progress()
	$MermaidManager.increment_progress()


func _has_something_to_do() -> bool:
	return (
		$QuestManager.is_action_available()
		and $MermaidManager.is_action_available()
	)

func _tick_until_something_to_do() -> void:
	var safety: int = 1000

	while not (_game_over or _won) \
	and not _has_something_to_do() \
	and $QuestManager.has_active_quests() \
	and safety > 0:
		_tick()
		safety -= 1

	print("Aktive Quests: ", $QuestManager.has_active_quests())

	if not $QuestManager.has_active_quests() \
	and round_state == RoundState.QUESTS_RUNNING:
		_time_paused = true
		_game_timer.stop()
		round_state = RoundState.READY
		

func finish_visual_novel() -> void:
	if game_loop:
		game_loop.finish_visual_novel()
