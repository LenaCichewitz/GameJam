extends Node

signal mermaid_recruited(stats: Stats)
signal mermaid_busy(mermaid_id: int, busy: bool)

const RECRUIT_DURATION := 60.0

var _sent_mermaid_id: int = -1
var _time_left: float = 0.0

func _ready() -> void:
	SaveManager.register("shellcity", self)

func is_busy() -> bool:
	return _sent_mermaid_id != -1

func send_mermaid(mermaid_id: int) -> bool:
	if is_busy():
		return false
	_sent_mermaid_id = mermaid_id
	_time_left = RECRUIT_DURATION
	mermaid_busy.emit(mermaid_id,true)
	return true

func _process(delta: float) -> void:
	if not is_busy():
		return
	_time_left -= delta
	if _time_left <= 0.0:
		_finish_recruitment()

func _finish_recruitment() -> void:
	var stats := StatsGenerator.roll()
	# TODO: Noch zu schaffender MermaidManager bekommt Signal busy -> false
	mermaid_busy.emit(_sent_mermaid_id,false)
	_sent_mermaid_id = -1
	# TODO: Noch zu schaffender MermaidManager bekommt Signal neue Mermaid rekrutiert
	mermaid_recruited.emit(stats)       

func save() -> Dictionary:
	return {"sent_mermaid_id": _sent_mermaid_id, "time_left": _time_left}

func load_data(d: Dictionary) -> void:
	_sent_mermaid_id = int(d.get("sent_mermaid_id", -1))
	_time_left = float(d.get("time_left", 0.0))
