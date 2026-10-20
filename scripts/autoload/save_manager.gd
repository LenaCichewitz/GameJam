extends Node

const SAVE_PATH := "user://savegame.json"
const TMP_PATH := "user://savegame.tmp"
const SAVE_VERSION := 1

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)  # damit wir beim Schließen speichern können
	load_game()

func save_game() -> void:
	var data := {
		"version": SAVE_VERSION,
		"saved_at": Time.get_unix_time_from_system(),
		"state": GameState.to_dict(),
	}
	# Erst Temp-Datei, danach Main-File
	var f := FileAccess.open(TMP_PATH, FileAccess.WRITE)
	if f == null:
		push_error("Save fehlgeschlagen: %s" % FileAccess.get_open_error())
		return
	f.store_string(JSON.stringify(data))
	f.close()
	DirAccess.rename_absolute(TMP_PATH, SAVE_PATH)
	
func delete_save() -> bool:
	#Save existiert nicht, also koennen wir bereits true zurueck geben
	if not FileAccess.file_exists(SAVE_PATH):
		return true
	#File  existiert, also loeschen
	DirAccess.remove_absolute(SAVE_PATH)
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var text := FileAccess.get_file_as_string(SAVE_PATH)
	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_warning("Savegame beschädigt, starte neu.")
		return false
	GameState.from_dict(data.get("state", {}))
	return true

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()
