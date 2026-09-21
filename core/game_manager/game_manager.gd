extends Node

# Global game state manager

enum GameState {
	COVER,
	WORLD_MAP,
	BATTLEFIELD,
	DIALOG
}

const SCENE_PATHS = {
	GameState.COVER: "res://cover/cover.tscn",
	GameState.WORLD_MAP: "res://world_map/world_map.tscn",
	GameState.BATTLEFIELD: "res://battlefield/battlefield.tscn",
	GameState.DIALOG: "res://dialog/dialog.tscn"
}

signal state_changed(new_state: GameState)

var current_state: GameState = GameState.COVER
var active_params: Dictionary = {}
var active_profile: AreaProfile = null
var active_deck: DeckData = null

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
		
	switch_state(profile.target_state, {
		"chapter": profile.get_chapter_key(),
		"dialog_id": profile.get_dialog_key(),
		"encounter_index": profile.encounter_index,
		"zone": profile.zone
	}, immediate)

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
		
	if immediate:
		await get_tree().process_frame
		get_tree().change_scene_to_file(scene_path)
		await get_tree().process_frame
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
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_is_transitioning = false


