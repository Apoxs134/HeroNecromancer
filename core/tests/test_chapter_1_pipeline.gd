extends Node2D

func _ready() -> void:
	print("--- Running Scene-level Chapter 1 Pipeline Test ---")
	
	# Verify GameManager autoload is active
	assert(GameManager != null, "GameManager singleton not loaded")
	
	# 1. Test Battlefield Scene instantiation with EncounterData
	var battlefield_scene = load("res://battlefield/battlefield.tscn") as PackedScene
	assert(battlefield_scene != null, "Failed to load battlefield.tscn")
	var bf = battlefield_scene.instantiate()
	add_child(bf)
	await get_tree().process_frame
	
	var tutorial_encounter = load("res://battlefield/data/ch1_battle_tutorial.tres") as EncounterData
	bf.load_encounter_resource(tutorial_encounter)
	assert(bf.title_label.text == "TUTORIAL: DEFEND THE SCYTHE", "Battlefield title mismatch")
	assert(bf.background_texture.texture != null, "Battlefield texture not assigned")
	assert(bf.event_overlay.visible == false, "Briefing should be dialog-free")
	assert(bf.card_panel.visible == true, "Briefing details should be directly visible")
	assert(bf.finish_button.visible == true, "Begin battle button should be active")
	print("✔ Battlefield with ch1_battle_tutorial.tres loaded properly as dialog-free briefing.")
	bf.queue_free()
	await get_tree().process_frame
	
	# Test Battle Arena instantiation and tutorial/dialog presentation
	var arena_scene = load("res://battlefield/battle_arena/battle_arena.tscn") as PackedScene
	assert(arena_scene != null, "Failed to load battle_arena.tscn")
	GameManager.active_params = {
		"encounter_tres": "res://battlefield/data/ch1_battle_tutorial.tres",
		"encounter_id": "ch1_battle_tutorial",
		"is_tutorial": true,
		"tutorial_dialog": tutorial_encounter.tutorial_dialog
	}
	var arena = arena_scene.instantiate()
	arena.size = Vector2(1280, 720)
	add_child(arena)
	await get_tree().process_frame
	assert(arena.event_overlay.visible == true, "Battle Arena should display dialogue on encounter start")
	assert(arena.targeting_line != null, "Targeting line not instantiated")
	assert(arena.targeting_reticle_tip != null, "Targeting reticle tip not instantiated")
	
	# Skip dialog to test combat targeting
	arena.event_overlay.visible = false
	arena.combat_ui.visible = true
	arena._start_player_turn()
	await get_tree().process_frame
	await get_tree().process_frame
	assert(arena.hand_cards.size() > 0, "Hand cards should be drawn")
	
	# 1. Tap-to-select enemy test
	arena._select_target_enemy(1)
	assert(arena.selected_target_index == 1, "Tap-targeting enemy 1 failed")
	arena._select_target_enemy(0)
	assert(arena.selected_target_index == 0, "Tap-targeting enemy 0 failed")
	
	# 2. Drag-to-select test
	var card_to_drag = arena.hand_cards[0]
	var initial_hand_count = arena.hand_cards.size()
	arena._on_card_drag_started(card_to_drag, Vector2(500, 600))
	assert(arena.active_drag_card == card_to_drag, "Active drag card should be set")
	assert(arena.targeting_line.visible == true, "Targeting line should become visible on drag")
	assert(arena.targeting_reticle_tip.visible == true, "Targeting tip should become visible on drag")
	
	# Move drag over enemy 1 center
	var e1_center = arena.enemy_ui_nodes[1].get_global_rect().get_center()
	arena._on_card_drag_moved(card_to_drag, e1_center)
	assert(arena.selected_target_index == 1, "Drag over enemy 1 should auto-target enemy 1")
	
	# End drag above hand to cast
	arena._on_card_drag_ended(card_to_drag, e1_center)
	assert(arena.targeting_line.visible == false, "Targeting line should hide after drag end")
	assert(arena.hand_cards.size() == initial_hand_count - 1, "Card should have been played from hand")
	
	# 3. Test Attack Tap Targeting (Should hit selected target directly without blocking)
	arena._select_target_enemy(0)
	var e0_initial_hp = arena.enemies[0]["hp"]
	var attack_card_data = load("res://core/cards/data/pale_smite.tres") as CardData
	arena._spawn_card_to_hand(attack_card_data)
	var atk_card_ui = arena.hand_cards[arena.hand_cards.size() - 1]
	arena._on_card_clicked(attack_card_data, atk_card_ui)
	assert(arena.enemies[0]["hp"] < e0_initial_hp, "Attack card should damage selected enemy on tap")
	
	# 4. Test Shield Card Targeting (Should only target player)
	var initial_block = arena.player_block
	var ward_card_data = load("res://core/cards/data/grave_ward.tres") as CardData
	arena._spawn_card_to_hand(ward_card_data)
	var ward_card_ui = arena.hand_cards[arena.hand_cards.size() - 1]
	arena._on_card_clicked(ward_card_data, ward_card_ui)
	assert(arena.player_block > initial_block, "Shield card must grant Block to player")
	
	# 5. Test Summon and Repeated Summon Morphing into Unsummon / Detonate
	var vargas_card_data = load("res://core/cards/data/vargas_bulwark.tres") as CardData
	arena.player_energy = 6
	arena._spawn_card_to_hand(vargas_card_data)
	var vargas_card_ui = arena.hand_cards[arena.hand_cards.size() - 1]
	arena._on_card_clicked(vargas_card_data, vargas_card_ui)
	assert(arena.active_summons.size() == 1, "Vargas should be summoned to the battlefield")
	
	# Spawn a second Vargas card into hand -> must morph into Detonate / BURST
	arena._spawn_card_to_hand(vargas_card_data)
	arena._update_hand_card_modes()
	var vargas_dup_ui = arena.hand_cards[arena.hand_cards.size() - 1]
	assert(vargas_dup_ui.is_unsummon_mode == true, "Repeated summon card must enter unsummon mode")
	assert(vargas_dup_ui.type_label.text == "BURST", "Card type must display BURST in unsummon mode")
	assert(vargas_dup_ui.title_label.text.contains("Vargas"), "Card title must indicate detonating Vargas")
	
	# 6. Test Directional Unsummon via Drag onto Slot
	var slot0_center = arena._get_slot_containers()[0].get_global_rect().get_center()
	arena._on_card_drag_ended(vargas_dup_ui, slot0_center)
	assert(arena.active_summons.size() == 0, "Directional unsummon should detonate and remove targeted summon")
	
	# 7. Test New WebP Companion Textures
	assert(arena.companion_textures["vargas"].resource_path.ends_with("vargas_summon.webp"), "Vargas texture mismatch")
	assert(arena.companion_textures["kaelen"].resource_path.ends_with("kaelen_summon.webp"), "Kaelen texture mismatch")
	assert(arena.companion_textures["lyra"].resource_path.ends_with("lyra_summon.webp"), "Lyra texture mismatch")
	assert(arena.companion_textures["boros"].resource_path.ends_with("boros_summon.webp"), "Boros texture mismatch")
	assert(arena.hero_texture.resource_path.ends_with("input_commander.webp"), "Hero texture mismatch")
	
	# 8. Test Repeated Summon Card Becoming Unsummon, Other Summon Cards Appearing Normally (Rule 3)
	arena.player_energy = 10
	arena._summon_companion(vargas_card_data)
	var kaelen_card = load("res://core/cards/data/kaelen_sentry.tres") as CardData
	var lyra_card = load("res://core/cards/data/lyra_benediction.tres") as CardData
	var boros_card = load("res://core/cards/data/boros_revenant.tres") as CardData
	arena._summon_companion(kaelen_card)
	arena._summon_companion(lyra_card)
	assert(arena.active_summons.size() == 3, "Expected 3 full summon slots")
	
	# Boros is NOT on field -> Boros card MUST remain normal summon card
	arena._spawn_card_to_hand(boros_card)
	# Lyra IS on field -> Repeated Lyra card MUST morph into unsummon (BURST)
	arena._spawn_card_to_hand(lyra_card)
	arena._update_hand_card_modes()
	var boros_ui = arena.hand_cards[arena.hand_cards.size() - 2]
	var lyra_dup_ui = arena.hand_cards[arena.hand_cards.size() - 1]
	assert(boros_ui.is_unsummon_mode == false, "Card of companion not on field must remain normal summon card")
	assert(lyra_dup_ui.is_unsummon_mode == true, "Repeated summon card of companion already on field must morph into unsummon card")
	assert(lyra_dup_ui.type_label.text == "BURST", "Repeated summon card must show BURST type")
	
	# 9. Test Charnel Sacrifice Filter When No Summon Cards (Rule 1)
	arena.draw_pile.clear()
	arena.discard_pile.clear()
	arena.hand_cards.clear()
	arena.active_summons.clear()
	if GameManager.active_deck != null:
		GameManager.active_deck.cards.clear()
	assert(arena._has_any_summon_card() == false, "Should report no summon cards")
	
	print("✔ Battle Arena tap and drag targeting, webp textures, 3-slot full unsummon, and charnel filter verified.")
	arena.queue_free()
	await get_tree().process_frame
	
	# 2. Test World Map Scene instantiation with MapData
	var world_map_scene = load("res://world_map/world_map.tscn") as PackedScene
	assert(world_map_scene != null, "Failed to load world_map.tscn")
	var wm = world_map_scene.instantiate()
	add_child(wm)
	await get_tree().process_frame
	
	var map_data = load("res://world_map/data/ch1_map_data.tres") as MapData
	wm.load_map_data(map_data)
	assert(wm.header_title.text.begins_with("OAKHAVEN LOWLANDS"), "World map title mismatch")
	assert(wm.map_texture.texture != null, "World map texture not assigned")
	assert(map_data.nodes.size() >= 5, "Expected at least 5 crusade map nodes")
	assert(wm._node_buttons.size() >= 5, "Expected buttons for all crusade nodes")
	print("✔ World Map Crusade Tree with ch1_map_data.tres loaded properly.")
	wm.queue_free()
	await get_tree().process_frame
	
	# 3. Test ClaimCardModal Choice Mode & Card Selection
	var claim_modal_scene = load("res://core/ui/claim_card_modal/claim_card_modal.tscn") as PackedScene
	assert(claim_modal_scene != null, "Failed to load claim_card_modal.tscn")
	var claim_modal = claim_modal_scene.instantiate() as ClaimCardModal
	add_child(claim_modal)
	await get_tree().process_frame
	
	var test_card = load("res://core/cards/data/forbidden_rite.tres") as CardData
	var test_card2 = load("res://core/cards/data/grim_harvest.tres") as CardData
	var test_cards: Array[CardData] = [test_card, test_card2]
	var claimed_result: Array[CardData] = []
	claim_modal.cards_claimed.connect(func(c: Array[CardData]):
		claimed_result.append_array(c)
	)
	
	claim_modal.show_reward(test_cards, "SPOILS OF WAR", "Choose 1 card:", true)
	await get_tree().process_frame
	assert(claim_modal.visible == true, "Claim modal should be visible")
	assert(claim_modal.cards_container.get_child_count() == 2, "Expected 2 reward cards")
	
	# Simulate clicking the first card via its overlay select button
	var first_card_ui = claim_modal.cards_container.get_child(0)
	var select_btn = first_card_ui.get_node_or_null("CardSelectButton") as Button
	assert(select_btn != null, "Overlay CardSelectButton must exist on choice card")
	select_btn.pressed.emit()
	
	await get_tree().create_timer(0.25).timeout
	assert(claim_modal.visible == false, "Claim modal should close after selection")
	assert(claimed_result.size() == 1 and claimed_result[0] == test_card, "Claimed card should match selected card")
	print("✔ ClaimCardModal choice selection, modal closing, and card reward verified.")
	claim_modal.queue_free()
	await get_tree().process_frame
	
	# 4. Test Enemy Textures for All Chapter Encounters (Ch1, Ch2, Ch3)
	var test_encounters: Array[String] = [
		"res://battlefield/data/ch1_battle_tutorial.tres",
		"res://battlefield/data/ch1_tile_battle.tres",
		"res://battlefield/data/ch1_elite_battle.tres",
		"res://battlefield/data/ch1_boss_battle.tres",
		"res://battlefield/data/ch2_tile_battle.tres",
		"res://battlefield/data/ch2_elite_battle.tres",
		"res://battlefield/data/ch2_boss_battle.tres",
		"res://battlefield/data/ch3_tile_battle.tres",
		"res://battlefield/data/ch3_elite_battle.tres",
		"res://battlefield/data/ch3_boss_battle.tres"
	]
	var test_arena = arena_scene.instantiate()
	for enc_path in test_encounters:
		var enc = load(enc_path) as EncounterData
		assert(enc != null, "Failed to load encounter: " + enc_path)
		for enemy in enc.enemies:
			var tex: Texture2D = test_arena._get_enemy_texture(str(enemy))
			assert(tex != null, "Texture is null for enemy: " + str(enemy))
			assert(tex != test_arena.scout_texture and tex != test_arena.farmer_texture, "Enemy mapped to fallback: " + str(enemy))
	test_arena.queue_free()
	print("✔ All enemy textures across Chapter 1, 2, and 3 loaded cleanly with zero fallback.")

	# 5. Test Procedural Encounter Squad Generator (Aleatory, Chapter Constrained, Boss Exclusion)
	print("--- Testing EncounterGenerator Procedural Logic ---")
	var battle_arena_script = load("res://battlefield/battle_arena/battle_arena.gd")
	var bosses = ["garrison captain boros", "high inquisitor malakor", "king alden the betrayer", "malakor's shade"]
	
	# Boss encounters strictly preserve their rosters
	var ch1_boss = load("res://battlefield/data/ch1_boss_battle.tres") as EncounterData
	var ch1_boss_squad = EncounterGenerator.get_enemies_for_encounter(ch1_boss)
	assert(ch1_boss_squad == ch1_boss.enemies, "Boss encounter squad was altered!")

	var ch2_boss = load("res://battlefield/data/ch2_boss_battle.tres") as EncounterData
	var ch2_boss_squad = EncounterGenerator.get_enemies_for_encounter(ch2_boss)
	assert(ch2_boss_squad == ch2_boss.enemies, "Ch2 Boss squad was altered!")

	var ch3_boss = load("res://battlefield/data/ch3_boss_battle.tres") as EncounterData
	var ch3_boss_squad = EncounterGenerator.get_enemies_for_encounter(ch3_boss)
	assert(ch3_boss_squad == ch3_boss.enemies, "Ch3 Boss squad was altered!")
	print("✔ Boss encounters strictly preserved.")

	# Non-boss squad generation: boss exclusion, chapter constraint, sizing, aleatory diversity
	var ch1_normal = load("res://battlefield/data/ch1_tile_battle.tres") as EncounterData
	var ch2_normal = load("res://battlefield/data/ch2_tile_battle.tres") as EncounterData
	var ch3_normal = load("res://battlefield/data/ch3_tile_battle.tres") as EncounterData

	var ch1_variations = {}
	var ch2_variations = {}
	var ch3_variations = {}

	for _i in range(30):
		var s1 = EncounterGenerator.get_enemies_for_encounter(ch1_normal)
		assert(s1.size() >= 2 and s1.size() <= 3, "Ch1 squad size out of bounds: %d" % s1.size())
		for e in s1:
			var low = e.to_lower()
			for b in bosses:
				assert(not low.contains(b), "Boss leaked into Ch1 non-boss encounter: %s" % e)
			assert(battle_arena_script.CHAPTER_1_ENEMY_TEXTURES.has(low) or low.contains("farmer") or low.contains("scout"), "Ch1 invalid enemy: %s" % e)
		ch1_variations[",".join(s1)] = true

		var s2 = EncounterGenerator.get_enemies_for_encounter(ch2_normal)
		assert(s2.size() >= 3 and s2.size() <= 4, "Ch2 squad size out of bounds: %d" % s2.size())
		for e in s2:
			var low = e.to_lower()
			for b in bosses:
				assert(not low.contains(b), "Boss leaked into Ch2 non-boss encounter: %s" % e)
			assert(battle_arena_script.CHAPTER_2_ENEMY_TEXTURES.has(low), "Ch2 invalid enemy: %s" % e)
		ch2_variations[",".join(s2)] = true

		var s3 = EncounterGenerator.get_enemies_for_encounter(ch3_normal)
		assert(s3.size() == 4, "Ch3 squad size must be 4: %d" % s3.size())
		for e in s3:
			var low = e.to_lower()
			for b in bosses:
				assert(not low.contains(b), "Boss leaked into Ch3 non-boss encounter: %s" % e)
			assert(battle_arena_script.CHAPTER_3_ENEMY_TEXTURES.has(low), "Ch3 invalid enemy: %s" % e)
		ch3_variations[",".join(s3)] = true

	assert(ch1_variations.size() > 1, "Ch1 generated squads lack aleatory variation")
	assert(ch2_variations.size() > 1, "Ch2 generated squads lack aleatory variation")
	assert(ch3_variations.size() > 1, "Ch3 generated squads lack aleatory variation")
	print("✔ Non-boss squads verified: randomized compositions, 0 boss leaks, strict chapter pools, correct sizing.")

	# 6. Test Character Visual Scaling & Dynamic Silhouette Shadows
	print("--- Testing Character Visual Scaling & Dynamic Silhouette Shadows ---")
	var visual_arena = arena_scene.instantiate()
	add_child(visual_arena)
	await get_tree().process_frame

	# A. Check Hero silhouette shadow
	var hero_sil = visual_arena.find_child("HeroSilhouette", true, false) as TextureRect
	assert(hero_sil != null, "HeroSilhouette must be created under HeroSlot")
	assert(hero_sil.material is ShaderMaterial, "HeroSilhouette must use ShaderMaterial")

	# B. Check Scale Profile Tiers
	var prof_vargas = visual_arena._get_character_visual_profile("vargas")
	var prof_golem = visual_arena._get_character_visual_profile("sanctified golem")
	var prof_hound = visual_arena._get_character_visual_profile("holy warhound")
	var prof_scout = visual_arena._get_character_visual_profile("peasant militia scout")
	var prof_shade = visual_arena._get_character_visual_profile("high chancellor shade")

	assert(prof_vargas.scale >= 1.20, "Vargas must be scaled up (>= 1.20)")
	assert(prof_golem.scale >= 1.25, "Golems must be scaled up (>= 1.25)")
	assert(prof_hound.scale <= 0.85, "Hounds must be scaled down (<= 0.85)")
	assert(prof_scout.scale <= 0.90, "Scouts must be scaled down (<= 0.90)")
	assert(prof_shade.y_offset < 0.0, "Shade must have negative y_offset for hovering")

	# C. Check Enemy Silhouette Shadows & Pivot
	assert(visual_arena.enemy_ui_nodes.size() > 0, "Enemy nodes must exist")
	for enode in visual_arena.enemy_ui_nodes:
		var espr = enode.find_child("EnemySprite", true, false) as TextureRect
		var eshadow = enode.find_child("CharacterShadow", true, false) as TextureRect
		var eground = enode.find_child("GroundShadow", true, false) as TextureRect
		var e_intent = enode.find_child("IntentBadge", true, false) as Panel
		var e_reticle = enode.find_child("ReticleIcon", true, false) as TextureRect
		assert(espr != null, "EnemySprite missing")
		assert(eshadow != null, "CharacterShadow missing")
		assert(eground != null, "GroundShadow contact missing")
		assert(e_intent != null, "IntentBadge missing")
		assert(e_reticle != null, "ReticleIcon missing")
		assert(abs((e_intent.position.y - 54.0) - e_reticle.position.y) < 0.1, "ReticleIcon must align directly above IntentBadge")
		assert(eshadow.material is ShaderMaterial, "CharacterShadow must use ShaderMaterial")
		assert(espr.pivot_offset.y > 180.0, "Enemy sprite pivot must be anchored at feet")

	# Check Intent badge calculation extremes
	var golem_intent_y = 6.0 + prof_golem.y_offset - 195.0 * (prof_golem.scale - 1.0)
	var hound_intent_y = 6.0 + prof_hound.y_offset - 195.0 * (prof_hound.scale - 1.0) + prof_hound.get("intent_y_adjust", 0.0)
	assert(golem_intent_y < -40.0, "Large character intention panel must shift up (y < -40)")
	assert(hound_intent_y > 40.0, "Small character intention panel must shift down (y > 40)")

	# D. Check Summon Scaling & Silhouette Shadow
	var vargas_card = load("res://core/cards/data/vargas_bulwark.tres") as CardData
	visual_arena._summon_companion(vargas_card)
	await get_tree().create_timer(0.35).timeout
	var v_spr = visual_arena.vanguard_sprite
	assert(v_spr != null and abs(v_spr.scale.x - 1.25) < 0.01, "Vargas summon sprite must scale to 1.25")
	var v_sil = visual_arena._slot_silhouette_shadows[0]
	assert(v_sil != null and v_sil.visible == true, "Vargas silhouette shadow must be visible when summoned")
	assert(v_sil.material is ShaderMaterial, "Vargas silhouette must use ShaderMaterial")

	visual_arena.queue_free()
	await get_tree().process_frame
	print("✔ Character scaling tiers, feet anchors, and dynamic silhouette shadows verified!")

	print("--- ALL CHAPTER 1 SCENE TESTS PASSED CLEANLY! ---")
	get_tree().quit(0)
