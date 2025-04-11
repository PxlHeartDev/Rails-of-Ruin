class_name StatManager
extends Node

@export var stats: Dictionary[String, Stat]

func setStat(statName: String, val: Variant) -> void:
	if statName in stats.keys():
		stats[statName].setVal(val)
	else:
		print("Stat %s not found in %s" % [statName, get_parent()])

func getStat(statName: String) -> Variant:
	if statName in stats.keys():
		return stats[statName].getVal()
	else:
		print("Stat %s not found in %s" % [statName, get_parent()])
		return null
	
