extends Node2D

signal mermaid_recruited(mermaid_id: int)
signal mermaid_busy(mermaid_id: int, busy: bool)

@export var recruit_duration := 60.0

var _sent_mermaid_id: int = -1

func _ready() -> void:
	SaveManager.register("shellcity", self)

func is_busy() -> bool:
	return _sent_mermaid_id != -1

func send_mermaid(mermaid_id: int) -> bool:
	if is_busy():
		return false
	_sent_mermaid_id = mermaid_id
	$RecruitTimer.start(recruit_duration)
	mermaid_busy.emit(mermaid_id, true)
	return true

func _on_recruit_timer_timeout() -> void:
	var mermaid_id := _sent_mermaid_id
	_sent_mermaid_id = -1
	mermaid_busy.emit(mermaid_id, false)
	mermaid_recruited.emit(mermaid_id)

func save() -> Dictionary:
	var time_left := 0.0
	if is_busy():
		time_left = $RecruitTimer.time_left
	return {"sent_mermaid_id": _sent_mermaid_id, "time_left": time_left}

func load_data(d: Dictionary) -> void:
	_sent_mermaid_id = int(d.get("sent_mermaid_id", -1))
	if not is_busy():
		$RecruitTimer.stop()
		return
	$RecruitTimer.start(maxf(float(d.get("time_left", recruit_duration)), 0.01))
