extends Control

const CINZEL_BOLD = preload("res://ui/fonts/Cinzel/static/Cinzel-Bold.ttf")
const CINZEL_SEMIBOLD = preload("res://ui/fonts/Cinzel/static/Cinzel-SemiBold.ttf")
const CRIMSON_REGULAR = preload("res://ui/fonts/Crimson_Pro/static/CrimsonPro-Regular.ttf")
const CRIMSON_ITALIC = preload("res://ui/fonts/Crimson_Pro/static/CrimsonPro-MediumItalic.ttf")

const PANEL_V1_TEX = preload("res://ui/panel_v1_ui.webp")
const PANEL_V2_TEX = preload("res://ui/panel_v2_ui.webp")
const PANEL_V3_TEX = preload("res://ui/panel_v3_ui.webp")
const PANEL_V7_TEX = preload("res://ui/panel_v7_ui.webp")
const PANEL_V8_TEX = preload("res://ui/panel_v8_ui.webp")

@onready var scroll_container: ScrollContainer = $MapScrollContainer
@onready var map_content: Control = $MapScrollContainer/MapContent
@onready var map_texture: TextureRect = $MapScrollContainer/MapContent/MapTexture
@onready var path_layer: Control = $MapScrollContainer/MapContent/PathLayer
@onready var nodes_container: Control = $MapScrollContainer/MapContent/NodesContainer
@onready var header_title: Label = $HeaderPanel/Title
@onready var status_label: Label = $FooterBar/StatusLabel
@onready var back_button: Button = $BackButton

@onready var claim_card_modal: ClaimCardModal = $ClaimCardModal
@onready var bone_altar_modal: BoneAltarModal = $BoneAltarModal
@onready var tutorial_modal: ColorRect = $TutorialModal
@onready var tutorial_title: Label = $TutorialModal/ModalPanel/TutorialTitle
@onready var tutorial_body: Label = $TutorialModal/ModalPanel/TutorialBody
@onready var tutorial_dismiss: Button = $TutorialModal/ModalPanel/TutorialDismissButton

var current_map_data: MapData = null
var current_node_id: String = ""
var cleared_node_ids: Array = []
var _node_buttons: Dictionary = {}
var _pending_altar_node: MapNodeData = null

static var _has_seen_crusade_tutorial: bool = false

const DRAG_THRESHOLD: float = 12.0
var _is_dragging: bool = false
var _has_dragged: bool = false
var _drag_start_pos: Vector2 = Vector2.ZERO
var _scroll_start_val: int = 0
var _last_drag_pos_y: float = 0.0
var _last_drag_time: float = 0.0
var _drag_velocity: float = 0.0
var _momentum_tween: Tween = null

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	tutorial_dismiss.pressed.connect(_on_tutorial_dismissed)
	claim_card_modal.dismissed.connect(_on_claim_modal_dismissed)
	claim_card_modal.cards_claimed.connect(_on_cards_claimed)
	if bone_altar_modal != null:
		bone_altar_modal.altar_completed.connect(_on_altar_completed)
		
	# Ensure active deck exists for the crusade
	if GameManager.active_deck == null:
		var starter = load("res://core/cards/data/starter_vanguard_deck.tres") as DeckData
		if starter != null:
			var deck_copy = DeckData.new()
			deck_copy.deck_name = starter.deck_name
			deck_copy.cards = starter.cards.duplicate()
			GameManager.active_deck = deck_copy
	
	path_layer.draw.connect(_on_path_layer_draw)
	
	var ch = GameManager.active_params.get("chapter", "chapter_1")
	var default_map = "res://world_map/data/%s_map_data.tres" % ch.replace("chapter_", "ch")
	var map_path: String = GameManager.active_params.get("map_data_tres", default_map)
	if not ResourceLoader.exists(map_path):
		map_path = "res://world_map/data/ch1_map_data.tres"
		
	if ResourceLoader.exists(map_path):
		var res = load(map_path) as MapData
		if res != null:
			load_map_data(res)
			
	# If chapter has changed, award Act transition bonus (+5 Max HP and full heal)
	if current_map_data != null and not GameManager.crusade_chapter_key.is_empty() and GameManager.crusade_chapter_key != current_map_data.chapter_key:
		GameManager.crusade_chapter_key = current_map_data.chapter_key
		GameManager.crusade_max_hp += 5
		GameManager.crusade_hero_hp = GameManager.crusade_max_hp
		GameManager.crusade_cleared_node_ids = [current_map_data.start_node_id]
		GameManager.crusade_current_node_id = current_map_data.start_node_id
	elif current_map_data != null and GameManager.crusade_chapter_key.is_empty():
		GameManager.crusade_chapter_key = current_map_data.chapter_key
			
	# Restore persistent node progress
	var default_start: String = current_map_data.start_node_id if current_map_data else "node_0_start"
	if GameManager.crusade_cleared_node_ids.size() > 0:
		cleared_node_ids = GameManager.crusade_cleared_node_ids.duplicate()
	else:
		var raw_cleared = GameManager.active_params.get("cleared_node_ids", [])
		if raw_cleared is Array and raw_cleared.size() > 0:
			cleared_node_ids = raw_cleared.duplicate()
		else:
			cleared_node_ids = [default_start]
		GameManager.crusade_cleared_node_ids = cleared_node_ids.duplicate()
		
	if not GameManager.crusade_current_node_id.is_empty():
		current_node_id = GameManager.crusade_current_node_id
	else:
		current_node_id = GameManager.active_params.get("current_node_id", default_start)
		GameManager.crusade_current_node_id = current_node_id
	
	# Check if returning from victory in battle
	var completed = GameManager.active_params.get("completed_encounter", "")
	var pending_node = GameManager.active_params.get("pending_node_id", "")
	if not pending_node.is_empty():
		if not cleared_node_ids.has(pending_node):
			cleared_node_ids.append(pending_node)
		current_node_id = pending_node
		GameManager.crusade_current_node_id = current_node_id
		GameManager.crusade_cleared_node_ids = cleared_node_ids.duplicate()
		GameManager.active_params.erase("pending_node_id")
		status_label.text = "Victory secured! Select your next crusade path."
		GameManager.save_crusade()
		
		# If boss was cleared, transition to end dialog
		var node_data = current_map_data.get_node(current_node_id) if current_map_data else null
		if node_data != null and node_data.node_type == MapNodeData.NodeType.BOSS:
			_advance_to_end_dialog()
			return
	elif not completed.is_empty():
		status_label.text = "Victory secured! Select your next crusade path."
		var node_data = current_map_data.get_node(current_node_id) if current_map_data else null
		if node_data != null and node_data.node_type == MapNodeData.NodeType.BOSS:
			_advance_to_end_dialog()
			return
			
	_refresh_all_nodes()
	call_deferred("_scroll_to_node", current_node_id, false)

func _update_header_title() -> void:
	if current_map_data != null and header_title != null:
		header_title.text = "%s   |   ❤️ Hero HP: %d/%d" % [current_map_data.map_name, GameManager.crusade_hero_hp, GameManager.crusade_max_hp]

func load_map_data(data: MapData) -> void:
	current_map_data = data
	_update_header_title()
	if data.bg_texture != null:
		map_texture.texture = data.bg_texture
		
	tutorial_title.text = data.tutorial_title
	tutorial_body.text = data.tutorial_text
	
	if not _has_seen_crusade_tutorial and not data.tutorial_text.is_empty():
		tutorial_modal.visible = true
	else:
		tutorial_modal.visible = false
		
	_build_map_node_buttons()

func _on_tutorial_dismissed() -> void:
	_has_seen_crusade_tutorial = true
	tutorial_modal.visible = false
	status_label.text = "Select a highlighted path node to advance your Crusade."

func _get_node_stylebox(type: MapNodeData.NodeType) -> StyleBoxTexture:
	var sb = StyleBoxTexture.new()
	match type:
		MapNodeData.NodeType.COMBAT, MapNodeData.NodeType.START:
			sb.texture = PANEL_V1_TEX
			sb.texture_margin_left = 18.0
			sb.texture_margin_top = 16.0
			sb.texture_margin_right = 18.0
			sb.texture_margin_bottom = 16.0
		MapNodeData.NodeType.ELITE:
			sb.texture = PANEL_V8_TEX
			sb.texture_margin_left = 22.0
			sb.texture_margin_top = 18.0
			sb.texture_margin_right = 22.0
			sb.texture_margin_bottom = 18.0
		MapNodeData.NodeType.BOSS:
			sb.texture = PANEL_V3_TEX
			sb.texture_margin_left = 24.0
			sb.texture_margin_top = 18.0
			sb.texture_margin_right = 24.0
			sb.texture_margin_bottom = 18.0
		MapNodeData.NodeType.GRIMOIRE:
			sb.texture = PANEL_V2_TEX
			sb.texture_margin_left = 20.0
			sb.texture_margin_top = 16.0
			sb.texture_margin_right = 20.0
			sb.texture_margin_bottom = 16.0
		MapNodeData.NodeType.ALTAR:
			sb.texture = PANEL_V7_TEX
			sb.texture_margin_left = 20.0
			sb.texture_margin_top = 16.0
			sb.texture_margin_right = 20.0
			sb.texture_margin_bottom = 16.0
		_:
			sb.texture = PANEL_V1_TEX
			sb.texture_margin_left = 18.0
			sb.texture_margin_top = 16.0
			sb.texture_margin_right = 18.0
			sb.texture_margin_bottom = 16.0

	sb.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	sb.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	sb.content_margin_left = 12.0
	sb.content_margin_right = 12.0
	sb.content_margin_top = 8.0
	sb.content_margin_bottom = 8.0
	return sb

func _build_map_node_buttons() -> void:
	for child in nodes_container.get_children():
		child.queue_free()
	_node_buttons.clear()
	
	if current_map_data == null:
		return
		
	for node_data in current_map_data.nodes:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(166, 70)
		btn.position = node_data.position - Vector2(83, 35)
		btn.focus_mode = Control.FOCUS_NONE
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.add_theme_font_override("font", CINZEL_BOLD)
		btn.add_theme_font_size_override("font_size", 12)
		
		var sb = _get_node_stylebox(node_data.node_type)
		btn.add_theme_stylebox_override("normal", sb)
		btn.add_theme_stylebox_override("hover", sb)
		btn.add_theme_stylebox_override("pressed", sb)
		btn.add_theme_stylebox_override("disabled", sb)
		
		var icon_str = _get_node_icon(node_data.node_type)
		btn.text = "%s\n%s" % [icon_str, node_data.title.to_upper()]
		btn.pressed.connect(func(): _on_node_clicked(node_data.id))
		
		nodes_container.add_child(btn)
		_node_buttons[node_data.id] = btn
		
	path_layer.queue_redraw()

func _get_node_icon(type: MapNodeData.NodeType) -> String:
	match type:
		MapNodeData.NodeType.START:
			return "🕯️ ENTRY"
		MapNodeData.NodeType.COMBAT:
			return "⚔️ SKIRMISH"
		MapNodeData.NodeType.ELITE:
			return "💀 ELITE HOST"
		MapNodeData.NodeType.GRIMOIRE:
			return "📜 GRIMOIRE"
		MapNodeData.NodeType.ALTAR:
			return "🕯️ BONE ALTAR"
		MapNodeData.NodeType.BOSS:
			return "👑 FORTRESS"
		_:
			return "•"

func _refresh_all_nodes() -> void:
	if current_map_data == null:
		return
		
	var curr_node = current_map_data.get_node(current_node_id)
	var available_ids: Array = []
	if curr_node != null:
		available_ids = curr_node.connected_node_ids
		
	for node_data in current_map_data.nodes:
		var btn = _node_buttons.get(node_data.id, null) as Button
		if btn == null:
			continue
			
		var is_current = (node_data.id == current_node_id)
		var is_cleared = cleared_node_ids.has(node_data.id)
		var is_available = available_ids.has(node_data.id) and not is_cleared
		
		var icon_str = _get_node_icon(node_data.node_type)
		
		if is_current:
			btn.visible = true
			btn.disabled = true
			btn.modulate = Color(0.45, 1.0, 0.75, 1.0)
			btn.text = "📍 [ YOU ARE HERE ]\n%s" % node_data.title.to_upper()
			btn.add_theme_color_override("font_disabled_color", Color(0.9, 1.0, 0.9, 1.0))
		elif is_available:
			btn.visible = true
			btn.disabled = false
			btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
			btn.text = "%s\n%s" % [icon_str, node_data.title.to_upper()]
			match node_data.node_type:
				MapNodeData.NodeType.COMBAT:
					btn.add_theme_color_override("font_color", Color(0.96, 0.90, 0.78, 1))
					btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1))
				MapNodeData.NodeType.ELITE:
					btn.add_theme_color_override("font_color", Color(1.0, 0.72, 0.35, 1))
					btn.add_theme_color_override("font_hover_color", Color(1.0, 0.88, 0.55, 1))
				MapNodeData.NodeType.BOSS:
					btn.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45, 1))
					btn.add_theme_color_override("font_hover_color", Color(1.0, 0.7, 0.7, 1))
				MapNodeData.NodeType.GRIMOIRE:
					btn.add_theme_color_override("font_color", Color(0.55, 0.85, 1.0, 1))
					btn.add_theme_color_override("font_hover_color", Color(0.8, 0.95, 1.0, 1))
				MapNodeData.NodeType.ALTAR:
					btn.add_theme_color_override("font_color", Color(0.90, 0.65, 0.95, 1))
					btn.add_theme_color_override("font_hover_color", Color(1.0, 0.82, 1.0, 1))
				_:
					btn.add_theme_color_override("font_color", Color(0.96, 0.92, 0.82, 1))
					btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1))
		elif is_cleared:
			btn.visible = true
			btn.disabled = true
			btn.modulate = Color(0.5, 0.52, 0.56, 0.6)
			btn.text = "✓ CLEARED\n%s" % node_data.title.to_upper()
			btn.add_theme_color_override("font_disabled_color", Color(0.65, 0.68, 0.72, 0.8))
		else:
			# Unknown upcoming markers are completely hidden
			btn.visible = false
			btn.disabled = true
			
	path_layer.queue_redraw()

func _on_path_layer_draw() -> void:
	if current_map_data == null:
		return
		
	var curr_node = current_map_data.get_node(current_node_id)
	var available_ids: Array = curr_node.connected_node_ids if curr_node else []
	
	for node in current_map_data.nodes:
		for target_id in node.connected_node_ids:
			var target_node = current_map_data.get_node(target_id)
			if target_node == null:
				continue
				
			var is_active_route = (node.id == current_node_id and available_ids.has(target_id))
			var is_traveled = (cleared_node_ids.has(node.id) and cleared_node_ids.has(target_id))
			
			# Paths that cannot be used should be completely hidden
			if not is_active_route and not is_traveled:
				continue
				
			var from_pos = node.position
			var to_pos = target_node.position
			var line_color = Color(0.95, 0.35, 0.35, 0.85) if is_active_route else Color(0.3, 0.8, 0.5, 0.65)
			var line_width = 3.5 if is_active_route else 2.5
				
			# Draw dashed line with node beads (Cult of the Lamb style)
			_draw_crusade_dashed_line(from_pos, to_pos, line_color, line_width)

func _draw_crusade_dashed_line(from: Vector2, to: Vector2, color: Color, width: float) -> void:
	var dist = from.distance_to(to)
	var dir = (to - from).normalized()
	var step = 14.0
	var cursor = 0.0
	
	while cursor < dist:
		var p1 = from + dir * cursor
		var p2 = from + dir * minf(cursor + 7.0, dist)
		path_layer.draw_line(p1, p2, color, width)
		path_layer.draw_circle(p1, width * 0.8, color)
		cursor += step

func _on_node_clicked(node_id: String) -> void:
	if _has_dragged or current_map_data == null:
		return
		
	var clicked_node = current_map_data.get_node(node_id)
	if clicked_node == null:
		return
		
	var curr_node = current_map_data.get_node(current_node_id)
	var is_available = (curr_node != null and curr_node.connected_node_ids.has(node_id) and not cleared_node_ids.has(node_id))
	var is_current = (node_id == current_node_id)
	var is_cleared = cleared_node_ids.has(node_id)
	
	if is_current or is_cleared:
		status_label.text = "%s: Already secured. Choose a higher-tier node." % clicked_node.title
		return
		
	if not is_available:
		status_label.text = "Path Blocked: You may only travel along connected upward paths."
		# Shake feedback
		var btn = _node_buttons.get(node_id, null) as Button
		if btn != null:
			var orig_x = btn.position.x
			var tween = create_tween()
			tween.tween_property(btn, "position:x", orig_x - 6, 0.04)
			tween.tween_property(btn, "position:x", orig_x + 6, 0.04)
			tween.tween_property(btn, "position:x", orig_x, 0.04)
		return
		
	# Execute Node Action
	match clicked_node.node_type:
		MapNodeData.NodeType.COMBAT, MapNodeData.NodeType.ELITE:
			_trigger_combat_encounter(clicked_node)
		MapNodeData.NodeType.GRIMOIRE:
			_trigger_grimoire_shrine(clicked_node)
		MapNodeData.NodeType.ALTAR:
			_trigger_bone_altar(clicked_node)
		MapNodeData.NodeType.BOSS:
			_trigger_boss_encounter(clicked_node)

func _trigger_combat_encounter(node: MapNodeData) -> void:
	status_label.text = "Marching into battle: %s..." % node.title
	var encounter_path: String = "res://battlefield/data/ch1_tile_battle.tres"
	if node.encounter != null:
		encounter_path = node.encounter.resource_path
		
	_save_crusade_state(node.id)
	GameManager.switch_state(GameManager.GameState.BATTLEFIELD, {
		"encounter_tres": encounter_path,
		"pending_node_id": node.id,
		"chapter": current_map_data.chapter_key
	})

func _trigger_boss_encounter(node: MapNodeData) -> void:
	status_label.text = "Breaching the Granary Gates: %s..." % node.title
	if node.encounter != null:
		_save_crusade_state(node.id)
		GameManager.switch_state(GameManager.GameState.BATTLEFIELD, {
			"encounter_tres": node.encounter.resource_path,
			"pending_node_id": node.id,
			"chapter": current_map_data.chapter_key
		})
	else:
		_advance_to_end_dialog()

func _trigger_grimoire_shrine(node: MapNodeData) -> void:
	status_label.text = "Grimoire Shrine discovered: Claiming ancient knowledge... (Hero HP: %d/%d)" % [GameManager.crusade_hero_hp, GameManager.crusade_max_hp]
	if not cleared_node_ids.has(node.id):
		cleared_node_ids.append(node.id)
	current_node_id = node.id
	_save_crusade_state(node.id)
	GameManager.complete_crusade_node()
	
	var pool: Array[CardData] = [
		load("res://core/cards/data/soul_cleanse.tres") as CardData,
		load("res://core/cards/data/soul_surge.tres") as CardData,
		load("res://core/cards/data/dark_harvest.tres") as CardData,
		load("res://core/cards/data/bone_spikes.tres") as CardData,
		load("res://core/cards/data/wither_touch.tres") as CardData,
		load("res://core/cards/data/sanguine_curse.tres") as CardData,
		load("res://core/cards/data/grim_harvest.tres") as CardData,
		load("res://core/cards/data/pale_guillotine.tres") as CardData,
		load("res://core/cards/data/soul_roulette.tres") as CardData,
		load("res://core/cards/data/forbidden_rite.tres") as CardData
	]
	pool.shuffle()
	var reward_cards: Array[CardData] = [pool[0], pool[1], pool[2]]
	
	claim_card_modal.show_reward(reward_cards, "CRYPT OF THE LOST VANGUARD", "Acquired 3 forbidden spells for your Grimoire:")
	_update_header_title()
	_refresh_all_nodes()
	_scroll_to_node(node.id, true)

func _trigger_bone_altar(node: MapNodeData) -> void:
	_pending_altar_node = node
	if bone_altar_modal != null:
		bone_altar_modal.open_altar()
	else:
		_on_altar_completed("Bone Altar consecrated: Hero vitality restored.")

func _on_altar_completed(summary_text: String) -> void:
	if _pending_altar_node != null:
		var node = _pending_altar_node
		if not cleared_node_ids.has(node.id):
			cleared_node_ids.append(node.id)
		current_node_id = node.id
		_save_crusade_state(node.id)
		GameManager.complete_crusade_node()
		_pending_altar_node = null
		
	status_label.text = summary_text
	_update_header_title()
	_refresh_all_nodes()
	if current_node_id != "":
		_scroll_to_node(current_node_id, true)

func _on_cards_claimed(cards: Array[CardData]) -> void:
	if GameManager.active_deck != null:
		for card in cards:
			GameManager.active_deck.cards.append(card)
	status_label.text = "%d new card(s) bound to Grimoire. Deck size: %d." % [cards.size(), GameManager.active_deck.cards.size() if GameManager.active_deck else 0]

func _on_claim_modal_dismissed() -> void:
	status_label.text = "Spells scribed into Grimoire. Choose your next crusade path."

func _advance_to_end_dialog() -> void:
	status_label.text = "Granary secured! Concluding Chapter 1..."
	var end_dialog: String = current_map_data.end_dialog_id if current_map_data else "ending_scene"
	var ch: String = current_map_data.chapter_key if current_map_data else "chapter_1"
	GameManager.switch_state(GameManager.GameState.DIALOG, {
		"chapter": ch,
		"dialog_id": end_dialog
	})

func _save_crusade_state(pending_id: String = "") -> void:
	GameManager.crusade_cleared_node_ids = cleared_node_ids.duplicate()
	GameManager.crusade_current_node_id = current_node_id
	if not pending_id.is_empty():
		GameManager.start_crusade_node(pending_id)
		GameManager.active_params["pending_node_id"] = pending_id
	GameManager.active_params["cleared_node_ids"] = cleared_node_ids
	GameManager.active_params["current_node_id"] = current_node_id
	GameManager.save_crusade()

func _on_back_pressed() -> void:
	_save_crusade_state(current_node_id)
	GameManager.switch_state(GameManager.GameState.COVER)

func _scroll_to_node(node_id: String, smooth: bool = true) -> void:
	if current_map_data == null or scroll_container == null or map_content == null:
		return
	var node_data = current_map_data.get_node(node_id)
	if node_data == null:
		return
	var viewport_h = scroll_container.size.y if scroll_container.size.y > 0 else 720.0
	var target_y = node_data.position.y - (viewport_h * 0.5)
	var max_scroll = map_content.custom_minimum_size.y - viewport_h
	var target_scroll = int(clampf(target_y, 0.0, max(0.0, max_scroll)))
	
	if smooth:
		var tween = create_tween()
		tween.tween_property(scroll_container, "scroll_vertical", target_scroll, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		scroll_container.scroll_vertical = target_scroll

func _input(event: InputEvent) -> void:
	if (claim_card_modal != null and claim_card_modal.visible) or (tutorial_modal != null and tutorial_modal.visible) or (bone_altar_modal != null and bone_altar_modal.visible):
		return
		
	if event is InputEventScreenTouch:
		if event.pressed:
			_start_drag(event.position)
		else:
			_end_drag()
	elif event is InputEventScreenDrag:
		_process_drag(event.position)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drag(event.global_position)
			else:
				_end_drag()
	elif event is InputEventMouseMotion and _is_dragging:
		_process_drag(event.global_position)

func _start_drag(pos: Vector2) -> void:
	_is_dragging = true
	_has_dragged = false
	_drag_start_pos = pos
	_scroll_start_val = scroll_container.scroll_vertical
	_last_drag_pos_y = pos.y
	_last_drag_time = Time.get_ticks_msec() / 1000.0
	_drag_velocity = 0.0
	if _momentum_tween and _momentum_tween.is_valid():
		_momentum_tween.kill()

func _process_drag(pos: Vector2) -> void:
	if not _is_dragging:
		return
	var delta_y = pos.y - _drag_start_pos.y
	if abs(delta_y) > DRAG_THRESHOLD:
		_has_dragged = true
		
	var now = Time.get_ticks_msec() / 1000.0
	var dt = now - _last_drag_time
	if dt > 0.001:
		var instant_v = (pos.y - _last_drag_pos_y) / dt
		_drag_velocity = lerpf(_drag_velocity, instant_v, 0.45)
	_last_drag_pos_y = pos.y
	_last_drag_time = now
	
	var viewport_h = scroll_container.size.y if scroll_container.size.y > 0 else 720.0
	var max_scroll = int(max(0.0, map_content.custom_minimum_size.y - viewport_h))
	scroll_container.scroll_vertical = clampi(int(_scroll_start_val - delta_y), 0, max_scroll)

func _end_drag() -> void:
	if not _is_dragging:
		return
	_is_dragging = false
	
	# Apply mobile momentum flick
	if abs(_drag_velocity) > 140.0:
		var viewport_h = scroll_container.size.y if scroll_container.size.y > 0 else 720.0
		var max_scroll = max(0.0, map_content.custom_minimum_size.y - viewport_h)
		var target_scroll = clampf(scroll_container.scroll_vertical - (_drag_velocity * 0.32), 0.0, max_scroll)
		if _momentum_tween and _momentum_tween.is_valid():
			_momentum_tween.kill()
		_momentum_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_momentum_tween.tween_property(scroll_container, "scroll_vertical", int(target_scroll), 0.38)
		
	if _has_dragged:
		get_tree().create_timer(0.06).timeout.connect(func(): _has_dragged = false)
