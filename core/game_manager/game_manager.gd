extends Node

# Global game state manager

enum GameState {
	COVER,
	WORLD_MAP,
	BATTLEFIELD,
	DIALOG,
	CREDITS,
	BATTLE_ARENA
}

const SCENE_PATHS = {
	GameState.COVER: "res://cover/cover.tscn",
	GameState.WORLD_MAP: "res://world_map/world_map.tscn",
	GameState.BATTLEFIELD: "res://battlefield/battlefield.tscn",
	GameState.DIALOG: "res://dialog/dialog.tscn",
	GameState.CREDITS: "res://credits/credits.tscn",
	GameState.BATTLE_ARENA: "res://battlefield/battle_arena/battle_arena.tscn"
}

signal state_changed(new_state: GameState)

var current_state: GameState = GameState.COVER
var active_params: Dictionary = {}
var active_profile: AreaProfile = null
var active_deck: DeckData = null

## Global debug flags
@export var debug_battle_skip: bool = true

const SAVE_PATH = "user://crusade_save.json"

var crusade_cleared_node_ids: Array = []
var crusade_current_node_id: String = ""
var crusade_pending_node_id: String = ""
var crusade_chapter_key: String = ""
var crusade_hero_hp: int = 30
var crusade_max_hp: int = 30

func start_crusade_node(node_id: String) -> void:
	crusade_pending_node_id = node_id

func complete_crusade_node() -> void:
	var target_node = crusade_pending_node_id
	if target_node.is_empty():
		target_node = active_params.get("pending_node_id", "")
		
	if not target_node.is_empty():
		if not crusade_cleared_node_ids.has(target_node):
			crusade_cleared_node_ids.append(target_node)
		crusade_current_node_id = target_node
		crusade_pending_node_id = ""
	save_crusade()

func cancel_crusade_node() -> void:
	crusade_pending_node_id = ""

func reset_crusade(start_node_id: String = "node_0_start") -> void:
	crusade_cleared_node_ids = [start_node_id] if not start_node_id.is_empty() else []
	crusade_current_node_id = start_node_id
	crusade_pending_node_id = ""
	crusade_hero_hp = 30
	crusade_max_hp = 30
	var starter = load("res://core/cards/data/starter_vanguard_deck.tres") as DeckData
	if starter != null:
		var d = DeckData.new()
		d.deck_name = starter.deck_name
		d.cards = starter.cards.duplicate()
		active_deck = d

func has_saved_crusade() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_crusade() -> void:
	var ch = crusade_chapter_key
	if ch.is_empty():
		ch = active_params.get("chapter", "chapter_1")
	var map_path = active_params.get("map_data_tres", "res://world_map/data/%s_map_data.tres" % ch.replace("chapter_", "ch"))
	
	var deck_cards_data: Array[Dictionary] = []
	if active_deck != null:
		for c in active_deck.cards:
			if c != null:
				deck_cards_data.append({
					"id": c.id,
					"path": c.resource_path,
					"is_upgraded": c.is_upgraded
				})
	
	var save_data: Dictionary = {
		"version": 1,
		"chapter": ch,
		"map_data_tres": map_path,
		"current_node_id": crusade_current_node_id,
		"cleared_node_ids": crusade_cleared_node_ids,
		"hero_hp": crusade_hero_hp,
		"max_hp": crusade_max_hp,
		"deck_cards": deck_cards_data,
		"timestamp": Time.get_unix_time_from_system()
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		print("Crusade auto-saved: ", ch, " at node ", crusade_current_node_id, " (HP: ", crusade_hero_hp, "/", crusade_max_hp, ", Deck: ", deck_cards_data.size(), " cards)")

func load_and_resume_crusade() -> bool:
	if not has_saved_crusade():
		return false
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var text = file.get_as_text()
	file.close()
	var json = JSON.new()
	if json.parse(text) != OK:
		return false
	var data = json.get_data()
	if not data is Dictionary:
		return false
		
	crusade_chapter_key = data.get("chapter", "chapter_1")
	crusade_current_node_id = data.get("current_node_id", "node_0_start")
	var raw_cleared = data.get("cleared_node_ids", [])
	crusade_cleared_node_ids = raw_cleared if raw_cleared is Array else []
	crusade_pending_node_id = ""
	crusade_hero_hp = data.get("hero_hp", 30)
	crusade_max_hp = data.get("max_hp", 30)
	
	# Restore active deck
	var saved_cards = data.get("deck_cards", [])
	if saved_cards is Array and saved_cards.size() > 0:
		var loaded_deck = DeckData.new()
		loaded_deck.deck_name = "Player Crusade Deck"
		for c_info in saved_cards:
			var path = c_info.get("path", "")
			var card_id = c_info.get("id", "")
			var is_up = c_info.get("is_upgraded", false)
			var base_card: CardData = null
			if not path.is_empty() and ResourceLoader.exists(path):
				base_card = load(path) as CardData
			elif not card_id.is_empty():
				var clean_id = card_id.replace("_plus", "")
				var res_path = "res://core/cards/data/%s.tres" % clean_id
				if ResourceLoader.exists(res_path):
					base_card = load(res_path) as CardData
			if base_card != null:
				if is_up:
					loaded_deck.cards.append(CardUpgradeModel.upgrade_card(base_card))
				else:
					loaded_deck.cards.append(base_card)
		active_deck = loaded_deck
	elif active_deck == null:
		var starter = load("res://core/cards/data/starter_vanguard_deck.tres") as DeckData
		if starter != null:
			var d = DeckData.new()
			d.deck_name = starter.deck_name
			d.cards = starter.cards.duplicate()
			active_deck = d
	
	var map_tres = data.get("map_data_tres", "")
	if map_tres.is_empty() or not ResourceLoader.exists(map_tres):
		map_tres = "res://world_map/data/%s_map_data.tres" % crusade_chapter_key.replace("chapter_", "ch")
		
	switch_state(GameState.WORLD_MAP, {
		"chapter": crusade_chapter_key,
		"map_data_tres": map_tres,
		"hero_hp": crusade_hero_hp,
		"max_hp": crusade_max_hp,
		"current_node_id": crusade_current_node_id,
		"cleared_node_ids": crusade_cleared_node_ids
	})
	return true

func clear_saved_crusade() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("Crusade save cleared.")

var _fade_layer: CanvasLayer
var _fade_rect: ColorRect
var _is_transitioning: bool = false

func is_transitioning() -> bool:
	return _is_transitioning

func _ready() -> void:
	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 128
	
	_fade_rect = ColorRect.new()
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.color = Color(0.02, 0.03, 0.05, 1.0)
	_fade_rect.modulate.a = 0.0
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_fade_layer.add_child(_fade_rect)
	add_child(_fade_layer)

func apply_profile(profile: AreaProfile, immediate: bool = false) -> void:
	if profile == null:
		return
	active_profile = profile
	if profile.deck != null:
		active_deck = profile.deck
	elif active_deck == null:
		active_deck = load("res://core/cards/data/starter_vanguard_deck.tres") as DeckData
		
	var params: Dictionary = {
		"chapter": profile.get_chapter_key(),
		"dialog_id": profile.get_dialog_key(),
		"encounter_index": profile.encounter_index,
		"zone": profile.zone
	}
	if not profile.map_data_tres.is_empty():
		params["map_data_tres"] = profile.map_data_tres
	if not profile.encounter_tres.is_empty():
		params["encounter_tres"] = profile.encounter_tres
		
	switch_state(profile.target_state, params, immediate)

func switch_state(new_state: GameState, params: Dictionary = {}, immediate: bool = false) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	current_state = new_state
	active_params = params
	state_changed.emit(new_state)
	
	var scene_path = SCENE_PATHS.get(new_state, "")
	if scene_path == "":
		push_error("Scene path not found for state: " + str(new_state))
		_is_transitioning = false
		return
		
	if immediate or _fade_rect == null:
		await get_tree().process_frame
		get_tree().change_scene_to_file(scene_path)
		await get_tree().process_frame
		if _fade_rect != null:
			_fade_rect.modulate.a = 0.0
			_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_is_transitioning = false
		return
		
	# Fade to black
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var fade_out = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	fade_out.tween_property(_fade_rect, "modulate:a", 1.0, 0.22)
	await fade_out.finished
	
	# Change active scene
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	
	# Fade in from black
	var fade_in = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fade_in.tween_property(_fade_rect, "modulate:a", 0.0, 0.28)
	await fade_in.finished
	if _fade_rect != null:
		_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_is_transitioning = false


