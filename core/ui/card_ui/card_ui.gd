class_name CardUI
extends Control

signal card_clicked(card_data: CardData)
signal card_hovered(card: CardUI)
signal card_unhovered(card: CardUI)
signal card_drag_started(card: CardUI, global_pos: Vector2)
signal card_drag_moved(card: CardUI, global_pos: Vector2)
signal card_drag_ended(card: CardUI, global_pos: Vector2)

var _is_pressing: bool = false
var _is_dragging: bool = false
var _press_start_pos: Vector2 = Vector2.ZERO
const DRAG_THRESHOLD: float = 10.0

@export var disable_internal_hover: bool = false
@export var card_data: CardData:
	set(value):
		card_data = value
		if is_node_ready():
			update_display()

@onready var card_frame: TextureRect = $Frame
@onready var cost_label: Label = $CostBadge/CostLabel
@onready var title_label: Label = $TitleLabel
@onready var type_label: Label = $TypeLabel
@onready var desc_label: Label = $DescLabel
@onready var art_rect: TextureRect = $ArtRect

var _hover_tween: Tween = null
var is_playable: bool = true

func set_playable(playable: bool) -> void:
	is_playable = playable
	var target_mod = Color.WHITE if is_playable else Color(0.48, 0.48, 0.55, 0.82)
	var tw = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "modulate", target_mod, 0.18)

func flash_unplayable() -> void:
	if cost_label != null:
		var orig_color = cost_label.get_theme_color("font_color")
		var tw = create_tween()
		tw.tween_property(cost_label, "modulate", Color(2.0, 0.3, 0.3), 0.08)
		tw.tween_property(cost_label, "modulate", Color.WHITE, 0.16)

func _ready() -> void:
	pivot_offset = Vector2(size.x / 2.0, size.y * 0.85)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	
	if card_data != null:
		update_display()

var is_unsummon_mode: bool = false
var unsummon_target_name: String = ""
var unsummon_burst_summary: String = ""

func set_unsummon_mode(enabled: bool, target_name: String = "", burst_summary: String = "") -> void:
	is_unsummon_mode = enabled
	unsummon_target_name = target_name
	unsummon_burst_summary = burst_summary
	if is_node_ready():
		update_display()

func update_display() -> void:
	if card_data == null:
		return
		
	cost_label.text = str(card_data.cost)
	
	if is_unsummon_mode:
		title_label.text = "Detonate: %s" % (unsummon_target_name if not unsummon_target_name.is_empty() else "Summon")
		if not unsummon_burst_summary.is_empty():
			desc_label.text = "💥 Unsummon %s:\n%s\n(Drag to any active ally to target)" % [unsummon_target_name, unsummon_burst_summary]
		else:
			desc_label.text = "💥 Detonate & unsummon %s.\n(Drag to any active ally to target)" % unsummon_target_name
	else:
		title_label.text = card_data.title
		desc_label.text = card_data.description
	
	# Format card art
	var custom_art = card_data.get("art")
	if custom_art != null:
		art_rect.texture = custom_art
	else:
		match card_data.card_type:
			CardData.CardType.ATTACK:
				art_rect.texture = preload("res://core/ui/card_ui/assets/art_attack.svg")
			_:
				art_rect.texture = preload("res://core/ui/card_ui/assets/art_skill.svg")
				
	_update_card_type_theme()

func _update_card_type_theme() -> void:
	if card_data == null or card_frame == null:
		return
		
	var frame_tint: Color = Color.WHITE
	var type_name: String = "CARD"
	var type_color: Color = Color(0.75, 0.8, 0.9, 1.0)
	
	if is_unsummon_mode:
		type_name = "BURST"
		type_color = Color(1.0, 0.7, 0.25, 1.0)
		frame_tint = Color(1.35, 0.85, 0.45, 1.0)
	else:
		match card_data.card_type:
			CardData.CardType.ATTACK:
				type_name = "ATTACK"
				type_color = Color(1.0, 0.45, 0.45, 1.0)
				frame_tint = Color(1.22, 0.72, 0.72, 1.0)
			CardData.CardType.SKILL:
				type_name = "SKILL"
				type_color = Color(0.45, 0.8, 1.0, 1.0)
				frame_tint = Color(0.72, 0.9, 1.25, 1.0)
			CardData.CardType.POWER:
				type_name = "POWER"
				type_color = Color(1.0, 0.85, 0.35, 1.0)
				frame_tint = Color(1.25, 1.08, 0.65, 1.0)
			CardData.CardType.SUMMON:
				type_name = "SUMMON"
				type_color = Color(0.4, 0.95, 0.65, 1.0)
				frame_tint = Color(0.75, 1.25, 0.88, 1.0)
			CardData.CardType.SPELL:
				type_name = "SPELL"
				type_color = Color(0.88, 0.58, 1.0, 1.0)
				frame_tint = Color(1.18, 0.8, 1.3, 1.0)
			_:
				type_name = "CARD"
				type_color = Color(0.75, 0.8, 0.9, 1.0)
				frame_tint = Color.WHITE
			
	if card_data.is_upgraded:
		frame_tint = Color(frame_tint.r * 1.15, frame_tint.g * 1.15, frame_tint.b * 1.15, 1.0)
		
	card_frame.self_modulate = frame_tint
	type_label.text = type_name
	type_label.add_theme_color_override("font_color", type_color)

func _on_mouse_entered() -> void:
	card_hovered.emit(self)
	if disable_internal_hover:
		return
	if _hover_tween and _hover_tween.is_valid():
		_hover_tween.kill()
	z_index = 70
	_hover_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.12)

func _on_mouse_exited() -> void:
	card_unhovered.emit(self)
	if disable_internal_hover:
		return
	if _hover_tween and _hover_tween.is_valid():
		_hover_tween.kill()
	z_index = 0
	_hover_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(self, "scale", Vector2.ONE, 0.12)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if not is_playable:
				flash_unplayable()
				return
			_is_pressing = true
			_is_dragging = false
			_press_start_pos = event.global_position
		else:
			if _is_dragging:
				_is_dragging = false
				card_drag_ended.emit(self, event.global_position)
			elif _is_pressing:
				card_clicked.emit(card_data)
			_is_pressing = false
			
	elif event is InputEventMouseMotion and _is_pressing:
		if not is_playable:
			return
		if not _is_dragging and event.global_position.distance_to(_press_start_pos) > DRAG_THRESHOLD:
			_is_dragging = true
			card_drag_started.emit(self, event.global_position)
		if _is_dragging:
			card_drag_moved.emit(self, event.global_position)
			
	elif event is InputEventScreenTouch:
		if event.pressed:
			if not is_playable:
				flash_unplayable()
				return
			_is_pressing = true
			_is_dragging = false
			_press_start_pos = event.position
		else:
			if _is_dragging:
				_is_dragging = false
				card_drag_ended.emit(self, event.position)
			elif _is_pressing:
				card_clicked.emit(card_data)
			_is_pressing = false
			
	elif event is InputEventScreenDrag and _is_pressing:
		if not is_playable:
			return
		if not _is_dragging and event.position.distance_to(_press_start_pos) > DRAG_THRESHOLD:
			_is_dragging = true
			card_drag_started.emit(self, event.position)
		if _is_dragging:
			card_drag_moved.emit(self, event.position)
