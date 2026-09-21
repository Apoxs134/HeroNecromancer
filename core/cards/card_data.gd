class_name CardData
extends Resource

enum CardType {
	ATTACK,
	SKILL,
	POWER,
	SUMMON
}

enum TargetType {
	ENEMY_SINGLE,
	ENEMY_ALL,
	SELF,
	MINION,
	NONE
}

enum CardRarity {
	STARTER,
	COMMON,
	UNCOMMON,
	RARE
}

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
@export var cost: int = 1
@export var card_type: CardType = CardType.ATTACK
@export var target_type: TargetType = TargetType.ENEMY_SINGLE
@export var rarity: CardRarity = CardRarity.STARTER
@export var damage: int = 0
@export var block: int = 0
@export var summon_id: String = ""
