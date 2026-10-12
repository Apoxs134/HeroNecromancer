class_name CardData
extends Resource

enum CardType {
	ATTACK,
	SKILL,
	POWER,
	SUMMON,
	SPELL
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
@export var heal: int = 0
@export var strength_buff: int = 0
@export var apply_vulnerable: int = 0
@export var apply_weak: int = 0
@export var apply_bleed: int = 0
@export var cleanse_debuffs: bool = false
@export var thorns_buff: int = 0
@export var summon_hp: int = 0
@export var burst_damage: int = 0
@export var burst_heal: int = 0
@export var burst_block: int = 0
@export var fatal_energy_refund: int = 0
@export var fatal_draw: int = 0
@export var is_upgraded: bool = false
@export var art: Texture2D
