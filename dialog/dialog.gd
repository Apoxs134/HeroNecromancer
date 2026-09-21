extends Control

@onready var bg_rect: ColorRect = $Background
@onready var illustration_rect: TextureRect = $IllustrationRect
@onready var dialog_panel: Panel = $DialogPanel
@onready var speaker_label: Label = $DialogPanel/SpeakerLabel
@onready var message_label: Label = $DialogPanel/MessageLabel
@onready var next_button: Button = $DialogPanel/NextButton
@onready var skip_button: Button = $SkipButton
@onready var system_popup: Panel = $SystemPopup
@onready var popup_title: Label = $SystemPopup/PopupTitle
@onready var popup_message: Label = $SystemPopup/PopupMessage
@onready var popup_button: Button = $SystemPopup/PopupButton
@onready var claim_card_modal: ClaimCardModal = $ClaimCardModal
@onready var chapter_splash: ChapterSplash = $ChapterSplash
@onready var transition_curtain: ColorRect = $TransitionCurtain

const DEFAULT_PANEL_PATH: String = "res://dialog/assets/default_panel.svg"

var _dialog_cache: Dictionary = {}
var _texture_cache: Dictionary = {}
var _current_dialog: Dictionary = {}
var current_line_index: int = 0
var _current_panel: String = ""
var _active_chapter: String = ""
var _is_transitioning: bool = false

func _ready() -> void:
	dialog_panel.visible = false
	skip_button.visible = false
	message_label.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	next_button.pressed.connect(_on_next_pressed)
	skip_button.pressed.connect(_on_skip_pressed)
	popup_button.pressed.connect(_on_popup_button_pressed)
	claim_card_modal.dismissed.connect(_on_claim_modal_dismissed)
	
	var chapter: String = GameManager.active_params.get("chapter", "chapter_0")
	var dialog_id: String = GameManager.active_params.get("dialog_id", "intro_scene")
	start_dialog(chapter, dialog_id)

func _input(event: InputEvent) -> void:
	if _is_transitioning:
		return
	if chapter_splash and chapter_splash.visible:
		return
	if claim_card_modal and claim_card_modal.visible:
		return
		
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER)):
		if system_popup.visible:
			_on_popup_button_pressed()
		else:
			_on_next_pressed()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if system_popup.visible:
			if popup_button.get_global_rect().has_point(event.global_position):
				return
			return
		if skip_button.get_global_rect().has_point(event.global_position):
			return
		if next_button.get_global_rect().has_point(event.global_position):
			return
		_on_next_pressed()

func start_dialog(chapter: String, dialog_id: String) -> void:
	_active_chapter = chapter
	current_line_index = 0
	_current_panel = ""
	system_popup.visible = false
	dialog_panel.visible = false
	skip_button.visible = false
	
	_current_dialog = _load_dialog_data(chapter, dialog_id)
	if _current_dialog.is_empty():
		speaker_label.text = "System"
		message_label.text = "Dialogue data not found for: %s / %s" % [chapter, dialog_id]
		next_button.text = "Return"
		dialog_panel.visible = true
		skip_button.visible = true
		return
		
	var raw_color = _current_dialog.get("background_color", [0.08, 0.09, 0.11, 1.0])
	if raw_color is Array and raw_color.size() >= 4:
		bg_rect.color = Color(raw_color[0], raw_color[1], raw_color[2], raw_color[3])

	# Pre-load initial illustration from line 0 so there is no texture popping
	var lines: Array = _current_dialog.get("lines", [])
	var first_panel: String = DEFAULT_PANEL_PATH
	if lines.size() > 0 and lines[0].has("panel"):
		first_panel = lines[0].get("panel", DEFAULT_PANEL_PATH)
	_set_illustration_immediate(first_panel)
		
	if _current_dialog.has("splash"):
		dialog_panel.visible = false
		skip_button.visible = false
		var splash_info = _current_dialog.get("splash", {})
		chapter_splash.play_splash(splash_info.get("title", "PROLOGUE"), splash_info.get("subtitle", ""))
		await chapter_splash.finished
		dialog_panel.visible = true
		skip_button.visible = true
	else:
		dialog_panel.visible = true
		skip_button.visible = true
		
	display_current_line()

func _set_illustration_immediate(panel_path: String) -> void:
	var target_path: String = panel_path
	if target_path.is_empty() or not ResourceLoader.exists(target_path):
		target_path = DEFAULT_PANEL_PATH
		
	_current_panel = target_path
	if not _texture_cache.has(target_path):
		if ResourceLoader.exists(target_path):
			_texture_cache[target_path] = load(target_path) as Texture2D
	illustration_rect.texture = _texture_cache.get(target_path, null)
	illustration_rect.modulate.a = 1.0


func _load_dialog_data(chapter: String, dialog_id: String) -> Dictionary:
	var path: String = "res://dialog/data/%s.json" % chapter
	if not _dialog_cache.has(chapter):
		if not FileAccess.file_exists(path):
			push_error("Dialog file does not exist: %s" % path)
			return {}
		var file = FileAccess.open(path, FileAccess.READ)
		var json_string = file.get_as_text()
		var parsed = JSON.parse_string(json_string)
		if parsed is Dictionary:
			_dialog_cache[chapter] = parsed
		else:
			push_error("Failed to parse dialog JSON: %s" % path)
			return {}
			
	var chapter_data: Dictionary = _dialog_cache.get(chapter, {})
	return chapter_data.get(dialog_id, {})

var _typewriter_tween: Tween = null
var _is_typing: bool = false

func display_current_line() -> void:
	var lines: Array = _current_dialog.get("lines", [])
	
	if current_line_index < lines.size():
		var line: Dictionary = lines[current_line_index]
		var speaker: String = line.get("speaker", "")
		var text_content: String = line.get("text", "")
		
		if line.has("panel"):
			_update_illustration(line.get("panel", ""))
			
		if line.get("shake", false):
			_trigger_screen_shake()
			
		if line.get("claim_starter_deck", false):
			dialog_panel.visible = false
			system_popup.visible = false
			var pale_smite = load("res://core/cards/data/pale_smite.tres") as CardData
			var grave_ward = load("res://core/cards/data/grave_ward.tres") as CardData
			var vargas_bulwark = load("res://core/cards/data/vargas_bulwark.tres") as CardData
			var kaelen_volley = load("res://core/cards/data/kaelen_volley.tres") as CardData
			var starter_cards: Array[CardData] = [pale_smite, grave_ward, vargas_bulwark, kaelen_volley]
			claim_card_modal.show_reward(starter_cards, "THE FALLEN VANGUARD", "Starter Deck Acquired: 10 Cards added to your Grimoire:")
			return

		if speaker == "System" or line.get("popup", false):
			dialog_panel.visible = false
			system_popup.visible = true
			popup_title.text = line.get("title", "SYSTEM NOTICE")
			popup_message.text = text_content
			popup_button.text = line.get("button_text", "Claim & Continue")
			return
		else:
			dialog_panel.visible = true
			system_popup.visible = false
			
		speaker_label.text = speaker
		message_label.text = text_content
		_start_typewriter(text_content)
		
		if current_line_index == lines.size() - 1:
			next_button.text = "Finish"
		else:
			next_button.text = "Next"
	else:
		_end_dialog()

func _on_claim_modal_dismissed() -> void:
	var next_ch: String = _current_dialog.get("next_chapter", "")
	if not next_ch.is_empty():
		transition_to_dialog(next_ch, "intro_scene")
	elif _active_chapter == "chapter_0":
		transition_to_dialog("chapter_1", "intro_scene")
	else:
		_end_dialog()

func transition_to_dialog(chapter: String, dialog_id: String) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	
	if _typewriter_tween and _typewriter_tween.is_valid():
		_typewriter_tween.kill()
		_is_typing = false
		
	# Fade out current dialog screen to black
	transition_curtain.mouse_filter = Control.MOUSE_FILTER_STOP
	var fade_out = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	fade_out.tween_property(transition_curtain, "modulate:a", 1.0, 0.22)
	await fade_out.finished
	
	# While curtain is 100% black, load and prepare the new dialog
	var next_data: Dictionary = _load_dialog_data(chapter, dialog_id)
	var has_splash: bool = next_data.has("splash")
	
	if has_splash:
		# Reset curtain to 0 behind splash since splash backdrop is solid black
		transition_curtain.modulate.a = 0.0
		transition_curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE
		await start_dialog(chapter, dialog_id)
	else:
		start_dialog(chapter, dialog_id)
		var fade_in = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		fade_in.tween_property(transition_curtain, "modulate:a", 0.0, 0.25)
		await fade_in.finished
		transition_curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
	_is_transitioning = false

func _on_popup_button_pressed() -> void:
	system_popup.visible = false
	dialog_panel.visible = true
	current_line_index += 1
	var lines: Array = _current_dialog.get("lines", [])
	if current_line_index < lines.size():
		display_current_line()
	else:
		_end_dialog()

func _start_typewriter(text_content: String) -> void:
	if _typewriter_tween and _typewriter_tween.is_valid():
		_typewriter_tween.kill()
		
	message_label.visible_ratio = 0.0
	_is_typing = true
	
	var duration: float = clampf(text_content.length() * 0.022, 0.35, 1.8)
	_typewriter_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	_typewriter_tween.tween_property(message_label, "visible_ratio", 1.0, duration)
	_typewriter_tween.tween_callback(func(): _is_typing = false)

func _trigger_screen_shake() -> void:
	var shake_tween = create_tween()
	var orig_pos = illustration_rect.position
	for i in 4:
		var offset = Vector2(randf_range(-8.0, 8.0), randf_range(-8.0, 8.0))
		shake_tween.tween_property(illustration_rect, "position", orig_pos + offset, 0.04)
	shake_tween.tween_property(illustration_rect, "position", orig_pos, 0.04)

func _update_illustration(panel_path: String) -> void:
	var target_path: String = panel_path
	if target_path.is_empty() or not ResourceLoader.exists(target_path):
		target_path = DEFAULT_PANEL_PATH
		
	if target_path == _current_panel and illustration_rect.texture != null:
		return
	_current_panel = target_path
	
	if not _texture_cache.has(target_path):
		if ResourceLoader.exists(target_path):
			_texture_cache[target_path] = load(target_path) as Texture2D
		else:
			return
			
	var new_tex: Texture2D = _texture_cache.get(target_path, null)
	if new_tex == null:
		return
		
	if illustration_rect.texture == new_tex:
		return
		
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(illustration_rect, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func(): illustration_rect.texture = new_tex)
	tween.tween_property(illustration_rect, "modulate:a", 1.0, 0.3)

func _on_next_pressed() -> void:
	if _is_transitioning:
		return
	if _is_typing:
		if _typewriter_tween and _typewriter_tween.is_valid():
			_typewriter_tween.kill()
		message_label.visible_ratio = 1.0
		_is_typing = false
		return
		
	current_line_index += 1
	var lines: Array = _current_dialog.get("lines", [])
	if current_line_index < lines.size():
		display_current_line()
	else:
		_end_dialog()

func _on_skip_pressed() -> void:
	if _is_transitioning:
		return
	if _typewriter_tween and _typewriter_tween.is_valid():
		_typewriter_tween.kill()
		_is_typing = false

	# Auto-claim starter deck if skipping before manual claim
	if _active_chapter == "chapter_0" and GameManager.active_deck == null:
		GameManager.active_deck = load("res://core/cards/data/starter_vanguard_deck.tres") as DeckData

	_advance_to_next_sequence()

func _end_dialog() -> void:
	if _is_transitioning:
		return
	if _typewriter_tween and _typewriter_tween.is_valid():
		_typewriter_tween.kill()
		_is_typing = false
		
	_advance_to_next_sequence()

func _advance_to_next_sequence() -> void:
	if _is_transitioning:
		return
	# 1. Check for chained chapter progression
	var next_ch: String = _current_dialog.get("next_chapter", "")
	if not next_ch.is_empty():
		print("Advancing to next chapter: %s" % next_ch)
		transition_to_dialog(next_ch, "intro_scene")
		return
		
	# 2. Check for explicit game state transition (e.g. BATTLEFIELD, COVER)
	var next_state_name: String = _current_dialog.get("next_state", "").to_upper()
	match next_state_name:
		"BATTLEFIELD":
			print("Advancing to BATTLEFIELD encounter...")
			GameManager.switch_state(GameManager.GameState.BATTLEFIELD, {
				"chapter": _active_chapter,
				"encounter_id": _current_dialog.get("encounter_id", "skirmish_1")
			})
			return
		"COVER":
			GameManager.switch_state(GameManager.GameState.COVER)
			return
		"WORLD_MAP":
			GameManager.switch_state(GameManager.GameState.WORLD_MAP)
			return
			
	# 3. Default fallback
	print("Dialogue completed. Returning to World Map.")
	GameManager.switch_state(GameManager.GameState.WORLD_MAP)



