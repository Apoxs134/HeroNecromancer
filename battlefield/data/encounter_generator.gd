class_name EncounterGenerator
extends RefCounted

## Procedural Encounter Squad Generator
## Assembles balanced, chapter-constrained, non-boss enemy compositions.

static func get_enemies_for_encounter(encounter: EncounterData, chapter_key: String = "") -> Array[String]:
	if encounter == null:
		if chapter_key == "chapter_2" or chapter_key == "ch2":
			return generate_squad(2, false)
		elif chapter_key == "chapter_3" or chapter_key == "ch3":
			return generate_squad(3, false)
		return ["Peasant Militia Scout", "Enraged Farmer"]

	var enc_id = encounter.id.to_lower()
	var diff = encounter.difficulty.to_lower()

	# 1. Boss and Tutorial encounters are strictly preserved
	if diff == "boss" or enc_id.contains("boss") or diff == "tutorial" or enc_id.contains("tutorial"):
		var list: Array[String] = []
		for e in encounter.enemies:
			list.append(str(e))
		return list

	# 2. Determine chapter constraint
	var ch = 1
	if enc_id.begins_with("ch2") or chapter_key == "chapter_2":
		ch = 2
	elif enc_id.begins_with("ch3") or chapter_key == "chapter_3":
		ch = 3

	var is_elite = diff == "elite" or enc_id.contains("elite")
	return generate_squad(ch, is_elite)

static func generate_squad(chapter: int, is_elite: bool) -> Array[String]:
	var squad: Array[String] = []

	match chapter:
		1:
			# Chapter 1: 2-3 enemies for normal, 3 for elite
			if is_elite:
				var frontline_pool = ["Militia Vanguard", "Zealot Templar"]
				var skirmish_pool = ["Holy Warhound", "Armed Townsperson"]
				var ranged_pool = ["Pyre Crossbowman", "Peasant Militia Scout"]
				squad.append(frontline_pool.pick_random())
				squad.append(skirmish_pool.pick_random())
				squad.append(ranged_pool.pick_random())
			else:
				var count = 3 if randf() > 0.4 else 2
				var pool = [
					"Peasant Militia Scout",
					"Enraged Farmer",
					"Armed Townsperson",
					"Militia Vanguard",
					"Hound of Oakhaven"
				]
				# Guaranteed at least 1 frontline/militia
				squad.append(["Militia Vanguard", "Armed Townsperson", "Enraged Farmer"].pick_random())
				while squad.size() < count:
					var pick = pool.pick_random()
					# Avoid more than 1 hound
					if pick == "Hound of Oakhaven" and squad.has("Hound of Oakhaven"):
						pick = "Peasant Militia Scout"
					squad.append(pick)

		2:
			# Chapter 2: 3-4 enemies for normal, 4 for elite
			if is_elite:
				var leader_pool = ["Grand Judiciar Vane", "Sanctified Golem"]
				var frontline_pool = ["Iron Maiden Vanguard", "Templar Halberdier"]
				var skirmish_pool = ["Purifying Templars", "Sun-Oath Executioners"]
				var backline_pool = ["Inquisition Crossbowman", "Hounds of Mourning"]
				squad.append(leader_pool.pick_random())
				squad.append(frontline_pool.pick_random())
				squad.append(skirmish_pool.pick_random())
				squad.append(backline_pool.pick_random())
			else:
				var count = 4 if randf() > 0.45 else 3
				var pool = [
					"Templar Halberdier",
					"Inquisition Crossbowman",
					"Hounds of Mourning",
					"Purifying Templars",
					"Iron Maiden Vanguard"
				]
				squad.append(["Iron Maiden Vanguard", "Templar Halberdier"].pick_random())
				squad.append(["Purifying Templars", "Inquisition Crossbowman"].pick_random())
				while squad.size() < count:
					squad.append(pool.pick_random())

		3:
			# Chapter 3: 4 enemies for both normal and elite
			if is_elite:
				var leader_pool = ["Captain Lorian of the Guard", "Grand Justiciar Golem"]
				var frontline_pool = ["Palace Gilded Knight", "Grand Justiciar Golem"]
				var skirmish_pool = ["Golden Templar Champion", "Citadel Halberdier"]
				var ranged_pool = ["Royal Arbalestier"]
				squad.append(leader_pool.pick_random())
				squad.append(frontline_pool.pick_random())
				squad.append(skirmish_pool.pick_random())
				squad.append(ranged_pool.pick_random())
			else:
				var pool = [
					"Citadel Halberdier",
					"Royal Arbalestier",
					"Palace Gilded Knight",
					"Golden Templar Champion"
				]
				squad.append(["Palace Gilded Knight", "Citadel Halberdier"].pick_random())
				squad.append(["Golden Templar Champion", "Citadel Halberdier"].pick_random())
				squad.append("Royal Arbalestier")
				squad.append(pool.pick_random())

	return squad
