extends Control

const DeckTrayScript = preload("res://battlefield/deck_tray/deck_tray.gd")

const CINZEL_BOLD = preload("res://ui/fonts/Cinzel/static/Cinzel-Bold.ttf")
const CINZEL_SEMIBOLD = preload("res://ui/fonts/Cinzel/static/Cinzel-SemiBold.ttf")
const CRIMSON_REGULAR = preload("res://ui/fonts/Crimson_Pro/static/CrimsonPro-Regular.ttf")
const CRIMSON_ITALIC = preload("res://ui/fonts/Crimson_Pro/static/CrimsonPro-MediumItalic.ttf")

# Chapter 1 Enemy Sprites Mapping
const CHAPTER_1_ENEMY_TEXTURES: Dictionary = {
	"peasant militia scout": preload("res://core/battle/chapter1/Peasant Militia Scout.webp"),
	"enraged farmer": preload("res://core/battle/chapter1/Enraged Farmer.webp"),
	"militia vanguard": preload("res://core/battle/chapter1/Militia Vanguard.webp"),
	"armed townsperson": preload("res://core/battle/chapter1/Armed Townsperson.webp"),
	"armed townspersons": preload("res://core/battle/chapter1/Armed Townsperson.webp"),
	"hound of oakhaven": preload("res://core/battle/chapter1/Hound of Oakhaven.webp"),
	"zealot templar": preload("res://core/battle/chapter1/Zealot Templar.webp"),
	"holy warhound": preload("res://core/battle/chapter1/Holy Warhound.webp"),
	"pyre crossbowman": preload("res://core/battle/chapter1/Pyre Crossbowman.webp"),
	"garrison captain boros": preload("res://core/battle/chapter1/Garrison Captain Boros.webp"),
	"tower halberdier": preload("res://core/battle/chapter1/Tower Halberdier.webp"),
	"tower halberdiers": preload("res://core/battle/chapter1/Tower Halberdier.webp"),
	"militia bowman": preload("res://core/battle/chapter1/Militia Bowman.webp"),
}

# Chapter 2 Enemy Sprites Mapping
const CHAPTER_2_ENEMY_TEXTURES: Dictionary = {
	"inquisition crossbowman": preload("res://core/battle/chapter2/Inquisition Crossbowman.webp"),
	"templar halberdier": preload("res://core/battle/chapter2/Templar Halberdier.webp"),
	"templar halberdiers": preload("res://core/battle/chapter2/Templar Halberdier.webp"),
	"hounds of mourning": preload("res://core/battle/chapter2/Hounds of Mourning.webp"),
	"hound of mourning": preload("res://core/battle/chapter2/Hounds of Mourning.webp"),
	"grand judiciar vane": preload("res://core/battle/chapter2/Grand Judiciar Vane.webp"),
	"purifying templars": preload("res://core/battle/chapter2/Purifying Templars.webp"),
	"purifying templar": preload("res://core/battle/chapter2/Purifying Templars.webp"),
	"iron maiden vanguard": preload("res://core/battle/chapter2/Iron Maiden Vanguard.webp"),
	"high inquisitor malakor": preload("res://core/battle/chapter2/High Inquisitor Malakor.webp"),
	"sanctified golem": preload("res://core/battle/chapter2/Sanctified Golem.webp"),
	"sun-oath executioners": preload("res://core/battle/chapter2/Sun-Oath Executioners.webp"),
	"sun-oath executioner": preload("res://core/battle/chapter2/Sun-Oath Executioners.webp"),
}

# Chapter 3 Enemy Sprites Mapping
const CHAPTER_3_ENEMY_TEXTURES: Dictionary = {
	"citadel halberdier": preload("res://core/battle/chapter3/Citadel Halberdier.webp"),
	"citadel halberdiers": preload("res://core/battle/chapter3/Citadel Halberdier.webp"),
	"royal arbalestier": preload("res://core/battle/chapter3/Royal Arbalestier.webp"),
	"palace gilded knight": preload("res://core/battle/chapter3/Palace Gilded Knight.webp"),
	"captain lorian of the guard": preload("res://core/battle/chapter3/Captain Lorian of the Guard.webp"),
	"captain lorian": preload("res://core/battle/chapter3/Captain Lorian of the Guard.webp"),
	"golden templar champion": preload("res://core/battle/chapter3/Golden Templar Champion.webp"),
	"grand justiciar golem": preload("res://core/battle/chapter3/Grand Justiciar Golem.webp"),
	"king alden the betrayer": preload("res://core/battle/chapter3/King Alden the Betrayer.webp"),
	"king alden": preload("res://core/battle/chapter3/King Alden the Betrayer.webp"),
	"royal sun-golem": preload("res://core/battle/chapter3/Royal Sun-Golem.webp"),
	"royal sun golem": preload("res://core/battle/chapter3/Royal Sun-Golem.webp"),
	"high chancellor malakor's shade": preload("res://core/battle/chapter3/High Chancellor Shade.webp"),
	"high chancellor shade": preload("res://core/battle/chapter3/High Chancellor Shade.webp"),
}

@onready var title_label: Label = find_child("Title") as Label
@onready var card_panel: Control = find_child("CardPanel") as Control
@onready var details_label: Label = find_child("DetailsLabel") as Label
@onready var enemy_list_container: HBoxContainer = find_child("EnemyListContainer") as HBoxContainer
@onready var difficulty_label: Label = find_child("DifficultyLabel") as Label
@onready var difficulty_badge: PanelContainer = find_child("DifficultyBadge") as PanelContainer
@onready var battle_actions_container: HBoxContainer = find_child("BattleActionsContainer") as HBoxContainer
@onready var finish_button: Button = find_child("FinishButton") as Button
@onready var soul_crypt_button: Button = find_child("SoulCryptButton") as Button
@onready var retreat_button: Button = find_child("RetreatButton") as Button
@onready var debug_skip_button: Button = find_child("DebugSkipButton") as Button
@onready var deck_tray: DeckTrayScript = find_child("DeckTray") as DeckTrayScript
@onready var background_texture: TextureRect = find_child("BackgroundTexture") as TextureRect

@onready var event_overlay: ColorRect = find_child("EventOverlay") as ColorRect
@onready var event_speaker_label: Label = find_child("SpeakerLabel") as Label
@onready var event_message_label: Label = find_child("MessageLabel") as Label

var current_encounter: EncounterData = null
var event_lines: Array = []
var current_event_line_index: int = 0

const BATTLE_LEVELS = {
	"battle_1": {
		"name": "The Dark Forest",
		"enemies": ["Peasant Militia Scout", "Enraged Farmer"],
		"difficulty": "Easy"
	},
	"battle_2": {
		"name": "Necromancer's Keep",
		"enemies": ["Militia Vanguard", "Zealot Templar", "Pyre Crossbowman"],
		"difficulty": "Hard"
	}
}

func _ready() -> void:
	if retreat_button != null:
		retreat_button.pressed.connect(_on_retreat_pressed)
	if finish_button != null:
		finish_button.pressed.connect(_on_finish_pressed)
	if soul_crypt_button != null:
		soul_crypt_button.pressed.connect(_on_soul_crypt_pressed)
	
	if debug_skip_button != null:
		debug_skip_button.visible = GameManager.debug_battle_skip
		debug_skip_button.pressed.connect(_on_debug_skip_pressed)
		
	_update_battle_ui_visibility(false)
	
	var encounter_tres = GameManager.active_params.get("encounter_tres", "")
	var encounter_res: EncounterData = null
	
	if encounter_tres is EncounterData:
		encounter_res = encounter_tres
	elif encounter_tres is String and not encounter_tres.is_empty() and ResourceLoader.exists(encounter_tres):
		encounter_res = load(encounter_tres) as EncounterData
		
	if encounter_res != null:
		load_encounter_resource(encounter_res)
	else:
		var battle_id = GameManager.active_params.get("encounter_id", GameManager.active_params.get("battle_id", "battle_1"))
		load_legacy_battle(battle_id)

func _can_retreat() -> bool:
	if current_encounter != null:
		if not current_encounter.can_retreat or not current_encounter.return_to_map:
			return false
		if current_encounter.id == "ch1_battle_tutorial" or current_encounter.difficulty.to_lower() == "tutorial":
			return false
	return true

func _update_battle_ui_visibility(dialog_active: bool) -> void:
	if card_panel != null:
		card_panel.visible = not dialog_active
	if battle_actions_container != null:
		battle_actions_container.visible = not dialog_active
	if finish_button != null:
		finish_button.visible = not dialog_active
	if soul_crypt_button != null:
		soul_crypt_button.visible = not dialog_active
	if retreat_button != null:
		retreat_button.visible = not dialog_active and _can_retreat()
	if debug_skip_button != null:
		debug_skip_button.visible = GameManager.debug_battle_skip

func _on_soul_crypt_pressed() -> void:
	if deck_tray != null:
		var deck = GameManager.active_deck
		if deck == null:
			deck = load("res://core/cards/data/starter_vanguard_deck.tres") as DeckData
		deck_tray.open(deck)

var _last_advance_msec: int = 0

func _on_debug_skip_pressed() -> void:
	print("[DEBUG] Skip battle pressed! Completing encounter: %s" % (current_encounter.id if current_encounter != null else "legacy"))
	_execute_battle_completion()

func _input(event: InputEvent) -> void:
	if deck_tray != null and deck_tray.visible:
		return
	if event_overlay == null or not event_overlay.visible:
		return
	var is_tap = (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventScreenTouch and event.pressed)
	if not is_tap:
		return
	var tap_pos: Vector2 = event.position if event is InputEventScreenTouch else event.global_position
	if debug_skip_button != null and debug_skip_button.visible and debug_skip_button.get_global_rect().has_point(tap_pos):
		return
	if soul_crypt_button != null and soul_crypt_button.visible and soul_crypt_button.get_global_rect().has_point(tap_pos):
		return
	var now = Time.get_ticks_msec()
	if now < _last_advance_msec + 250:
		return
	_last_advance_msec = now
	advance_event()
	get_viewport().set_input_as_handled()

func load_encounter_resource(encounter: EncounterData) -> void:
	current_encounter = encounter
	if title_label != null:
		title_label.text = encounter.title
	if encounter.bg_texture != null and background_texture != null:
		background_texture.texture = encounter.bg_texture
		background_texture.visible = true
	elif background_texture != null:
		background_texture.visible = false
		
	var chapter = GameManager.active_params.get("chapter", "")
	var active_enemies = EncounterGenerator.get_enemies_for_encounter(encounter, chapter)
	GameManager.active_params["generated_enemies"] = active_enemies

	_populate_enemy_list(active_enemies, encounter.difficulty)
	
	if event_overlay != null:
		event_overlay.visible = false
	_update_battle_ui_visibility(false)

func load_legacy_battle(battle_id: String) -> void:
	var battle_name = "Battlefield"
	var diff = "Normal"
	var enemies: Array = []
	
	if BATTLE_LEVELS.has(battle_id):
		var info = BATTLE_LEVELS[battle_id]
		battle_name = info["name"]
		diff = info["difficulty"]
		enemies = info["enemies"]
	else:
		battle_name = "Encounter: " + battle_id
		enemies = ["Peasant Militia Scout", "Enraged Farmer"]
		
	if title_label != null:
		title_label.text = battle_name
		
	GameManager.active_params["generated_enemies"] = enemies
	_populate_enemy_list(enemies, diff)
		
	if event_overlay != null:
		event_overlay.visible = false
	_update_battle_ui_visibility(false)

func _get_enemy_texture(e_name: String) -> Texture2D:
	var key: String = e_name.strip_edges().to_lower()
	var all_dicts: Array = [CHAPTER_1_ENEMY_TEXTURES, CHAPTER_2_ENEMY_TEXTURES, CHAPTER_3_ENEMY_TEXTURES]
	for d in all_dicts:
		if d.has(key):
			return d[key]
	for d in all_dicts:
		for k in d.keys():
			if k in key or key in k:
				return d[k]
	return CHAPTER_1_ENEMY_TEXTURES.get("peasant militia scout")

func _get_enemy_preview_stats(e_name: String, index: int) -> Dictionary:
	var max_hp = 14 + (index * 6)
	var dmg = 4 + (index * 2)
	var role = "Hostile Combatant"

	if e_name.contains("Alden"):
		max_hp = 58
		dmg = 7
		role = "Arch-Betrayer (Boss)"
	elif e_name.contains("Malakor"):
		max_hp = 38
		dmg = 6
		role = "High Inquisitor"
	elif e_name.contains("Golem"):
		max_hp = 32
		dmg = 6
		role = "Animated Construct"
	elif e_name.contains("Lorian") or e_name.contains("Vane"):
		max_hp = 32
		dmg = 6
		role = "Elite Inquisitor"
	elif e_name.contains("Knight") or e_name.contains("Champion"):
		max_hp = 26
		dmg = 5
		role = "Armored Vanguard"
	elif e_name.contains("Captain") or e_name.contains("Boros"):
		max_hp = 34
		dmg = 6
		role = "Garrison Commander"
	elif e_name.contains("Crossbow") or e_name.contains("Bowman") or e_name.contains("Arbalestier"):
		role = "Ranged Marksman"
	elif e_name.contains("Scout"):
		role = "Frontier Scout"
	elif e_name.contains("Hound"):
		role = "War Beast"
	elif e_name.contains("Vanguard"):
		role = "Frontline Vanguard"
	elif e_name.contains("Halberdier"):
		role = "Polearm Sentinel"
	elif e_name.contains("Templar"):
		role = "Holy Zealot"
	elif e_name.contains("Farmer") or e_name.contains("Townsperson"):
		role = "Armed Militia"

	return {
		"hp": max_hp,
		"dmg": dmg,
		"role": role
	}

func _populate_enemy_list(active_enemies: Array, diff_str: String) -> void:
	if difficulty_label != null:
		difficulty_label.text = "DIFFICULTY: %s" % diff_str.to_upper()
		
	if difficulty_badge != null:
		var badge_style = difficulty_badge.get_theme_stylebox("panel")
		if badge_style is StyleBoxFlat:
			var flat = badge_style.duplicate() as StyleBoxFlat
			var diff_lower = diff_str.to_lower()
			if diff_lower == "boss":
				flat.border_color = Color(0.95, 0.28, 0.28, 0.95)
				difficulty_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
			elif diff_lower == "elite" or diff_lower == "hard":
				flat.border_color = Color(0.98, 0.62, 0.22, 0.95)
				difficulty_label.add_theme_color_override("font_color", Color(1.0, 0.72, 0.35))
			else:
				flat.border_color = Color(0.68, 0.55, 0.3, 0.85)
				difficulty_label.add_theme_color_override("font_color", Color(0.96, 0.84, 0.45))
			difficulty_badge.add_theme_stylebox_override("panel", flat)

	if details_label != null:
		var details_text: String = "Difficulty: %s\n\nHostile Lineup:\n" % diff_str
		for enemy in active_enemies:
			details_text += "• %s\n" % str(enemy)
		details_label.text = details_text

	if enemy_list_container == null:
		return

	# Clear previous cards
	for child in enemy_list_container.get_children():
		child.queue_free()

	# Create styled card for each enemy
	for i in range(active_enemies.size()):
		var enemy_name = str(active_enemies[i])
		var stats = _get_enemy_preview_stats(enemy_name, i)
		var tex = _get_enemy_texture(enemy_name)

		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(195, 255)
		
		var card_style = StyleBoxFlat.new()
		card_style.bg_color = Color(0.06, 0.05, 0.08, 0.92)
		card_style.border_width_left = 1
		card_style.border_width_top = 1
		card_style.border_width_right = 1
		card_style.border_width_bottom = 1
		card_style.border_color = Color(0.48, 0.40, 0.28, 0.8)
		card_style.corner_radius_top_left = 8
		card_style.corner_radius_top_right = 8
		card_style.corner_radius_bottom_right = 8
		card_style.corner_radius_bottom_left = 8
		card_style.shadow_color = Color(0, 0, 0, 0.55)
		card_style.shadow_size = 6
		card_style.content_margin_left = 10
		card_style.content_margin_right = 10
		card_style.content_margin_top = 10
		card_style.content_margin_bottom = 10
		card.add_theme_stylebox_override("panel", card_style)

		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 6)
		card.add_child(vbox)

		# Portrait box
		var portrait_panel = PanelContainer.new()
		portrait_panel.custom_minimum_size = Vector2(175, 130)
		portrait_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		var p_style = StyleBoxFlat.new()
		p_style.bg_color = Color(0.03, 0.025, 0.04, 0.95)
		p_style.border_width_left = 1
		p_style.border_width_top = 1
		p_style.border_width_right = 1
		p_style.border_width_bottom = 1
		p_style.border_color = Color(0.32, 0.28, 0.22, 0.7)
		p_style.corner_radius_top_left = 6
		p_style.corner_radius_top_right = 6
		p_style.corner_radius_bottom_right = 6
		p_style.corner_radius_bottom_left = 6
		portrait_panel.add_theme_stylebox_override("panel", p_style)

		var sprite_rect = TextureRect.new()
		sprite_rect.texture = tex
		sprite_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		sprite_rect.custom_minimum_size = Vector2(175, 130)
		portrait_panel.add_child(sprite_rect)
		vbox.add_child(portrait_panel)

		# Name Label
		var name_lbl = Label.new()
		name_lbl.text = enemy_name.to_upper()
		name_lbl.add_theme_font_override("font", CINZEL_BOLD)
		name_lbl.add_theme_font_size_override("font_size", 13)
		name_lbl.add_theme_color_override("font_color", Color(0.96, 0.91, 0.78, 1))
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_lbl.custom_minimum_size = Vector2(175, 34)
		vbox.add_child(name_lbl)

		# Role Label
		var role_lbl = Label.new()
		role_lbl.text = stats.role
		role_lbl.add_theme_font_override("font", CRIMSON_ITALIC)
		role_lbl.add_theme_font_size_override("font_size", 13)
		role_lbl.add_theme_color_override("font_color", Color(0.76, 0.72, 0.65, 0.9))
		role_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(role_lbl)

		# Stats HBox
		var stats_hbox = HBoxContainer.new()
		stats_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		stats_hbox.add_theme_constant_override("separation", 14)

		var hp_lbl = Label.new()
		hp_lbl.text = "❤ %d HP" % stats.hp
		hp_lbl.add_theme_font_override("font", CINZEL_SEMIBOLD)
		hp_lbl.add_theme_font_size_override("font_size", 12)
		hp_lbl.add_theme_color_override("font_color", Color(0.95, 0.42, 0.42, 1))
		stats_hbox.add_child(hp_lbl)

		var dmg_lbl = Label.new()
		dmg_lbl.text = "⚔ %d ATK" % stats.dmg
		dmg_lbl.add_theme_font_override("font", CINZEL_SEMIBOLD)
		dmg_lbl.add_theme_font_size_override("font_size", 12)
		dmg_lbl.add_theme_color_override("font_color", Color(0.95, 0.78, 0.45, 1))
		stats_hbox.add_child(dmg_lbl)

		vbox.add_child(stats_hbox)
		enemy_list_container.add_child(card)

func show_event(lines: Array) -> void:
	event_lines = lines
	current_event_line_index = 0
	_last_advance_msec = Time.get_ticks_msec() + 200
	if event_lines.size() > 0:
		event_overlay.visible = true
		_update_battle_ui_visibility(true)
		display_event_line()
	else:
		event_overlay.visible = false
		_update_battle_ui_visibility(false)

func display_event_line() -> void:
	if current_event_line_index < event_lines.size():
		var line = event_lines[current_event_line_index]
		event_speaker_label.text = line.get("speaker", "Tutorial")
		event_message_label.text = line.get("text", "")
	else:
		event_overlay.visible = false
		_update_battle_ui_visibility(false)

func advance_event() -> void:
	current_event_line_index += 1
	display_event_line()

func _on_finish_pressed() -> void:
	print("Beginning Battle: Transitioning to Battle Arena...")
	var params: Dictionary = GameManager.active_params.duplicate()
	if current_encounter != null:
		params["encounter_tres"] = current_encounter.resource_path
		params["encounter_id"] = current_encounter.id
		params["is_tutorial"] = current_encounter.id == "ch1_battle_tutorial" or current_encounter.difficulty.to_lower() == "tutorial"
		params["tutorial_dialog"] = current_encounter.tutorial_dialog
		if not current_encounter.next_dialog_id.is_empty():
			params["next_dialog_id"] = current_encounter.next_dialog_id
	GameManager.switch_state(GameManager.GameState.BATTLE_ARENA, params)

func _execute_battle_completion() -> void:
	print("Battle Completed successfully!")
	GameManager.complete_crusade_node()
	if current_encounter != null:
		if not current_encounter.next_dialog_id.is_empty():
			var ch = GameManager.active_params.get("chapter", "chapter_1")
			GameManager.switch_state(GameManager.GameState.DIALOG, {
				"chapter": ch,
				"dialog_id": current_encounter.next_dialog_id
			})
			return
		elif current_encounter.next_state == GameManager.GameState.WORLD_MAP or current_encounter.return_to_map:
			GameManager.switch_state(GameManager.GameState.WORLD_MAP, {
				"chapter": GameManager.active_params.get("chapter", "chapter_1"),
				"completed_encounter": current_encounter.id
			})
			return
			
	# Fallback
	var next_dialog: String = GameManager.active_params.get("next_dialog_id", "")
	if not next_dialog.is_empty():
		GameManager.switch_state(GameManager.GameState.DIALOG, {
			"chapter": GameManager.active_params.get("chapter", "chapter_1"),
			"dialog_id": next_dialog
		})
	else:
		GameManager.switch_state(GameManager.GameState.WORLD_MAP, {
			"chapter": GameManager.active_params.get("chapter", "chapter_1")
		})

func _on_retreat_pressed() -> void:
	if not _can_retreat():
		print("Retreat is disabled for this encounter.")
		return
	print("Retreating from battle...")
	GameManager.cancel_crusade_node()
	GameManager.switch_state(GameManager.GameState.WORLD_MAP, {
		"chapter": GameManager.active_params.get("chapter", "chapter_1")
	})
