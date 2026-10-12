class_name TutorialBattle
extends Control

const DeckTrayScript = preload("res://battlefield/deck_tray/deck_tray.gd")

@export var encounter_resource: EncounterData = preload("res://battlefield/data/ch1_battle_tutorial.tres")
@export var starter_deck: DeckData = preload("res://core/cards/data/starter_vanguard_deck.tres")

@onready var title_label: Label = $HeaderPanel/Title
@onready var objective_label: Label = $ObjectivePanel/ObjectiveLabel
@onready var start_button: Button = $ActionContainer/StartButton
@onready var soul_crypt_button: Button = $SoulCryptButton if has_node("SoulCryptButton") else $ActionContainer/SoulCryptButton
@onready var debug_skip_button: Button = $DebugSkipButton
@onready var background_texture: TextureRect = $BackgroundTexture
@onready var deck_tray: DeckTrayScript = $DeckTray

@onready var event_overlay: ColorRect = $EventOverlay
@onready var event_speaker_label: Label = $EventOverlay/Panel/SpeakerLabel
@onready var event_message_label: Label = $EventOverlay/Panel/MessageLabel

var event_lines: Array = []
var current_event_line_index: int = 0
var _last_advance_msec: int = 0

func _ready() -> void:
	start_button.pressed.connect(_on_start_battle_pressed)
	if soul_crypt_button != null:
		soul_crypt_button.pressed.connect(_on_soul_crypt_pressed)
	
	if debug_skip_button != null:
		debug_skip_button.visible = GameManager.debug_battle_skip
		debug_skip_button.pressed.connect(_on_debug_skip_pressed)
		
	if encounter_resource != null:
		title_label.text = encounter_resource.title
		if encounter_resource.bg_texture != null:
			background_texture.texture = encounter_resource.bg_texture
	if event_overlay != null:
		event_overlay.visible = false

func _on_soul_crypt_pressed() -> void:
	if deck_tray != null:
		var deck = GameManager.active_deck if GameManager.active_deck != null else starter_deck
		deck_tray.open(deck)

func show_tutorial_dialog(lines: Array) -> void:
	event_lines = lines
	current_event_line_index = 0
	_last_advance_msec = Time.get_ticks_msec() + 200
	if event_lines.size() > 0:
		event_overlay.visible = true
		display_current_line()
	else:
		event_overlay.visible = false

func display_current_line() -> void:
	if current_event_line_index < event_lines.size():
		var line = event_lines[current_event_line_index]
		event_speaker_label.text = line.get("speaker", "Tutorial")
		event_message_label.text = line.get("text", "")
	else:
		event_overlay.visible = false

func advance_dialog() -> void:
	current_event_line_index += 1
	display_current_line()

func _input(event: InputEvent) -> void:
	if deck_tray != null and deck_tray.visible:
		return
	if not event_overlay.visible:
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
	advance_dialog()
	get_viewport().set_input_as_handled()

func _on_start_battle_pressed() -> void:
	print("Tutorial Battle: Commencing combat phase in Battle Arena!")
	var params: Dictionary = {
		"encounter_tres": encounter_resource.resource_path if encounter_resource != null else "res://battlefield/data/ch1_battle_tutorial.tres",
		"encounter_id": encounter_resource.id if encounter_resource != null else "ch1_battle_tutorial",
		"chapter": "chapter_1",
		"is_tutorial": true,
		"tutorial_dialog": encounter_resource.tutorial_dialog if encounter_resource != null else []
	}
	GameManager.switch_state(GameManager.GameState.BATTLE_ARENA, params)

func _on_debug_skip_pressed() -> void:
	print("[DEBUG] Tutorial Battle skipped.")
	GameManager.complete_crusade_node()
	GameManager.switch_state(GameManager.GameState.WORLD_MAP, {
		"chapter": "chapter_1",
		"completed_encounter": encounter_resource.id if encounter_resource != null else "ch1_battle_tutorial"
	})
