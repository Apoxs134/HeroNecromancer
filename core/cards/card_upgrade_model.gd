class_name CardUpgradeModel
extends RefCounted

## Manages Card Sacrifice, Transmutation, and Upgrades.

const MIN_DECK_SIZE: int = 10

## Checks if a card can be upgraded (not already upgraded).
static func can_upgrade(card: CardData) -> bool:
	if card == null:
		return false
	return not card.is_upgraded

## Checks if the deck has surplus cards that can be sacrificed.
static func can_sacrifice(deck: DeckData, min_limit: int = MIN_DECK_SIZE) -> bool:
	if deck == null:
		return false
	return deck.cards.size() > min_limit

## Creates an upgraded duplicate of a card with enhanced values.
static func upgrade_card(base: CardData) -> CardData:
	if base == null:
		return null
	if base.is_upgraded:
		return base
		
	var upgraded: CardData = base.duplicate() as CardData
	upgraded.id = base.id + "_plus"
	upgraded.title = base.title + "+"
	upgraded.is_upgraded = true
	
	if upgraded.damage > 0:
		upgraded.damage += 3
	if upgraded.block > 0:
		upgraded.block += 3
	if upgraded.heal > 0:
		upgraded.heal += 2
	if upgraded.strength_buff > 0:
		upgraded.strength_buff += 1
	if upgraded.thorns_buff > 0:
		upgraded.thorns_buff += 1
	if upgraded.apply_vulnerable > 0:
		upgraded.apply_vulnerable += 1
	if upgraded.apply_weak > 0:
		upgraded.apply_weak += 1
	if upgraded.apply_bleed > 0:
		upgraded.apply_bleed += 2
		
	upgraded.description = _generate_upgraded_desc(upgraded)
	return upgraded

## Removes a single card instance from the player's deck.
static func sacrifice_card(deck: DeckData, target_card: CardData) -> bool:
	if deck == null or target_card == null:
		return false
		
	var idx = deck.cards.find(target_card)
	if idx == -1:
		for i in range(deck.cards.size()):
			if deck.cards[i].id == target_card.id:
				idx = i
				break
				
	if idx != -1:
		deck.cards.remove_at(idx)
		return true
	return false

## Sacrifices one card to upgrade another in the player's deck.
static func sacrifice_and_upgrade(deck: DeckData, card_to_sac: CardData, card_to_up: CardData) -> bool:
	if deck == null or card_to_sac == null or card_to_up == null:
		return false
	if card_to_sac == card_to_up:
		return false
	if not can_upgrade(card_to_up):
		return false
		
	var up_idx = deck.cards.find(card_to_up)
	if up_idx == -1:
		for i in range(deck.cards.size()):
			if deck.cards[i].id == card_to_up.id:
				up_idx = i
				break
	if up_idx == -1:
		return false
		
	var removed = sacrifice_card(deck, card_to_sac)
	if not removed:
		return false
		
	# Find up_idx again after removal
	up_idx = deck.cards.find(card_to_up)
	if up_idx == -1:
		for i in range(deck.cards.size()):
			if deck.cards[i].id == card_to_up.id:
				up_idx = i
				break
	if up_idx != -1:
		deck.cards[up_idx] = upgrade_card(card_to_up)
		return true
	return false

## Directly upgrades a card in the player's deck.
static func upgrade_card_in_deck(deck: DeckData, target_card: CardData) -> bool:
	if deck == null or target_card == null or not can_upgrade(target_card):
		return false
		
	var idx = deck.cards.find(target_card)
	if idx == -1:
		for i in range(deck.cards.size()):
			if deck.cards[i].id == target_card.id:
				idx = i
				break
	if idx != -1:
		deck.cards[idx] = upgrade_card(target_card)
		return true
	return false

static func _generate_upgraded_desc(c: CardData) -> String:
	var parts: Array[String] = []
	if c.damage > 0:
		parts.append("Deal %d damage." % c.damage)
	if c.block > 0:
		parts.append("Gain %d Block." % c.block)
	if c.heal > 0:
		parts.append("Restore %d HP." % c.heal)
	if c.strength_buff > 0:
		parts.append("Gain +%d Strength." % c.strength_buff)
	if c.thorns_buff > 0:
		parts.append("Gain +%d Thorns." % c.thorns_buff)
	if c.cleanse_debuffs:
		parts.append("Cleanse all debuffs.")
	if c.apply_vulnerable > 0:
		parts.append("Apply %d Vulnerable." % c.apply_vulnerable)
	if c.apply_weak > 0:
		parts.append("Apply %d Weak." % c.apply_weak)
	if c.apply_bleed > 0:
		parts.append("Apply %d Bleed." % c.apply_bleed)
	if not c.summon_id.is_empty():
		parts.append("Summon: %s." % c.summon_id.capitalize())
	if c.fatal_energy_refund > 0:
		parts.append("Fatal: Refund %d Energy." % c.fatal_energy_refund)
	if c.fatal_draw > 0:
		parts.append("Fatal: Draw %d Card." % c.fatal_draw)
	if parts.is_empty():
		return c.description + " (+)"
	return " ".join(parts)
