extends Node

const CombatSimEngine = preload("res://core/simulation/combat_sim_engine.gd")
const CardUpgradeModel = preload("res://core/cards/card_upgrade_model.gd")

@export var default_runs: int = 100
@export var output_json_path: String = "res://core/simulation/simulation_analytics.json"

const ENCOUNTERS_CH1 = [
	"res://battlefield/data/ch1_battle_tutorial.tres",
	"res://battlefield/data/ch1_tile_battle.tres",
	"res://battlefield/data/ch1_elite_battle.tres",
	"res://battlefield/data/ch1_boss_battle.tres"
]

func _ready() -> void:
	var args = OS.get_cmdline_user_args()
	var runs = default_runs
	var bot_type_str = "all"
	var encounter_filter = "all"
	var is_crusade = false

	# Parse custom command line options e.g. --runs=100 --bot=aggro --crusade
	for arg in args:
		if arg.begins_with("--runs="):
			runs = int(arg.trim_prefix("--runs="))
		elif arg.begins_with("--bot="):
			bot_type_str = arg.trim_prefix("--bot=").to_lower()
		elif arg.begins_with("--encounter="):
			encounter_filter = arg.trim_prefix("--encounter=").to_lower()
		elif arg == "--crusade" or arg == "--campaign" or arg.begins_with("--mode=crusade"):
			is_crusade = true

	if is_crusade:
		if bot_type_str == "all":
			run_all_personas_crusade(runs)
		else:
			var bot_persona = CombatSimEngine.BotPersona.BALANCED
			match bot_type_str:
				"aggro": bot_persona = CombatSimEngine.BotPersona.AGGRO
				"turtle": bot_persona = CombatSimEngine.BotPersona.TURTLE
				"chaos": bot_persona = CombatSimEngine.BotPersona.CHAOS
				_: bot_persona = CombatSimEngine.BotPersona.BALANCED
			run_crusade_simulation(runs, bot_persona, true)
	else:
		var bot_persona = CombatSimEngine.BotPersona.BALANCED
		match bot_type_str:
			"aggro": bot_persona = CombatSimEngine.BotPersona.AGGRO
			"turtle": bot_persona = CombatSimEngine.BotPersona.TURTLE
			"chaos": bot_persona = CombatSimEngine.BotPersona.CHAOS
			_: bot_persona = CombatSimEngine.BotPersona.BALANCED
		run_balance_suite(runs, bot_persona, encounter_filter)

	get_tree().quit(0)

func run_all_personas_crusade(runs_per_persona: int) -> Dictionary:
	var profiles = [
		{"enum": CombatSimEngine.BotPersona.BALANCED, "name": "BALANCED (Casual)", "specialist": false},
		{"enum": CombatSimEngine.BotPersona.BALANCED, "name": "BALANCED (Specialist)", "specialist": true},
		{"enum": CombatSimEngine.BotPersona.AGGRO, "name": "AGGRO (Casual)", "specialist": false},
		{"enum": CombatSimEngine.BotPersona.AGGRO, "name": "AGGRO (Specialist)", "specialist": true},
		{"enum": CombatSimEngine.BotPersona.TURTLE, "name": "TURTLE (Casual)", "specialist": false},
		{"enum": CombatSimEngine.BotPersona.TURTLE, "name": "TURTLE (Specialist)", "specialist": true},
		{"enum": CombatSimEngine.BotPersona.CHAOS, "name": "CHAOS (Casual)", "specialist": false},
		{"enum": CombatSimEngine.BotPersona.CHAOS, "name": "CHAOS (Specialist)", "specialist": true}
	]

	print("\n================================================================================")
	print("       HERONECROMANCER - CASUAL VS SPECIALIST CRUSADE BALANCE SUITE")
	print("================================================================================")
	print("Testing 8 profiles (Casual vs Specialist) with %d runs each (Total: %d Crusade runs)" % [runs_per_persona, runs_per_persona * profiles.size()])
	print("Casual: Expands deck up to 19 cards, always rests (+14 HP)")
	print("Specialist: Trims deck to exactly 10 cards, upgrades key cards at Altars when safe")
	print("================================================================================\n")

	var all_results: Array[Dictionary] = []
	var suite_start_ms = Time.get_ticks_msec()

	for p in profiles:
		var res = run_crusade_simulation(runs_per_persona, p["enum"], p["specialist"], false)
		all_results.append(res)

	# Master Cross-Persona Comparison Table
	print("\n=================================================================================================================")
	print("                           MASTER CRUSADE CROSS-PROFILE COMPARISON TABLE")
	print("=================================================================================================================")
	print("%-22s | %-10s | %-12s | %-10s | %-24s | %-24s" % ["Player Profile", "Win Rate", "Avg HP (Win)", "Avg Turns", "Deadliest Stage", "Top Draft Pick (Win Rate)"])
	print("-----------------------------------------------------------------------------------------------------------------")

	var total_runs = 0
	var total_wins = 0
	var sum_avg_hp = 0.0
	var sum_turns = 0.0

	for res in all_results:
		total_runs += res["total_runs"]
		total_wins += res["completed_runs"]
		sum_avg_hp += res["avg_final_hp"]
		sum_turns += res["avg_turns"]

		# Find deadliest stage
		var max_deaths = -1
		var dead_stage_name = "None"
		for s_id in res["deaths_by_stage"].keys():
			var count = res["deaths_by_stage"][s_id]
			if count > max_deaths and count > 0:
				max_deaths = count
				dead_stage_name = "%s (%d deaths)" % [s_id.replace("ch1_", "").capitalize(), count]

		# Find top drafted card
		var top_card = "None"
		var top_draft_count = 0
		for cid in res["draft_card_stats"].keys():
			var stat = res["draft_card_stats"][cid]
			if stat["picks"] > top_draft_count:
				top_draft_count = stat["picks"]
				top_card = "%s (%.0f%%)" % [cid, stat["win_correlation"]]

		print("%-22s | %5.1f%%    | %4.1f / 30   | %4.1f turns| %-24s | %-24s" % [
			res["persona"],
			res["clear_rate"],
			res["avg_final_hp"],
			res["avg_turns"],
			dead_stage_name,
			top_card
		])

	var global_clear_rate = (float(total_wins) / float(total_runs)) * 100.0
	var global_avg_hp = sum_avg_hp / float(all_results.size())
	var global_avg_turns = sum_turns / float(all_results.size())

	print("-----------------------------------------------------------------------------------------------------------------")
	print("%-22s | %5.1f%%    | %4.1f / 30   | %4.1f turns| %-24s | Total Runs: %d" % [
		"GLOBAL COMBINED",
		global_clear_rate,
		global_avg_hp,
		global_avg_turns,
		"Overall Campaign",
		total_runs
	])
	print("=================================================================================================================\n")

	var total_time_sec = (Time.get_ticks_msec() - suite_start_ms) / 1000.0
	print("Multi-profile crusade simulation completed in %.2f seconds." % total_time_sec)

	var master_json = {
		"timestamp": Time.get_datetime_string_from_system(),
		"total_crusade_runs": total_runs,
		"global_clear_rate": global_clear_rate,
		"global_avg_hp": global_avg_hp,
		"global_avg_turns": global_avg_turns,
		"profiles": all_results
	}

	var f = FileAccess.open("res://core/simulation/simulation_analytics.json", FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(master_json, "\t"))
		f.close()
		print("Master telemetry saved to: res://core/simulation/simulation_analytics.json\n")

	return master_json

func run_crusade_simulation(runs: int, persona: CombatSimEngine.BotPersona, is_specialist: bool = false, is_verbose: bool = true) -> Dictionary:
	var persona_names = ["BALANCED", "AGGRO", "TURTLE", "CHAOS"]
	var p_name = "%s (%s)" % [persona_names[persona], "Specialist" if is_specialist else "Casual"]

	if is_verbose:
		print("\n================================================================================")
		print("       HERONECROMANCER - FULL CRUSADE PROGRESSION SIMULATOR")
		print("================================================================================")
		print("Persona: %s | Total Crusade Runs: %d | Time: %s" % [p_name, runs, Time.get_datetime_string_from_system()])
		print("Starting Deck: 10 cards (4 Starter Types: 4x Pale Smite, 4x Grave Ward, 1x Vargas, 1x Kaelen)")
		print("Rules: Node 1 -> Draft 1 of 3 -> Node 2 -> Draft -> Node 3 (Elite) -> Draft -> Boss")
		print("Rest Site: Hero heals +14 HP or Upgrades key cards at Bone Altar")
		print("--------------------------------------------------------------------------------")
	else:
		print("--> Running %s profile (%d runs)..." % [p_name, runs])

	var suite_start_ms = Time.get_ticks_msec()

	var starter_deck_res = load("res://core/cards/data/starter_vanguard_deck.tres") as DeckData

	# Draft reward pool (Spoils of war: spells only, no summon cards)
	var draft_pool: Array[CardData] = [
		load("res://core/cards/data/soul_cleanse.tres") as CardData,
		load("res://core/cards/data/soul_surge.tres") as CardData,
		load("res://core/cards/data/dark_harvest.tres") as CardData,
		load("res://core/cards/data/bone_spikes.tres") as CardData,
		load("res://core/cards/data/wither_touch.tres") as CardData,
		load("res://core/cards/data/sanguine_curse.tres") as CardData,
		load("res://core/cards/data/grim_harvest.tres") as CardData,
		load("res://core/cards/data/pale_guillotine.tres") as CardData,
		load("res://core/cards/data/soul_roulette.tres") as CardData,
		load("res://core/cards/data/forbidden_rite.tres") as CardData,
		load("res://core/cards/data/charnel_sacrifice.tres") as CardData
	]
	draft_pool = draft_pool.filter(func(c: CardData): return c != null and c.card_type != CardData.CardType.SUMMON)

	var stages = [
		{"id": "ch1_tutorial", "name": "Stage 1: [Act I] Defend Scythe", "path": "res://battlefield/data/ch1_battle_tutorial.tres"},
		{"id": "ch1_skirmish", "name": "Stage 2: [Act I] Granary Skirmish", "path": "res://battlefield/data/ch1_tile_battle.tres"},
		{"id": "ch1_elite", "name": "Stage 3: [Act I] Inquisition Patrol", "path": "res://battlefield/data/ch1_elite_battle.tres"},
		{"id": "ch1_boss", "name": "Stage 4: [Act I] Boss Captain Boros", "path": "res://battlefield/data/ch1_boss_battle.tres"},
		{"id": "ch2_skirmish", "name": "Stage 5: [Act II] Gallows Pass", "path": "res://battlefield/data/ch2_tile_battle.tres"},
		{"id": "ch2_elite", "name": "Stage 6: [Act II] Judiciar Host", "path": "res://battlefield/data/ch2_elite_battle.tres"},
		{"id": "ch2_boss", "name": "Stage 7: [Act II] Boss Malakor", "path": "res://battlefield/data/ch2_boss_battle.tres"},
		{"id": "ch3_skirmish", "name": "Stage 8: [Act III] Avenue of Kings", "path": "res://battlefield/data/ch3_tile_battle.tres"},
		{"id": "ch3_elite", "name": "Stage 9: [Act III] Royal Guard Lorian", "path": "res://battlefield/data/ch3_elite_battle.tres"},
		{"id": "ch3_boss", "name": "Stage 10: [Act III] Climax King Alden", "path": "res://battlefield/data/ch3_boss_battle.tres"}
	]

	var completed_runs = 0
	var deaths_by_stage = {
		"ch1_tutorial": 0,
		"ch1_skirmish": 0,
		"ch1_elite": 0,
		"ch1_boss": 0,
		"ch2_skirmish": 0,
		"ch2_elite": 0,
		"ch2_boss": 0,
		"ch3_skirmish": 0,
		"ch3_elite": 0,
		"ch3_boss": 0
	}
	var card_draft_counts: Dictionary = {}
	var card_win_counts: Dictionary = {}
	var total_final_hp_on_win = 0
	var total_turns_on_win = 0

	var rng = RandomNumberGenerator.new()

	for r in range(runs):
		rng.seed = r + 2026
		var run_max_hp = 30
		var run_hp = 30
		var run_alive = true
		var run_turns = 0

		# Initialize 10-card starter deck from the 4 starter types
		var run_deck = DeckData.new()
		run_deck.deck_name = "Run %d Deck" % r
		run_deck.cards = starter_deck_res.cards.duplicate()

		var drafted_in_this_run: Array[String] = []
		var run_energy = 3

		for s_idx in range(stages.size()):
			var stage = stages[s_idx]
			var enc = load(stage["path"]) as EncounterData

			# Chapter-based Max Energy scaling: Ch1 (3), Ch2 (4), Ch3 (5)
			if s_idx >= 7:
				run_energy = 5
			elif s_idx >= 4:
				run_energy = 4
			else:
				run_energy = 3

			var sim = CombatSimEngine.new()
			sim.init_encounter(enc, run_deck, r * 20 + s_idx, run_hp, run_max_hp, run_energy)

			var res = sim.run_full_simulation(persona)
			run_turns += res.turns
			run_hp = res.final_player_hp

			if not res.won or run_hp <= 0:
				run_alive = false
				deaths_by_stage[stage["id"]] += 1
				break

			# Won stage -> Rest site / Act Transition + Draft card
			if s_idx < stages.size() - 1:
				if s_idx == 3:
					# Defeated Act 1 Boss (Captain Boros) -> Grant Boros Revenant
					run_max_hp += 5
					run_hp = run_max_hp
					var boros_card = load("res://core/cards/data/boros_revenant.tres") as CardData
					if boros_card != null and not _has_card_id(run_deck, "boros_revenant"):
						run_deck.cards.append(boros_card)
				elif s_idx == 6:
					# Defeated Act 2 Boss (High Inquisitor Malakor) -> Grant Malakor Inquisitor
					run_max_hp += 5
					run_hp = run_max_hp
					var malakor_card = load("res://core/cards/data/malakor_inquisitor.tres") as CardData
					if malakor_card != null and not _has_card_id(run_deck, "malakor_inquisitor"):
						run_deck.cards.append(malakor_card)
				else:
					if is_specialist and run_hp >= int(run_max_hp * 0.55):
						_upgrade_specialist_card(run_deck, persona)
					else:
						run_hp = mini(run_max_hp, run_hp + 14) # Standard node rest heal

				# Offer 3 random cards
				var pool_copy = draft_pool.duplicate()
				for i in range(pool_copy.size() - 1, 0, -1):
					var j = rng.randi_range(0, i)
					var tmp = pool_copy[i]
					pool_copy[i] = pool_copy[j]
					pool_copy[j] = tmp

				var offerings: Array[CardData] = [pool_copy[0], pool_copy[1], pool_copy[2]]
				var chosen_card: CardData = offerings[0]

				match persona:
					CombatSimEngine.BotPersona.AGGRO:
						offerings.sort_custom(func(a, b): return (a.damage + a.strength_buff) > (b.damage + b.strength_buff))
						chosen_card = offerings[0]
					CombatSimEngine.BotPersona.TURTLE:
						offerings.sort_custom(func(a, b): return (a.block + a.thorns_buff) > (b.block + b.thorns_buff))
						chosen_card = offerings[0]
					CombatSimEngine.BotPersona.BALANCED:
						offerings.sort_custom(func(a, b):
							var score_a = (10 if a.cleanse_debuffs else 0) + (a.heal * 2) + a.strength_buff + a.block + a.damage
							var score_b = (10 if b.cleanse_debuffs else 0) + (b.heal * 2) + b.strength_buff + b.block + b.damage
							return score_a > score_b
						)
						chosen_card = offerings[0]
					CombatSimEngine.BotPersona.CHAOS:
						chosen_card = offerings[rng.randi_range(0, 2)]

				run_deck.cards.append(chosen_card)
				if is_specialist:
					_trim_specialist_deck(run_deck, persona)
				card_draft_counts[chosen_card.id] = card_draft_counts.get(chosen_card.id, 0) + 1
				drafted_in_this_run.append(chosen_card.id)

		if run_alive:
			completed_runs += 1
			total_final_hp_on_win += run_hp
			total_turns_on_win += run_turns
			for cid in drafted_in_this_run:
				card_win_counts[cid] = card_win_counts.get(cid, 0) + 1

	var clear_rate = (float(completed_runs) / float(runs)) * 100.0
	var avg_final_hp = float(total_final_hp_on_win) / float(maxi(1, completed_runs))
	var avg_turns = float(total_turns_on_win) / float(maxi(1, completed_runs))

	if is_verbose:
		print("\n--- CRUSADE RUN COMPLETION TELEMETRY (%d Total Attempts) ---" % runs)
		print("  ★ Full Crusade Clear Rate: %5.1f%% (%d / %d won)" % [clear_rate, completed_runs, runs])
		print("  • Avg Hero HP on Final Victory: %5.1f / 30" % avg_final_hp)
		print("  • Avg Total Turns per Cleared Run: %5.1f turns" % avg_turns)

		print("\n--- MORTALITY HEATMAP (Where Crusades Failed) ---")
		for stage in stages:
			var count = deaths_by_stage[stage["id"]]
			var pct = (float(count) / float(runs)) * 100.0
			print("  %-32s : %3d deaths (%5.1f%% failure)" % [stage["name"], count, pct])

		print("\n--------------------------------------------------------------------------------")
		print("                      DRAFT CARD WIN-CORRELATION MATRIX")
		print("--------------------------------------------------------------------------------")
		print("%-18s | %-12s | %-12s | %s" % ["Card ID", "Times Picked", "Runs Won", "Win Correlation"])
		print("--------------------------------------------------------------------------------")
		for cid in card_draft_counts.keys():
			var picks = card_draft_counts[cid]
			var wins_with_card = card_win_counts.get(cid, 0)
			var win_corr = (float(wins_with_card) / float(maxi(1, picks))) * 100.0
			print("%-18s | %-12d | %-12d | %5.1f%%" % [cid, picks, wins_with_card, win_corr])

		var total_time_sec = (Time.get_ticks_msec() - suite_start_ms) / 1000.0
		print("--------------------------------------------------------------------------------")
		print("Finished in %.2f seconds." % total_time_sec)
		print("================================================================================\n")
	else:
		print("    Clear Rate: %5.1f%%  |  Avg HP: %4.1f/30  |  Avg Turns: %4.1f" % [clear_rate, avg_final_hp, avg_turns])

	var crusade_analytics = {
		"persona": p_name,
		"total_runs": runs,
		"completed_runs": completed_runs,
		"clear_rate": clear_rate,
		"avg_final_hp": avg_final_hp,
		"avg_turns": avg_turns,
		"deaths_by_stage": deaths_by_stage,
		"draft_card_stats": {}
	}
	for cid in card_draft_counts.keys():
		crusade_analytics["draft_card_stats"][cid] = {
			"picks": card_draft_counts[cid],
			"wins": card_win_counts.get(cid, 0),
			"win_correlation": (float(card_win_counts.get(cid, 0)) / float(maxi(1, card_draft_counts[cid]))) * 100.0
		}

	if is_verbose:
		var json_str = JSON.stringify(crusade_analytics, "\t")
		var f = FileAccess.open("res://core/simulation/simulation_analytics.json", FileAccess.WRITE)
		if f != null:
			f.store_string(json_str)
			f.close()

	return crusade_analytics

func run_balance_suite(runs_per_encounter: int, persona: CombatSimEngine.BotPersona, filter: String) -> Dictionary:
	var persona_names = ["BALANCED", "AGGRO", "TURTLE", "CHAOS"]
	print("\n================================================================================")
	print("       HERONECROMANCER - AUTOMATED COMBAT BALANCE SUITE")
	print("================================================================================")
	print("Persona: %s | Runs per encounter: %d | Time: %s" % [persona_names[persona], runs_per_encounter, Time.get_datetime_string_from_system()])
	print("--------------------------------------------------------------------------------")

	var starter_deck = load("res://core/cards/data/starter_vanguard_deck.tres") as DeckData
	var suite_start_ms = Time.get_ticks_msec()

	var overall_stats: Dictionary = {
		"timestamp": Time.get_datetime_string_from_system(),
		"persona": persona_names[persona],
		"runs_per_encounter": runs_per_encounter,
		"encounters": {},
		"card_performance": {}
	}

	var card_plays_total: Dictionary = {}
	var card_deads_total: Dictionary = {}

	for enc_path in ENCOUNTERS_CH1:
		if filter != "all" and not enc_path.to_lower().contains(filter):
			continue

		if not ResourceLoader.exists(enc_path):
			continue

		var enc = load(enc_path) as EncounterData
		var enc_name = enc.title if enc.title != "" else enc_path.get_file()
		
		var wins = 0
		var total_turns = 0
		var total_remaining_hp = 0
		var total_dmg_dealt = 0
		var total_dmg_taken = 0

		for r in range(runs_per_encounter):
			var sim = CombatSimEngine.new()
			sim.init_encounter(enc, starter_deck, r + 1)
			var sim_res = sim.run_full_simulation(persona)

			if sim_res.won:
				wins += 1
				total_remaining_hp += sim_res.final_player_hp
			total_turns += sim_res.turns
			total_dmg_dealt += sim_res.damage_dealt_total
			total_dmg_taken += sim_res.damage_taken_total

			for cid in sim_res.card_play_counts.keys():
				card_plays_total[cid] = card_plays_total.get(cid, 0) + sim_res.card_play_counts[cid]
			for cid in sim_res.card_dead_counts.keys():
				card_deads_total[cid] = card_deads_total.get(cid, 0) + sim_res.card_dead_counts[cid]

		var win_rate = (float(wins) / float(runs_per_encounter)) * 100.0
		var avg_turns = float(total_turns) / float(runs_per_encounter)
		var avg_hp = float(total_remaining_hp) / float(maxi(1, wins))
		var avg_dmg_in = float(total_dmg_taken) / float(runs_per_encounter)
		var avg_dmg_out = float(total_dmg_dealt) / float(runs_per_encounter)

		overall_stats["encounters"][enc.id] = {
			"title": enc_name,
			"difficulty": enc.difficulty,
			"win_rate": win_rate,
			"avg_turns": avg_turns,
			"avg_hp_on_win": avg_hp,
			"avg_dmg_dealt": avg_dmg_out,
			"avg_dmg_taken": avg_dmg_in
		}

		print("\n[ENCOUNTER: %s (%s)]" % [enc_name, enc.difficulty])
		print("  • Win Rate:        %5.1f%% (%d/%d)" % [win_rate, wins, runs_per_encounter])
		print("  • Avg Turns:       %5.1f" % avg_turns)
		print("  • Avg HP On Win:   %5.1f / 30" % avg_hp)
		print("  • Avg Dmg In/Out:  Dealt %5.1f | Taken %5.1f" % [avg_dmg_out, avg_dmg_in])
		
		# Balance assessment
		if win_rate < 35.0:
			print("  ⚠ ALERT: Encounter is brutal (Win Rate < 35%)! Check enemy starting damage/HP.")
		elif win_rate > 95.0:
			print("  ✔ Status: Trivial encounter (Win Rate > 95%).")
		else:
			print("  ✔ Status: Well-balanced encounter bracket.")

	print("\n--------------------------------------------------------------------------------")
	print("                         CARD EFFICIENCY & DEAD RATE")
	print("--------------------------------------------------------------------------------")
	print("%-18s | %-12s | %-12s | %-12s | %s" % ["Card ID", "Total Played", "Dead In Hand", "Play/Dead Ratio", "Balance Signal"])
	print("--------------------------------------------------------------------------------")

	for cid in card_plays_total.keys():
		var played = card_plays_total.get(cid, 0)
		var dead = card_deads_total.get(cid, 0)
		var ratio = float(played) / float(maxi(1, played + dead)) * 100.0
		var note = "Balanced"
		if ratio < 35.0:
			note = "Underused/Dead Card ⚠"
		elif ratio > 75.0:
			note = "High Utility / Core ★"

		overall_stats["card_performance"][cid] = {
			"played": played,
			"dead_in_hand": dead,
			"play_percentage": ratio,
			"signal": note
		}

		print("%-18s | %-12d | %-12d | %5.1f%%        | %s" % [cid, played, dead, ratio, note])

	var total_time_sec = (Time.get_ticks_msec() - suite_start_ms) / 1000.0
	print("--------------------------------------------------------------------------------")
	print("Finished in %.2f seconds." % total_time_sec)
	print("================================================================================\n")

	# Save report to JSON
	var json_str = JSON.stringify(overall_stats, "\t")
	var f = FileAccess.open(output_json_path, FileAccess.WRITE)
	if f != null:
		f.store_string(json_str)
		f.close()
		print("Saved telemetry data to: %s\n" % output_json_path)

	return overall_stats

func _trim_specialist_deck(deck: DeckData, persona: CombatSimEngine.BotPersona) -> void:
	if deck == null or deck.cards.size() <= 10:
		return
	var purge_idx = -1
	match persona:
		CombatSimEngine.BotPersona.AGGRO:
			for i in range(deck.cards.size()):
				if deck.cards[i].id == "grave_ward" and not deck.cards[i].is_upgraded:
					purge_idx = i
					break
			if purge_idx == -1:
				for i in range(deck.cards.size()):
					if deck.cards[i].id == "pale_smite" and not deck.cards[i].is_upgraded:
						purge_idx = i
						break
		CombatSimEngine.BotPersona.TURTLE:
			for i in range(deck.cards.size()):
				if deck.cards[i].id == "pale_smite" and not deck.cards[i].is_upgraded:
					purge_idx = i
					break
			if purge_idx == -1:
				for i in range(deck.cards.size()):
					if deck.cards[i].id == "kaelen_volley" and not deck.cards[i].is_upgraded:
						purge_idx = i
						break
		CombatSimEngine.BotPersona.BALANCED:
			for i in range(deck.cards.size()):
				if (deck.cards[i].id == "pale_smite" or deck.cards[i].id == "grave_ward") and not deck.cards[i].is_upgraded:
					purge_idx = i
					break
		CombatSimEngine.BotPersona.CHAOS:
			for i in range(deck.cards.size()):
				if not deck.cards[i].is_upgraded and (deck.cards[i].id == "grave_ward" or deck.cards[i].id == "pale_smite"):
					purge_idx = i
					break
	if purge_idx != -1:
		deck.cards.remove_at(purge_idx)
	elif deck.cards.size() > 10:
		deck.cards.remove_at(0)

func _upgrade_specialist_card(deck: DeckData, persona: CombatSimEngine.BotPersona) -> void:
	if deck == null:
		return
	var priority_ids: Array[String] = []
	match persona:
		CombatSimEngine.BotPersona.AGGRO:
			priority_ids = ["pale_guillotine", "grim_harvest", "pale_smite", "forbidden_rite"]
		CombatSimEngine.BotPersona.TURTLE:
			priority_ids = ["bone_spikes", "vargas_bulwark", "grave_ward", "dark_harvest"]
		CombatSimEngine.BotPersona.BALANCED:
			priority_ids = ["grim_harvest", "dark_harvest", "soul_surge", "soul_cleanse"]
		CombatSimEngine.BotPersona.CHAOS:
			priority_ids = ["soul_roulette", "forbidden_rite", "pale_guillotine", "grim_harvest"]
			
	for target_id in priority_ids:
		for c in deck.cards:
			if c.id == target_id and CardUpgradeModel.can_upgrade(c):
				CardUpgradeModel.upgrade_card_in_deck(deck, c)
				return
				
	for c in deck.cards:
		if CardUpgradeModel.can_upgrade(c):
			CardUpgradeModel.upgrade_card_in_deck(deck, c)
			return

func _has_card_id(deck: DeckData, card_id: String) -> bool:
	if deck == null:
		return false
	for c in deck.cards:
		if c != null and c.id == card_id:
			return true
	return false
