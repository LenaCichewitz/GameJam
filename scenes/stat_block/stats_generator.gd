class_name StatsGenerator
extends RefCounted

# Hab ich so aus den stats.gd uebernommen
const RANGES := {
	"strength": Vector2(1, 10),
	"perception": Vector2(1, 10),
	"maneuverability": Vector2(1, 10),
	"stamina": Vector2(1, 10),
	"speed": Vector2(1, 10),
	"darkness": Vector2(0, 5),
	"height": Vector2(1.2, 2.2),
	"resistance": Vector2(0.0, 1.0),
}

# Zur Unterscheidung und der Generierung spaeter
const FLOAT_STATS: Array[String] = ["height", "resistance"]

# Quality ist optional und koennen wir prinzipiell durch Upgrades oder aehnliches noch anpassen
# Standard ist 0.5 und damit mittelmaß. 1 sollte peak sein, 0.1 absoluter Trash.
static func roll(quality: float = 0.5, rng: RandomNumberGenerator = null) -> Dictionary:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()

	var result := {}
	for stat_name: String in RANGES:
		var r: Vector2 = RANGES[stat_name]
		var value := _roll_value(r.x, r.y, quality, rng)
		if stat_name in FLOAT_STATS:
			result[stat_name] = snappedf(value, 0.01)
		else:
			result[stat_name] = roundi(value)
	return result

# Ausm Netz kopiert :D Wenns ne bessere Moeglichkeit gibt, gerne her damit, denn ich versteh es nicht ganz :D
# Im Netz stand, dass man "mean" und "deviation" theoretisch auch auslassen koennte, aber es dafuer
# Sorgen soll, dass die Zahl die am Ende raus kommt, "normalisierter" ist und damit allzu krasse Abweichler 
# reduziert werden.
# Koennen wir zur Not ja immer noch anpassen.
static func _roll_value(min_v: float, max_v: float, quality: float, rng: RandomNumberGenerator) -> float:
	var mean := lerpf(min_v, max_v, quality)
	var deviation := (max_v - min_v) / 4.0
	return clampf(rng.randfn(mean, deviation), min_v, max_v)
