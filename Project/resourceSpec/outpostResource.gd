class_name OutpostResource
extends Resource

enum RARITY {
	Basic,
	Common,
	Uncommon,
	Rare,
	Elusive,
	Strange,
}

@export var name: String
@export var ID: String
@export var rarity: RARITY
@export var count: int
@export var production: int

func _init(p_name = "",
		p_ID = "",
		p_rarity = RARITY.Basic,
		p_count = 0,
		p_production = 0):
	name = p_name
	ID = p_ID
	rarity = p_rarity
	count = p_count
	production = p_production
