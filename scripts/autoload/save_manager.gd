extends Node

const SAVE_PATH := "user://savegame.json"
const TMP_PATH := "user://savegame.tmp"
const SAVE_VERSION := 1

# Brauchen wir nicht unbedingt, aber ggf. ganz sinnvoll, weil ja die Quests auf Mermaids verweisen
# So koennten wir zu Objekten linken
# TODO: "Economy" ist immer noch in Frage gestellt. Nutzen wir noch Money? Wir wollten ja eig keinen Shop.
const SAVE_ORDER: Array[String] = ["economy", "mermaids", "inventory", "quests", "shellcity"]

# Hier kann alles rein gepumpt werden, was gespeichert werden soll
var _saveables: Dictionary = {}  # key -> Node

# Alle Klassen die Speichern/Laden koennen sollen, koennen sich hiermit registrieren
func register(key: String, node: Node) -> void:
	#Pruefen ob die Klassen save und load-Method haben
	assert(node.has_method("save") and node.has_method("load_data"))
	# Falls ja, uebernehmen
	_saveables[key] = node

# Eigentliches speichern
# Diesmal dynamisch. Diese Klasse muss sich nur darauf verlassen koennen muessen, dass
# die andere Klasse, wo das Speichern getriggert werden soll, eine entsprechende Methode hat.
func save_game() -> void:
	var state := {}
	for key in _saveables:
		state[key] = _saveables[key].save()
	var data := {"version": SAVE_VERSION, "saved_at": Time.get_unix_time_from_system(), "state": state}
	var f := FileAccess.open(TMP_PATH, FileAccess.WRITE)
	if f == null:
		push_error("Save fehlgeschlagen: %s" % FileAccess.get_open_error())
		return
	f.store_string(JSON.stringify(data))
	f.close()
	DirAccess.rename_absolute(TMP_PATH, SAVE_PATH)

# Eigentliches laden
# Diesmal dynamisch. Diese Klasse muss sich nur darauf verlassen koennen muessen, dass
# die andere Klasse, wo das Laden getriggert werden soll, eine entsprechende Methode hat.
func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if typeof(data) != TYPE_DICTIONARY:
		return
	var state: Dictionary = data.get("state", {})
	for key in SAVE_ORDER:
		if _saveables.has(key) and state.has(key):
			_saveables[key].load_data(state[key])
