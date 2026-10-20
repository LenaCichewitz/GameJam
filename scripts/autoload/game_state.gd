extends Node

var money: int = 0 # TODO: Nutzen wir ueberhaupt noch Money, als Waehrung?
var mermaids: Array[Dictionary] = []   # z.B. {"id": 1, "name": "Marina", "level": 2}
var inventory: Array[Dictionary] = []  # z.B. {"id": "vase", "restored": 0.5}

# Speichern
func to_dict() -> Dictionary:
	return {
		"money": money,
		"mermaids": mermaids,
		"inventory": inventory,
	}

# Laden
func from_dict(d: Dictionary) -> void:
	money = d.get("money", 0)
	mermaids.assign(d.get("mermaids", []))
	inventory.assign(d.get("inventory", []))
