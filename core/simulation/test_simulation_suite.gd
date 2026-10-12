extends Node

func _ready() -> void:
	print("--- Running Combat Simulation & Auto-Battler Verification Suite ---")

	# 1. Test Pure CombatSimEngine across all 4 bot personas
	var enc = load("res://battlefield/data/ch1_tile_battle.tres") as EncounterData
	var deck = load("res://core/cards/data/starter_vanguard_deck.tres") as DeckData
	var CombatSimEngine = preload("res://core/simulation/combat_sim_engine.gd")

	for persona in [CombatSimEngine.BotPersona.BALANCED, CombatSimEngine.BotPersona.AGGRO, CombatSimEngine.BotPersona.TURTLE, CombatSimEngine.BotPersona.CHAOS]:
		var sim = CombatSimEngine.new()
		sim.init_encounter(enc, deck, 42)
		var res = sim.run_full_simulation(persona)
		assert(res.turns > 0, "Simulation should complete at least 1 turn")
		assert(res.card_play_counts.size() > 0, "Cards should be played")

	print("✔ CombatSimEngine validated for BALANCED, AGGRO, TURTLE, and CHAOS bots.")

	# 2. Test Simulation Colosseum instantiation
	var col_scene = load("res://core/simulation/simulation_colosseum.tscn") as PackedScene
	var col = col_scene.instantiate()
	add_child(col)
	await get_tree().process_frame
	assert(col.encounter_select.item_count >= 5, "Colosseum encounter list loaded")
	assert(col.bot_select.item_count == 4, "Colosseum bot list loaded")
	col._on_batch_sim_pressed()
	assert(col.win_rate_label.text.begins_with("Win Rate:"), "Colosseum batch sim updated telemetry UI")
	col.queue_free()
	await get_tree().process_frame

	print("✔ Simulation Colosseum & in-game telemetry dashboard verified.")
	print("--- ALL SIMULATION & AUTO-BATTLER TESTS PASSED CLEANLY! ---")
	get_tree().quit(0)
