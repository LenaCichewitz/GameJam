class_name GameLoop
extends Node

enum Phase {
	DAY,
	NIGHT,
}

# Fuer moegliche Uebergaenge und Ereignisse
signal phase_changed(previous_phase: Phase, new_phase: Phase)

# Am Tag X soll X passieren
signal day_started(day: int)

# Am Ende von Tag X soll X passieren
signal day_ended(day: int)

# In der Nacht vom X soll X passieren
signal night_started(day: int)

# Visual Novel fuer Tag X
signal visual_novel_requested(day: int)
signal visual_novel_finished(day: int)

@export var first_day: int = 1
@export var start_on_ready: bool = true
@export var auto_finish_visual_novel: bool = false

var current_day: int = 1
var current_phase: Phase = Phase.DAY


var _visual_novel_running: bool = false
var _started: bool = false


func _ready() -> void:
	current_day = first_day
	SaveManager.register("game_loop", self)
	if start_on_ready:
		start.call_deferred()


func start() -> void:
	if _started:
		return
	_started = true
	day_started.emit(current_day)


func is_day() -> bool:
	return current_phase == Phase.DAY


func is_night() -> bool:
	return current_phase == Phase.NIGHT


func is_visual_novel_running() -> bool:
	return _visual_novel_running


func end_day() -> void:
	if current_phase != Phase.DAY:
		return
	day_ended.emit(current_day)
	_set_phase(Phase.NIGHT)
	night_started.emit(current_day)
	request_visual_novel()


func request_visual_novel() -> void:
	if _visual_novel_running:
		return
	_visual_novel_running = true
	visual_novel_requested.emit(current_day)
	if auto_finish_visual_novel:
		finish_visual_novel.call_deferred()


func finish_visual_novel() -> void:
	if not _visual_novel_running:
		return
	_visual_novel_running = false
	visual_novel_finished.emit(current_day)
	_start_next_day()


#func skip_night() -> void:
	#if current_phase != Phase.NIGHT:
		#return
	#finish_visual_novel()


func _start_next_day() -> void:
	current_day += 1
	_set_phase(Phase.DAY)
	day_started.emit(current_day)


func _set_phase(new_phase: Phase) -> void:
	if current_phase == new_phase:
		return
	var previous_phase := current_phase
	current_phase = new_phase
	phase_changed.emit(previous_phase, new_phase)


func save() -> Dictionary:
	return {
		"current_day": current_day,
		"current_phase": int(current_phase),
		"visual_novel_running": _visual_novel_running,
	}


func load_data(data: Dictionary) -> void:
	current_day = int(data.get("current_day", first_day))
	current_phase = int(data.get("current_phase", Phase.DAY))
	_visual_novel_running = bool(data.get("visual_novel_running", false))
