class_name CombatSimEngine
extends RefCounted

enum BotPersona {
	BALANCED,
	AGGRO,
	TURTLE,
	CHAOS
}

# --- Simulation Result Struct ---
class SimResult:
	var won: bool = false
	var turns: int = 0
	var final_player_hp: int = 0
	var max_player_hp: int = 30
	var damage_dealt_total: int = 0
	var damage_taken_total: int = 0
	var card_play_counts: Dictionary = {} # card_id -> int
	var card_dead_counts: Dictionary = {} # card_id -> int
	var log_history: Array[String] = []

# --- Combat State ---
var player_hp: int = 30
var player_max_hp: int = 30
var player_block: int = 0
var player_energy: int = 3
var max_energy: int = 3

var player_strength: int = 0
var player_thorns: int = 0
var player_afflictions: Dictionary = {
	"weak": 0,
	"frail": 0,
	"bleed": 0
}

var vanguard_active: bool = false
var vanguard_hp: int = 0
var vanguard_max_hp: int = 12
const MAX_SUMMON_SLOTS: int = 3
var active_summons: Array[Dictionary] = []

var draw_pile: Array[CardData] = []
var hand: Array[CardData] = []
var discard_pile: Array[CardData] = []

var enemies: Array[Dictionary] = []
var turn_count: int = 0
var result: SimResult = SimResult.new()
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func init_encounter(encounter: EncounterData, deck: DeckData, bot_seed: int = 0, initial_hp: int = 30, initial_max_hp: int = 30, starting_max_energy: int = 3) -> void:
	if bot_seed != 0:
		rng.seed = bot_seed
	else:
		rng.randomize()

	player_max_hp = initial_max_hp
	player_hp = mini(initial_hp, player_max_hp)
	player_block = 0
	max_energy = starting_max_energy
	player_energy = max_energy
	player_strength = 0
	player_thorns = 0
	player_afflictions = {
		"weak": 0,
		"frail": 0,
		"bleed": 0
	}
	vanguard_active = false
	vanguard_hp = 0
	active_summons.clear()
	turn_count = 0

	result = SimResult.new()
	result.max_player_hp = player_max_hp

	# Initialize Deck
	draw_pile.clear()
	hand.clear()
	discard_pile.clear()

	var source_cards: Array[CardData] = []
	if deck != null and deck.cards.size() > 0:
		source_cards = deck.cards.duplicate()
	else:
		# Fallback starter vanguard deck
		var c_pale = load("res://core/cards/data/pale_smite.tres") as CardData
		var c_ward = load("res://core/cards/data/grave_ward.tres") as CardData
		var c_vargas = load("res://core/cards/data/vargas_bulwark.tres") as CardData
		var c_kaelen = load("res://core/cards/data/kaelen_volley.tres") as CardData
		source_cards = [c_pale, c_pale, c_ward, c_ward, c_vargas, c_kaelen]

	for card in source_cards:
		if card != null:
			draw_pile.append(card)
			if not result.card_play_counts.has(card.id):
				result.card_play_counts[card.id] = 0
			if not result.card_dead_counts.has(card.id):
				result.card_dead_counts[card.id] = 0

	_shuffle_array(draw_pile)

	# Initialize Enemies
	enemies.clear()
	var enemy_names: Array = []
	if encounter != null:
		enemy_names = EncounterGenerator.get_enemies_for_encounter(encounter)
	if enemy_names.is_empty():
		enemy_names = ["Peasant Militia Scout", "Enraged Farmer"]
	for i in range(enemy_names.size()):
		var e_name = str(enemy_names[i])
		var max_hp = 14 + (i * 6)
		var dmg = 4 + (i * 2)

		# Specialized archetype stats for Act 1, 2, and 3
		if e_name.contains("Alden"):
			max_hp = 58
			dmg = 7
		elif e_name.contains("Malakor"):
			max_hp = 38
			dmg = 6
		elif e_name.contains("Golem"):
			max_hp = 32
			dmg = 6
		elif e_name.contains("Lorian") or e_name.contains("Vane"):
			max_hp = 32
			dmg = 6
		elif e_name.contains("Knight") or e_name.contains("Champion"):
			max_hp = 26
			dmg = 5
		elif e_name.contains("Captain") or e_name.contains("Boros"):
			max_hp = 34
			dmg = 6
		elif e_name.contains("Templar"):
			max_hp = 22
			dmg = 5
		elif e_name.contains("Halberdier"):
			max_hp = 20
			dmg = 5
		elif e_name.contains("Hound"):
			max_hp = 11
			dmg = 4
		elif e_name.contains("Bowman") or e_name.contains("Crossbowman") or e_name.contains("Arbalestier"):
			max_hp = 13
			dmg = 4

		enemies.append({
			"name": e_name,
			"hp": max_hp,
			"max_hp": max_hp,
			"damage": dmg,
			"base_damage": dmg,
			"block": 0,
			"afflictions": {
				"vulnerable": 0,
				"weak": 0,
				"bleed": 0
			}
		})

func _damage_enemy(target: int, dmg: int) -> int:
	if target < 0 or target >= enemies.size() or enemies[target]["hp"] <= 0:
		return 0
	var enemy = enemies[target]
	var cur_block: int = enemy.get("block", 0)
	var unblocked = maxi(0, dmg - cur_block)
	enemy["block"] = maxi(0, cur_block - dmg)
	enemy["hp"] -= unblocked

	# Enemy Thorns / Riposte recoil
	if enemy.get("thorns", 0) > 0 and dmg > 0:
		var recoil = enemy["thorns"]
		player_hp = maxi(0, player_hp - recoil)
		result.damage_taken_total += recoil
		result.log_history.append("Riposte! %s reflected %d recoil damage to Hero" % [enemy["name"], recoil])

	return unblocked

func _shuffle_array(arr: Array) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j = rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp

func draw_cards(count: int) -> void:
	for i in range(count):
		if hand.size() >= 6:
			break
		if draw_pile.is_empty():
			if discard_pile.is_empty():
				break
			draw_pile = discard_pile.duplicate()
			discard_pile.clear()
			_shuffle_array(draw_pile)
		var c = draw_pile.pop_front()
		if c != null:
			hand.append(c)

func play_card(card: CardData, target_enemy_idx: int) -> bool:
	if card == null or card.cost > player_energy:
		return false

	player_energy -= card.cost
	hand.erase(card)
	discard_pile.append(card)
	result.card_play_counts[card.id] = result.card_play_counts.get(card.id, 0) + 1

	# 1. Cleanse Debuffs
	if card.cleanse_debuffs:
		player_afflictions["weak"] = 0
		player_afflictions["frail"] = 0
		player_afflictions["bleed"] = 0
		result.log_history.append("Turn %d: Hero cleansed all debuffs!" % turn_count)

	# 2. Heal Hero
	if card.heal > 0:
		var healed = mini(card.heal, player_max_hp - player_hp)
		player_hp += healed
		result.log_history.append("Turn %d: Cast %s healing %d HP (%d/%d)" % [turn_count, card.title, healed, player_hp, player_max_hp])

	# 3. Buffs (Strength / Thorns)
	if card.strength_buff > 0:
		player_strength += card.strength_buff
		result.log_history.append("Turn %d: Hero gained +%d Strength (Total: %d)" % [turn_count, card.strength_buff, player_strength])

	if card.thorns_buff > 0:
		player_thorns += card.thorns_buff
		result.log_history.append("Turn %d: Vanguard & Hero gained +%d Thorns (Total: %d)" % [turn_count, card.thorns_buff, player_thorns])

	# 4. Block gain (applicable to Skills, Powers, or Hybrid Attacks like Grim Harvest)
	if card.block > 0:
		var blk = card.block
		if player_afflictions["frail"] > 0:
			blk = maxi(1, int(blk * 0.65))
		player_block += blk
		result.log_history.append("Turn %d: Cast %s gaining %d block" % [turn_count, card.title, blk])

	# 5. Unique Chaos Cards (High Upside / Real Downside)
	if card.id == "forbidden_rite":
		player_hp = maxi(1, player_hp - 3)
		player_energy = mini(max_energy + 2, player_energy + 2)
		draw_cards(2)
		result.log_history.append("Turn %d: Forbidden Rite! Sacrificed 3 HP for +2 Energy and 2 Cards (HP: %d)" % [turn_count, player_hp])

	elif card.id == "soul_roulette":
		var roll = rng.randi_range(1, 3)
		match roll:
			1:
				var blk = 14
				if player_afflictions["frail"] > 0:
					blk = maxi(1, int(blk * 0.65))
				player_block += blk
				var healed = mini(4, player_max_hp - player_hp)
				player_hp += healed
				result.log_history.append("Turn %d: Soul Roulette JACKPOT! Gained %d Block and healed %d HP." % [turn_count, blk, healed])
			2:
				var r_target = get_lowest_hp_alive_enemy()
				if r_target != -1:
					var dmg = 14 + player_strength
					if enemies[r_target]["afflictions"]["vulnerable"] > 0:
						dmg = int(dmg * 1.5)
					enemies[r_target]["afflictions"]["vulnerable"] += 1
					var dealt = _damage_enemy(r_target, dmg)
					result.damage_dealt_total += dealt
					result.log_history.append("Turn %d: Soul Roulette STRIKE! Dealt %d damage to %s" % [turn_count, dealt, enemies[r_target]["name"]])
			3:
				for e in enemies:
					if e["hp"] > 0:
						e["afflictions"]["weak"] += 2
				player_afflictions["bleed"] += 2
				result.log_history.append("Turn %d: Soul Roulette CURSE! All foes Weak, but Hero suffers 2 Bleed." % turn_count)

	match card.card_type:
		CardData.CardType.SUMMON:
			var existing_idx: int = -1
			for i in range(active_summons.size()):
				var check_id = card.summon_id if not card.summon_id.is_empty() else card.id
				if active_summons[i].get("id") == check_id or active_summons[i].get("card_id") == card.id:
					existing_idx = i
					break
			if existing_idx != -1:
				var s = active_summons[existing_idx]
				var bd = card.burst_damage if card.burst_damage > 0 else (16 if s["id"].contains("kaelen") else (22 if s["id"].contains("boros") else (10 if s["id"].contains("vargas") else 0)))
				var bh = card.burst_heal if card.burst_heal > 0 else (12 if s["id"].contains("lyra") else 0)
				var bb = card.burst_block if card.burst_block > 0 else (15 if s["id"].contains("lyra") else (18 if s["id"].contains("vargas") else 0))
				if bd > 0:
					for e in enemies:
						if e["hp"] > 0:
							e["hp"] -= bd
							result.damage_dealt_total += bd
				if bh > 0:
					player_hp = mini(player_max_hp, player_hp + bh)
				if bb > 0:
					player_block += bb
				if s.get("id", "") == "vargas_spirit":
					vanguard_active = false
				active_summons.remove_at(existing_idx)
				result.log_history.append("Turn %d: Burst Detonation of %s!" % [turn_count, s["name"]])
			elif active_summons.size() < MAX_SUMMON_SLOTS:
				var sid = card.summon_id if not card.summon_id.is_empty() else card.id
				var c_name = "Vargas" if sid.contains("vargas") else ("Kaelen" if sid.contains("kaelen") else ("Lyra" if sid.contains("lyra") else ("Boros" if sid.contains("boros") else ("Malakor" if sid.contains("malakor") else card.title))))
				var c_hp = card.summon_hp if card.summon_hp > 0 else (12 if sid.contains("vargas") else (16 if sid.contains("boros") else (14 if sid.contains("malakor") else 0)))
				var is_taunt = c_hp > 0 and (sid.contains("vargas") or sid.contains("boros"))
				active_summons.append({
					"id": sid,
					"card_id": card.id,
					"name": c_name,
					"card_data": card,
					"hp": c_hp,
					"max_hp": c_hp,
					"has_taunt": is_taunt
				})
				if sid.contains("vargas"):
					vanguard_active = true
					vanguard_hp = c_hp
					vanguard_max_hp = c_hp
				if card.block > 0:
					player_block += card.block
				result.log_history.append("Turn %d: Summoned %s" % [turn_count, c_name])

		CardData.CardType.ATTACK, CardData.CardType.SPELL:
			if card.id == "charnel_sacrifice":
				if active_summons.size() > 0:
					var sacrificed = active_summons[0]
					var bd = sacrificed["card_data"].burst_damage if sacrificed["card_data"].burst_damage > 0 else 16
					var bh = sacrificed["card_data"].burst_heal if sacrificed["card_data"].burst_heal > 0 else (12 if sacrificed["id"].contains("lyra") else 0)
					var bb = sacrificed["card_data"].burst_block if sacrificed["card_data"].burst_block > 0 else (18 if sacrificed["id"].contains("vargas") else 0)
					if bd > 0:
						for e in enemies:
							if e["hp"] > 0:
								e["hp"] -= bd
								result.damage_dealt_total += bd
					if bh > 0:
						player_hp = mini(player_max_hp, player_hp + bh)
					if bb > 0:
						player_block += bb
					if sacrificed.get("id", "") == "vargas_spirit":
						vanguard_active = false
					active_summons.remove_at(0)
					player_energy = mini(max_energy + 2, player_energy + 2)
					draw_cards(2)
					result.log_history.append("Turn %d: Charnel Sacrifice consumed %s!" % [turn_count, sacrificed["name"]])

			var target = target_enemy_idx
			if target < 0 or target >= enemies.size() or enemies[target]["hp"] <= 0:
				target = get_first_alive_enemy()

			if target != -1:
				var dmg = card.damage if card.damage > 0 else (6 if card.card_type == CardData.CardType.ATTACK else 0)
				if card.id == "kaelen_volley":
					dmg = 8 # 4x2

				# Add Strength
				if dmg > 0:
					dmg += player_strength

				# Check Player Weak
				if player_afflictions["weak"] > 0 and dmg > 0:
					dmg = maxi(1, int(dmg * 0.75))

				# Check Enemy Vulnerable
				if target < enemies.size() and enemies[target]["afflictions"]["vulnerable"] > 0 and dmg > 0:
					dmg = int(dmg * 1.5)

				# Apply Debuffs to Target
				if card.apply_vulnerable > 0 and target < enemies.size():
					enemies[target]["afflictions"]["vulnerable"] += card.apply_vulnerable
				if card.apply_weak > 0 and target < enemies.size():
					enemies[target]["afflictions"]["weak"] += card.apply_weak
				if card.apply_bleed > 0 and target < enemies.size():
					enemies[target]["afflictions"]["bleed"] += card.apply_bleed

				if dmg > 0:
					var dealt = _damage_enemy(target, dmg)
					result.damage_dealt_total += dealt
					result.log_history.append("Turn %d: Cast %s dealing %d damage to %s" % [turn_count, card.title, dealt, enemies[target]["name"]])
					if enemies[target]["hp"] <= 0:
						if card.fatal_energy_refund > 0:
							player_energy = mini(max_energy + 2, player_energy + card.fatal_energy_refund)
							result.log_history.append("Turn %d: Fatal kill! Refunded %d energy." % [turn_count, card.fatal_energy_refund])
						if card.fatal_draw > 0:
							draw_cards(card.fatal_draw)
							result.log_history.append("Turn %d: Fatal kill! Drew %d card." % [turn_count, card.fatal_draw])
				else:
					result.log_history.append("Turn %d: Cast %s on %s" % [turn_count, card.title, enemies[target]["name"]])
			else:
				result.log_history.append("Turn %d: Cast %s into empty field" % [turn_count, card.title])

		CardData.CardType.SKILL, CardData.CardType.POWER:
			if card.id == "vargas_bulwark":
				vanguard_active = true
				vanguard_hp = vanguard_max_hp

			# Handle AOE or Skill debuffs (e.g. Sanguine Curse)
			if card.apply_bleed > 0 or card.apply_weak > 0 or card.apply_vulnerable > 0:
				for e in enemies:
					if e["hp"] > 0:
						if card.apply_bleed > 0:
							e["afflictions"]["bleed"] += card.apply_bleed
						if card.apply_weak > 0:
							e["afflictions"]["weak"] += card.apply_weak
						if card.apply_vulnerable > 0:
							e["afflictions"]["vulnerable"] += card.apply_vulnerable

	return true

func get_first_alive_enemy() -> int:
	for i in range(enemies.size()):
		if enemies[i]["hp"] > 0:
			return i
	return -1

func get_lowest_hp_alive_enemy() -> int:
	var lowest_hp = 9999
	var lowest_idx = -1
	for i in range(enemies.size()):
		if enemies[i]["hp"] > 0 and enemies[i]["hp"] < lowest_hp:
			lowest_hp = enemies[i]["hp"]
			lowest_idx = i
	return lowest_idx

func is_all_enemies_defeated() -> bool:
	for e in enemies:
		if e["hp"] > 0:
			return false
	return true

func execute_enemy_phase() -> void:
	# 1. Process Enemy Bleed ticks
	for enemy in enemies:
		if enemy["hp"] <= 0:
			continue
		if enemy["afflictions"]["bleed"] > 0:
			var b_dmg = enemy["afflictions"]["bleed"]
			enemy["hp"] -= b_dmg
			result.damage_dealt_total += b_dmg
			enemy["afflictions"]["bleed"] -= 1
			result.log_history.append("%s bled for %d damage!" % [enemy["name"], b_dmg])

	# Companion turn triggers (Kaelen snipe, Lyra benediction, Boros cleave)
	for s in active_summons:
		var sid: String = s.get("id", "").to_lower()
		if sid.contains("kaelen"):
			var target = get_first_alive_enemy()
			if target != -1:
				var kd = 4
				if enemies[target]["afflictions"]["vulnerable"] > 0:
					kd = int(kd * 1.5)
				var dealt = _damage_enemy(target, kd)
				result.damage_dealt_total += dealt
				result.log_history.append("Turn %d: Kaelen sniped for %d damage!" % [turn_count, dealt])
		elif sid.contains("lyra"):
			player_block += 2
			player_hp = mini(player_max_hp, player_hp + 1)
			result.log_history.append("Turn %d: Lyra granted +2 Block, +1 HP" % turn_count)
		elif sid.contains("boros"):
			for e_idx in range(enemies.size()):
				if enemies[e_idx]["hp"] > 0:
					var dealt = _damage_enemy(e_idx, 4)
					result.damage_dealt_total += dealt
			result.log_history.append("Turn %d: Boros cleaved for 4 AOE damage" % turn_count)
		elif sid.contains("malakor"):
			for e in enemies:
				if e["hp"] > 0:
					e["afflictions"]["bleed"] = e["afflictions"].get("bleed", 0) + 3
			result.log_history.append("Turn %d: Malakor branded all enemies with 3 Sun-Flame" % turn_count)

	# 2. Reset Enemy Block, Thorns & Evaluate Full Intent Taxonomy
	for e in enemies:
		e["block"] = 0
		e["thorns"] = 0

	for e_idx in range(enemies.size()):
		var enemy = enemies[e_idx]
		if enemy["hp"] <= 0:
			continue

		var e_name: String = enemy["name"]
		var incoming_dmg = enemy["damage"]
		var bypass_vanguard = false
		var cleave_damage = 0

		# Full Varied Intent Evaluation:
		if e_name.contains("Golem"):
			# Construct Archetype: Cataclysm Beam Charge
			if turn_count % 3 == 1:
				incoming_dmg = 0
				result.log_history.append("⏳ %s channels Solar Core (Cataclysm Charge)!" % e_name)
			elif turn_count % 3 == 2:
				incoming_dmg = 14
				bypass_vanguard = true
				result.log_history.append("💥 %s fires Cataclysm Beam for 14 direct damage!" % e_name)
			else:
				enemy["block"] = 12
				incoming_dmg = 0
				result.log_history.append("%s vents coolant (+12 Block)!" % e_name)
		elif e_name.contains("Maiden") or e_name.contains("Knight"):
			# Armored Duelist / Iron Fortress: Riposte Counter Stance
			if (turn_count + e_idx) % 3 == 1:
				enemy["block"] = 10
				enemy["thorns"] = 4
				incoming_dmg = 0
				result.log_history.append("⚔️🛡️ %s takes Riposte Stance (+10 Block, 4 Thorns)!" % e_name)
			elif (turn_count + e_idx) % 3 == 2:
				incoming_dmg = enemy["damage"] + 2
				result.log_history.append("%s executes Heavy Thrust (%d dmg)!" % [e_name, incoming_dmg])
			else:
				for ally in enemies:
					if ally != enemy and ally["hp"] > 0:
						ally["block"] = ally.get("block", 0) + 5
				incoming_dmg = 0
				result.log_history.append("%s guards squad (+5 Block to allies)!" % e_name)
		elif e_name.contains("Halberdier") or e_name.contains("Vanguard"):
			# Polearm Frontline: Alternates Phalanx Block and Cleaving Sweep
			if (turn_count + e_idx) % 2 == 1:
				enemy["block"] = 8
				incoming_dmg = 0
				result.log_history.append("%s locks shields (+8 Block)!" % e_name)
			else:
				incoming_dmg = enemy["damage"]
				cleave_damage = 4
				result.log_history.append("%s sweeps Halberd (%d dmg + 4 Cleave)!" % [e_name, incoming_dmg])
		elif e_name.contains("Arbalestier") or e_name.contains("Crossbowman") or e_name.contains("Bowman"):
			# Marksman: Alternates Piercing Shot (ignores summons) and Aim/Cover
			if (turn_count + e_idx) % 2 == 1:
				incoming_dmg = enemy["damage"] + 2
				bypass_vanguard = true
				player_afflictions["weak"] = maxi(player_afflictions["weak"], 1)
				result.log_history.append("🏹 %s fires Piercing Bolt (%d dmg, bypasses summons)!" % [e_name, incoming_dmg])
			else:
				enemy["block"] = 5
				incoming_dmg = 0
				result.log_history.append("%s reloads from cover (+5 Block)!" % e_name)
		elif e_name.contains("Hound"):
			# Beast / Skirmisher: Howl (Frail) -> Savage Bite (Bleed) -> Prowl
			if (turn_count + e_idx) % 3 == 1:
				player_afflictions["frail"] = maxi(player_afflictions["frail"], 2)
				incoming_dmg = 0
				result.log_history.append("🐺 %s bellows a terrifying Howl (Hero is Frail)!" % e_name)
			elif (turn_count + e_idx) % 3 == 2:
				incoming_dmg = enemy["damage"]
				player_afflictions["bleed"] = maxi(player_afflictions["bleed"], 2)
				result.log_history.append("%s tears flesh (%d dmg + 2 Bleed)!" % [e_name, incoming_dmg])
			else:
				incoming_dmg = 0
				result.log_history.append("%s prowls cautiously (Resting)!" % e_name)
		elif (e_name.contains("Captain") or e_name.contains("Boros") or e_name.contains("Vane") or e_name.contains("Lorian")) and not e_name.contains("Alden"):
			# Commander: Rally (+2 Dmg) -> Command Strike -> Phalanx Horn
			if turn_count % 3 == 1:
				for ally in enemies:
					if ally != enemy and ally["hp"] > 0:
						ally["damage"] += 2
				incoming_dmg = 0
				result.log_history.append("🎺 %s sounds Rallying Warhorn (+2 Dmg to squad)!" % e_name)
			elif turn_count % 3 == 2:
				incoming_dmg = enemy["damage"] + 2
				cleave_damage = 3
			else:
				for ally in enemies:
					if ally["hp"] > 0:
						ally["block"] = ally.get("block", 0) + 6
				incoming_dmg = 0
				result.log_history.append("🛡️ %s orders Phalanx Formation (+6 Block to squad)!" % e_name)

		# Enrage scaling & Boss Mechanics
		if e_name.contains("Alden"):
			# Final Boss: Royal enrage (+1 dmg turns 1-8, +2 dmg beyond turn 8)
			if turn_count > 8:
				enemy["damage"] += 2
				result.log_history.append("%s GOES BERSERK! Royal wrath surges damage to %d!" % [e_name, enemy["damage"]])
			else:
				enemy["damage"] += 1
				result.log_history.append("%s ENRAGES! Royal fury increases damage to %d." % [e_name, enemy["damage"]])
			if turn_count % 3 == 0:
				player_afflictions["frail"] = maxi(player_afflictions["frail"], 2)
				cleave_damage = 3
				# Royal Banishment: Banishes 1 active summon
				if active_summons.size() > 0:
					var purged = active_summons.pop_front()
					if purged.get("id", "") == "vargas_spirit":
						vanguard_active = false
					result.log_history.append("%s commands Royal Banishment! Dispels %s." % [e_name, purged["name"]])

			# Anti-Turtle: Royal Shield-Shatter punctures 20% of block if player stacks 16+ Block
			if player_block >= 16:
				var puncture = int(player_block * 0.20)
				player_block -= puncture
				player_hp = maxi(0, player_hp - puncture)
				result.damage_taken_total += puncture
				result.log_history.append("%s's Royal Blade punctures the Hero's guard! %d shield shattered into direct damage." % [e_name, puncture])
		elif e_name.contains("Malakor"):
			# Act 2 Boss: Sun-Flame burn (2 Bleed on Hero) every 3 turns, Warcry every 4 turns
			if turn_count % 3 == 0:
				player_afflictions["bleed"] = maxi(player_afflictions["bleed"], 2)
				result.log_history.append("%s brands the Hero with Sun-Flame (2 Bleed)!" % e_name)
				
				# Holy Purge: Dispel 50% block and banish 1 summon
				if player_block > 8:
					var dispelled = int(player_block * 0.5)
					player_block -= dispelled
					result.log_history.append("%s casts Holy Purge! Disperses %d block." % [e_name, dispelled])
				if active_summons.size() > 0:
					var purged = active_summons.pop_front()
					if purged.get("id", "") == "vargas_spirit":
						vanguard_active = false
					result.log_history.append("%s casts Holy Purge! Banishes %s from the battlefield." % [e_name, purged["name"]])
			if turn_count % 4 == 0:
				player_afflictions["weak"] = maxi(player_afflictions["weak"], 2)
		elif e_name.contains("Captain") or e_name.contains("Boros"):
			if turn_count % 2 == 0:
				enemy["damage"] += 1
				result.log_history.append("%s ENRAGES! Damage increased to %d." % [e_name, enemy["damage"]])
			if turn_count % 3 == 0:
				player_afflictions["frail"] = maxi(player_afflictions["frail"], 2)
				result.log_history.append("%s roars a battle cry! Hero is Frail (Block -35%%)!" % e_name)

		if enemy["afflictions"]["weak"] > 0 and incoming_dmg > 0:
			incoming_dmg = maxi(1, int(incoming_dmg * 0.75))

		# Enemy Archetype Tricks:
		if incoming_dmg > 0:
			if e_name.contains("Hound"):
				# Multi-bite attack: inflicts Bleed on Hero
				player_afflictions["bleed"] = maxi(player_afflictions["bleed"], 2)
			elif e_name.contains("Halberdier"):
				# Cleave through Vanguard: deals 3 unblockable damage to Hero
				cleave_damage = 3
				player_afflictions["frail"] = maxi(player_afflictions["frail"], 1)
			elif e_name.contains("Bowman"):
				# 50% piercing shot ignores vanguard taunt, inflicts Weak
				if rng.randf() < 0.5:
					bypass_vanguard = true
				player_afflictions["weak"] = maxi(player_afflictions["weak"], 1)
			elif e_name.contains("Templar"):
				player_afflictions["frail"] = maxi(player_afflictions["frail"], 2)

		# Check for active Taunt summon (Vargas, Boros, etc.)
		var taunt_target: Dictionary = {}
		var taunt_idx: int = -1
		for i in range(active_summons.size()):
			if active_summons[i].get("has_taunt", false) and active_summons[i].get("hp", 0) > 0:
				taunt_target = active_summons[i]
				taunt_idx = i
				break

		# Apply Vanguard / Taunt or direct Hero damage
		if incoming_dmg > 0:
			if not taunt_target.is_empty() and not bypass_vanguard:
				taunt_target["hp"] -= incoming_dmg
				result.damage_taken_total += incoming_dmg
				if taunt_target["hp"] <= 0:
					result.log_history.append("%s has fallen!" % taunt_target["name"])
					if taunt_target.get("id", "") == "vargas_spirit":
						vanguard_active = false
					active_summons.remove_at(taunt_idx)
			elif vanguard_active and not bypass_vanguard:
				vanguard_hp -= incoming_dmg
				result.damage_taken_total += incoming_dmg
				if vanguard_hp <= 0:
					vanguard_active = false
					result.log_history.append("Vanguard has fallen!")

				# Cleave damage from halberdiers
				if cleave_damage > 0:
					var unblocked_cleave = maxi(0, cleave_damage - player_block)
					player_block = maxi(0, player_block - cleave_damage)
					player_hp = maxi(0, player_hp - unblocked_cleave)
					result.damage_taken_total += unblocked_cleave
			else:
				var unblocked_dmg = maxi(0, incoming_dmg - player_block)
				player_block = maxi(0, player_block - incoming_dmg)
				player_hp = maxi(0, player_hp - unblocked_dmg)
				result.damage_taken_total += unblocked_dmg

		# Thorns counter-attack:
		if player_thorns > 0 and incoming_dmg > 0:
			var dealt = _damage_enemy(e_idx, player_thorns)
			result.damage_dealt_total += dealt
			result.log_history.append("Thorns reflected %d damage to %s" % [dealt, e_name])

		# Tick enemy afflictions (vulnerable, weak)
		if enemy["afflictions"]["vulnerable"] > 0:
			enemy["afflictions"]["vulnerable"] -= 1
		if enemy["afflictions"]["weak"] > 0:
			enemy["afflictions"]["weak"] -= 1

	# 3. Hero Bleed tick & affliction decay
	if player_afflictions["bleed"] > 0:
		var hero_bleed = player_afflictions["bleed"]
		player_hp = maxi(0, player_hp - hero_bleed)
		result.damage_taken_total += hero_bleed
		player_afflictions["bleed"] -= 1
		result.log_history.append("Hero suffered %d Bleed damage!" % hero_bleed)

	if player_afflictions["weak"] > 0:
		player_afflictions["weak"] -= 1
	if player_afflictions["frail"] > 0:
		player_afflictions["frail"] -= 1

	# Decay temporary hero strength
	if player_strength > 0:
		player_strength = maxi(0, player_strength - 1)

func step_bot_turn(persona: BotPersona) -> void:
	var max_actions = 15
	while max_actions > 0:
		max_actions -= 1
		if is_all_enemies_defeated() or player_hp <= 0:
			break

		var playable_cards: Array[CardData] = []
		for c in hand:
			if c.cost <= player_energy:
				playable_cards.append(c)

		if playable_cards.is_empty():
			break

		var chosen_card: CardData = null
		var chosen_target: int = get_lowest_hp_alive_enemy()

		# Strategic High-Priority Triggers:
		# 1. If debuffed, prioritize Cleanse
		if player_afflictions["weak"] > 0 or player_afflictions["frail"] > 0 or player_afflictions["bleed"] > 0:
			for c in playable_cards:
				if c.cleanse_debuffs:
					chosen_card = c
					break

		# 2. If low HP (<= 20), prioritize Dark Harvest (heal)
		if chosen_card == null and player_hp <= 20:
			for c in playable_cards:
				if c.heal > 0:
					chosen_card = c
					break

		# 3. If Soul Surge in hand, activate strength buff before attacks
		if chosen_card == null:
			for c in playable_cards:
				if c.strength_buff > 0 and player_strength == 0:
					chosen_card = c
					break

		# 4. If Sanguine Curse or Wither Touch on fresh turn, debuff enemies
		if chosen_card == null and turn_count <= 2:
			for c in playable_cards:
				if c.id == "sanguine_curse" or c.id == "wither_touch":
					chosen_card = c
					break

		if chosen_card == null:
			match persona:
				BotPersona.AGGRO:
					var target_hp = enemies[chosen_target]["hp"] if chosen_target != -1 and chosen_target < enemies.size() else 99
					playable_cards.sort_custom(func(a, b):
						# Prioritize lethal fatal refund card to extend turn tempo
						var a_fatal = a.fatal_energy_refund > 0 and a.damage >= target_hp
						var b_fatal = b.fatal_energy_refund > 0 and b.damage >= target_hp
						if a_fatal and not b_fatal:
							return true
						if b_fatal and not a_fatal:
							return false
						# Prioritize Kaelen summon early for sustained turn damage
						var a_kaelen = a.id.contains("kaelen") and active_summons.size() < MAX_SUMMON_SLOTS
						var b_kaelen = b.id.contains("kaelen") and active_summons.size() < MAX_SUMMON_SLOTS
						if a_kaelen and not b_kaelen:
							return true
						if b_kaelen and not a_kaelen:
							return false
						var a_is_offense = (a.card_type == CardData.CardType.ATTACK or a.card_type == CardData.CardType.SPELL) and a.damage > 0
						var b_is_offense = (b.card_type == CardData.CardType.ATTACK or b.card_type == CardData.CardType.SPELL) and b.damage > 0
						if a_is_offense and not b_is_offense:
							return true
						if b_is_offense and not a_is_offense:
							return false
						return a.damage > b.damage
					)
					chosen_card = playable_cards[0]

				BotPersona.TURTLE:
					playable_cards.sort_custom(func(a, b):
						if active_summons.size() < MAX_SUMMON_SLOTS and (a.card_type == CardData.CardType.SUMMON or a.id == "vargas_bulwark"):
							return true
						if a.block > b.block:
							return true
						return false
					)
					chosen_card = playable_cards[0]

				BotPersona.BALANCED:
					var total_incoming = 0
					for e in enemies:
						if e["hp"] > 0:
							total_incoming += e["damage"]

					if active_summons.size() < MAX_SUMMON_SLOTS:
						for c in playable_cards:
							if c.card_type == CardData.CardType.SUMMON or c.id == "vargas_bulwark":
								chosen_card = c
								break

					if chosen_card == null and total_incoming > player_block:
						for c in playable_cards:
							if c.block > 0:
								chosen_card = c
								break

					if chosen_card == null:
						for c in playable_cards:
							if c.card_type == CardData.CardType.ATTACK or c.card_type == CardData.CardType.SPELL:
								chosen_card = c
								break

					if chosen_card == null:
						chosen_card = playable_cards[0]

				BotPersona.CHAOS:
					chosen_card = playable_cards[rng.randi_range(0, playable_cards.size() - 1)]

		if chosen_card != null:
			play_card(chosen_card, chosen_target)
		else:
			break

func run_full_simulation(persona: BotPersona = BotPersona.BALANCED, max_turns: int = 50) -> SimResult:
	turn_count = 0

	while turn_count < max_turns:
		turn_count += 1
		player_energy = max_energy
		player_block = 0
		draw_cards(5 - hand.size())

		step_bot_turn(persona)

		# Log dead cards left unplayed in hand at end of turn
		for dead_card in hand:
			result.card_dead_counts[dead_card.id] = result.card_dead_counts.get(dead_card.id, 0) + 1

		if is_all_enemies_defeated():
			result.won = true
			break

		execute_enemy_phase()

		if player_hp <= 0:
			result.won = false
			break

	result.turns = turn_count
	result.final_player_hp = player_hp
	return result
