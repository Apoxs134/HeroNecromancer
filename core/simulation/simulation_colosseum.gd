extends Control

const CombatSimEngine = preload("res://core/simulation/combat_sim_engine.gd")

# UI References
@onready var encounter_select: OptionButton = $MainLayout/LeftPanel/VBox/EncounterSelect
@onready var bot_select: OptionButton = $MainLayout/LeftPanel/VBox/BotSelect
@onready var speed_select: OptionButton = $MainLayout/LeftPanel/VBox/SpeedSelect
@onready var start_match_btn: Button = $MainLayout/LeftPanel/VBox/StartMatchButton
@onready var batch_sim_btn: Button = $MainLayout/LeftPanel/VBox/BatchSimButton
@onready var reset_btn: Button = $MainLayout/LeftPanel/VBox/ResetButton

# Live Arena UI
@onready var status_banner: Label = $MainLayout/CenterPanel/VBox/StatusBanner
@onready var hero_hp_bar: ProgressBar = $MainLayout/CenterPanel/VBox/ArenaBox/AllianceSide/HeroHPBar
@onready var hero_hp_label: Label = $MainLayout/CenterPanel/VBox/ArenaBox/AllianceSide/HeroHPLabel
@onready var hero_block_label: Label = $MainLayout/CenterPanel/VBox/ArenaBox/AllianceSide/HeroBlockLabel
@onready var vanguard_box: Panel = $MainLayout/CenterPanel/VBox/ArenaBox/AllianceSide/VanguardBox
@onready var vanguard_label: Label = $MainLayout/CenterPanel/VBox/ArenaBox/AllianceSide/VanguardBox/VanguardLabel

@onready var enemies_container: HBoxContainer = $MainLayout/CenterPanel/VBox/ArenaBox/EnemiesSide
@onready var hand_label: Label = $MainLayout/CenterPanel/VBox/HandInfo/HandLabel
@onready var ticker_log: RichTextLabel = $MainLayout/CenterPanel/VBox/TickerLog

# Analytics Dashboard
@onready var win_rate_label: Label = $MainLayout/RightPanel/VBox/WinRateLabel
@onready var avg_turns_label: Label = $MainLayout/RightPanel/VBox/AvgTurnsLabel
@onready var avg_hp_label: Label = $MainLayout/RightPanel/VBox/AvgHPLabel
@onready var card_stats_table: RichTextLabel = $MainLayout/RightPanel/VBox/CardStatsTable
@onready var alert_label: Label = $MainLayout/RightPanel/VBox/AlertLabel

const ENCOUNTER_DATA = [
	{"name": "Ch.1 - Tutorial: Defend The Scythe", "path": "res://battlefield/data/ch1_battle_tutorial.tres"},
	{"name": "Ch.1 - Outpost Skirmish: Granary Road", "path": "res://battlefield/data/ch1_tile_battle.tres"},
	{"name": "Ch.1 - Elite: Inquisition Patrol", "path": "res://battlefield/data/ch1_elite_battle.tres"},
	{"name": "Ch.1 - Boss: Garrison of the Granary", "path": "res://battlefield/data/ch1_boss_battle.tres"},
	{"name": "Ch.2 - Lowlands Skirmish", "path": "res://battlefield/data/ch2_tile_battle.tres"},
	{"name": "Ch.2 - Elite: Templar Commander", "path": "res://battlefield/data/ch2_elite_battle.tres"},
	{"name": "Ch.2 - Boss: Castle Keep", "path": "res://battlefield/data/ch2_boss_battle.tres"}
]

var live_engine: CombatSimEngine = null
var current_encounter: EncounterData = null
var starter_deck: DeckData = null
var is_spectating: bool = false
var match_speed: float = 1.0

func _ready() -> void:
	starter_deck = load("res://core/cards/data/starter_vanguard_deck.tres") as DeckData
	_setup_dropdowns()
	_connect_signals()
	_load_selected_encounter()

func _setup_dropdowns() -> void:
	encounter_select.clear()
	for i in range(ENCOUNTER_DATA.size()):
		encounter_select.add_item(ENCOUNTER_DATA[i]["name"], i)

	bot_select.clear()
	bot_select.add_item("Balanced (Adaptive)", 0)
	bot_select.add_item("Aggro (Damage Focus)", 1)
	bot_select.add_item("Turtle (Vanguard / Block)", 2)
	bot_select.add_item("Chaos (Random Stress Test)", 3)

	speed_select.clear()
	speed_select.add_item("1x Normal Speed", 0)
	speed_select.add_item("2x Fast", 1)
	speed_select.add_item("5x Turbo", 2)

func _connect_signals() -> void:
	encounter_select.item_selected.connect(func(_idx): _load_selected_encounter())
	start_match_btn.pressed.connect(_on_start_match_pressed)
	batch_sim_btn.pressed.connect(_on_batch_sim_pressed)
	reset_btn.pressed.connect(_on_reset_pressed)
	speed_select.item_selected.connect(_on_speed_changed)

func _on_speed_changed(idx: int) -> void:
	match idx:
		0: match_speed = 1.0
		1: match_speed = 2.0
		2: match_speed = 5.0

func _load_selected_encounter() -> void:
	var idx = encounter_select.selected
	if idx >= 0 and idx < ENCOUNTER_DATA.size():
		var path = ENCOUNTER_DATA[idx]["path"]
		if ResourceLoader.exists(path):
			current_encounter = load(path) as EncounterData
	_reset_live_state()

func _reset_live_state() -> void:
	is_spectating = false
	start_match_btn.disabled = false
	live_engine = CombatSimEngine.new()
	if current_encounter != null:
		live_engine.init_encounter(current_encounter, starter_deck)
	status_banner.text = "Idle. Select an encounter and click [Start Match] or [Batch 100 Runs]."
	status_banner.modulate = Color(0.85, 0.85, 0.95)
	ticker_log.text = "[color=#778899]Awaiting battle commencement...[/color]"
	_update_live_ui()

func _update_live_ui() -> void:
	if live_engine == null:
		return

	# Alliance
	hero_hp_bar.max_value = live_engine.player_max_hp
	hero_hp_bar.value = live_engine.player_hp
	hero_hp_label.text = "Hero HP: %d / %d" % [live_engine.player_hp, live_engine.player_max_hp]
	hero_block_label.text = "🛡 Block: %d | ⚡ Energy: %d/3" % [live_engine.player_block, live_engine.player_energy]

	if live_engine.vanguard_active:
		vanguard_box.visible = true
		vanguard_label.text = "Vargas: %d/%d HP (Taunt Active)" % [live_engine.vanguard_hp, live_engine.vanguard_max_hp]
	else:
		vanguard_box.visible = false

	# Enemies
	for child in enemies_container.get_children():
		child.queue_free()

	for i in range(live_engine.enemies.size()):
		var e = live_engine.enemies[i]
		var e_panel = PanelContainer.new()
		e_panel.custom_minimum_size = Vector2(140, 110)
		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 3)

		var name_lbl = Label.new()
		name_lbl.text = e["name"]
		name_lbl.add_theme_font_size_override("font_size", 12)
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(name_lbl)

		var hp_bar = ProgressBar.new()
		hp_bar.max_value = e["max_hp"]
		hp_bar.value = maxi(0, e["hp"])
		hp_bar.custom_minimum_size = Vector2(130, 10)
		hp_bar.show_percentage = false
		vbox.add_child(hp_bar)

		var hp_lbl = Label.new()
		if e["hp"] <= 0:
			hp_lbl.text = "☠ DEFEATED"
			hp_lbl.add_theme_color_override("font_color", Color(0.6, 0.3, 0.3))
		else:
			hp_lbl.text = "HP: %d/%d  (⚔ %d)" % [e["hp"], e["max_hp"], e["damage"]]
			hp_lbl.add_theme_color_override("font_color", Color(1.0, 0.8, 0.6))
		hp_lbl.add_theme_font_size_override("font_size", 11)
		hp_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(hp_lbl)

		var vuln = e["afflictions"].get("vulnerable", 0)
		if vuln > 0:
			var aff_lbl = Label.new()
			aff_lbl.text = "🩸 Vuln x%d" % vuln
			aff_lbl.add_theme_font_size_override("font_size", 10)
			aff_lbl.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
			vbox.add_child(aff_lbl)

		e_panel.add_child(vbox)
		enemies_container.add_child(e_panel)

	# Hand
	var hand_titles: Array[String] = []
	for card in live_engine.hand:
		hand_titles.append("[%s (%d⚡)]" % [card.title, card.cost])
	hand_label.text = "Bot Hand (%d cards): %s" % [live_engine.hand.size(), "  ".join(hand_titles) if hand_titles.size() > 0 else "Empty"]

func _log_ticker(msg: String, color_hex: String = "#c0c0d0") -> void:
	ticker_log.append_text("[color=%s]%s[/color]\n" % [color_hex, msg])

func _on_start_match_pressed() -> void:
	if is_spectating:
		return
	is_spectating = true
	start_match_btn.disabled = true
	status_banner.text = "⚔ Spectator Match Active! Bot piloting encounter..."
	status_banner.modulate = Color(0.4, 1.0, 0.7)

	live_engine = CombatSimEngine.new()
	live_engine.init_encounter(current_encounter, starter_deck)
	ticker_log.text = ""
	_log_ticker("=== BATTLE COMMENCED: %s ===" % current_encounter.title, "#f0e68c")

	var persona = bot_select.selected as CombatSimEngine.BotPersona
	var turn = 0

	while is_spectating and not live_engine.is_all_enemies_defeated() and live_engine.player_hp > 0:
		turn += 1
		live_engine.turn_count = turn
		live_engine.player_energy = live_engine.max_energy
		live_engine.player_block = 0
		live_engine.draw_cards(5 - live_engine.hand.size())
		_update_live_ui()

		_log_ticker("\n--- Turn %d: Bot drawing cards ---" % turn, "#87ceeb")
		await get_tree().create_timer(maxf(0.08, 0.5 / match_speed)).timeout
		if not is_spectating:
			break

		# Step bot card plays one by one visually
		var played_any = true
		while played_any and is_spectating:
			played_any = false
			var playable: Array[CardData] = []
			for c in live_engine.hand:
				if c.cost <= live_engine.player_energy:
					playable.append(c)

			if playable.is_empty():
				break

			# Pick card
			var chosen: CardData = null
			if not live_engine.vanguard_active:
				for c in playable:
					if c.card_type == CardData.CardType.SUMMON or c.id == "vargas_bulwark":
						chosen = c
						break
			if chosen == null:
				for c in playable:
					if c.card_type == CardData.CardType.ATTACK or c.card_type == CardData.CardType.SPELL:
						chosen = c
						break
			if chosen == null:
				chosen = playable[0]

			if chosen != null:
				var target_idx = live_engine.get_lowest_hp_alive_enemy()
				var target_name = live_engine.enemies[target_idx]["name"] if target_idx != -1 else "Foe"
				live_engine.play_card(chosen, target_idx)
				played_any = true

				_log_ticker("Bot casts %s on %s!" % [chosen.title, target_name], "#98fb98")
				_update_live_ui()
				await get_tree().create_timer(maxf(0.06, 0.4 / match_speed)).timeout

			if live_engine.is_all_enemies_defeated():
				break

		if live_engine.is_all_enemies_defeated():
			break

		# Enemy attack phase
		_log_ticker("Enemies striking back...", "#ffa07a")
		await get_tree().create_timer(maxf(0.06, 0.35 / match_speed)).timeout
		live_engine.execute_enemy_phase()
		_update_live_ui()
		await get_tree().create_timer(maxf(0.06, 0.35 / match_speed)).timeout

	is_spectating = false
	start_match_btn.disabled = false

	if live_engine.is_all_enemies_defeated():
		status_banner.text = "🏆 VICTORY! Bot successfully cleared the encounter!"
		status_banner.modulate = Color(0.3, 1.0, 0.5)
		_log_ticker("\n=== ENCOUNTER WON in %d turns! Hero HP: %d/30 ===" % [turn, live_engine.player_hp], "#32cd32")
	elif live_engine.player_hp <= 0:
		status_banner.text = "☠ DEFEAT! Hero fell in battle."
		status_banner.modulate = Color(1.0, 0.4, 0.4)
		_log_ticker("\n=== HERO FALLEN at Turn %d ===" % turn, "#ff4500")

func _on_batch_sim_pressed() -> void:
	if current_encounter == null:
		return
	status_banner.text = "Running 100 simulations in background..."
	status_banner.modulate = Color(1.0, 0.85, 0.3)

	var persona = bot_select.selected as CombatSimEngine.BotPersona
	var runs = 100
	var wins = 0
	var total_turns = 0
	var total_remaining_hp = 0
	var card_plays: Dictionary = {}
	var card_deads: Dictionary = {}

	for r in range(runs):
		var sim = CombatSimEngine.new()
		sim.init_encounter(current_encounter, starter_deck, r + 1)
		var res = sim.run_full_simulation(persona)
		if res.won:
			wins += 1
			total_remaining_hp += res.final_player_hp
		total_turns += res.turns

		for cid in res.card_play_counts.keys():
			card_plays[cid] = card_plays.get(cid, 0) + res.card_play_counts[cid]
		for cid in res.card_dead_counts.keys():
			card_deads[cid] = card_deads.get(cid, 0) + res.card_dead_counts[cid]

	var win_rate = (float(wins) / float(runs)) * 100.0
	var avg_turns = float(total_turns) / float(runs)
	var avg_hp = float(total_remaining_hp) / float(maxi(1, wins))

	win_rate_label.text = "Win Rate: %5.1f%% (%d / %d)" % [win_rate, wins, runs]
	avg_turns_label.text = "Avg Turns: %.1f" % avg_turns
	avg_hp_label.text = "Avg HP On Victory: %.1f / 30" % avg_hp

	if win_rate >= 80.0:
		win_rate_label.modulate = Color(0.3, 1.0, 0.5)
	elif win_rate >= 40.0:
		win_rate_label.modulate = Color(1.0, 0.85, 0.3)
	else:
		win_rate_label.modulate = Color(1.0, 0.35, 0.35)

	# Format Card Table
	var table_text = "[b]Card Telemetry (Plays vs Dead in Hand):[/b]\n"
	for cid in card_plays.keys():
		var p = card_plays.get(cid, 0)
		var d = card_deads.get(cid, 0)
		var pct = float(p) / float(maxi(1, p + d)) * 100.0
		table_text += "• [color=#87cefa]%s[/color]: %d played | %d dead (%4.1f%%)\n" % [cid, p, d, pct]
	card_stats_table.text = table_text

	if win_rate < 35.0:
		alert_label.text = "⚠ Balance Alert: Encounter is punitive! Average survival rate < 35%."
		alert_label.modulate = Color(1.0, 0.4, 0.4)
	elif win_rate > 95.0:
		alert_label.text = "✔ Balance Alert: Trivial encounter. Suitable for intro/tutorial."
		alert_label.modulate = Color(0.5, 0.9, 1.0)
	else:
		alert_label.text = "✔ Healthy Balance: Win rate between 40% and 90%."
		alert_label.modulate = Color(0.4, 1.0, 0.5)

	status_banner.text = "Batch of 100 completed! Analytics updated on right panel."
	status_banner.modulate = Color(0.4, 0.9, 1.0)

func _on_reset_pressed() -> void:
	_reset_live_state()
