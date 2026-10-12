class_name DeckTray
extends Control

signal card_selected(card_data: CardData)
signal modal_closed

@export var card_scene: PackedScene = preload("res://core/ui/card_ui/card_ui.tscn")
@onready var scroll_container: ScrollContainer = $Panel/ScrollContainer
@onready var cards_container: GridContainer = $Panel/ScrollContainer/MarginBox/CardsContainer if has_node("Panel/ScrollContainer/MarginBox/CardsContainer") else $Panel/ScrollContainer/CardContainer
@onready var count_label: Label = find_child("CountLabel", true, false) as Label
@onready var title_label: Label = find_child("TitleLabel", true, false) as Label
@onready var close_button: Button = find_child("CloseButton", true, false) as Button
@onready var backdrop: ColorRect = $Backdrop

@onready var preview_popup: Control = $CardPreviewPopup if has_node("CardPreviewPopup") else null
@onready var popup_backdrop: ColorRect = $CardPreviewPopup/PopupBackdrop if has_node("CardPreviewPopup/PopupBackdrop") else null
@onready var big_card_slot: Control = $CardPreviewPopup/BigCardSlot if has_node("CardPreviewPopup/BigCardSlot") else null

var current_deck: DeckData = null
var _is_scroll_dragging: bool = false
var _scroll_drag_last_y: float = 0.0

func _ready() -> void:
	visible = false
	if preview_popup != null:
		preview_popup.visible = false
		preview_popup.gui_input.connect(_on_preview_gui_input)
	if popup_backdrop != null:
		popup_backdrop.gui_input.connect(_on_preview_gui_input)
	if close_button != null:
		close_button.pressed.connect(close)
	if backdrop != null:
		backdrop.gui_input.connect(_on_backdrop_gui_input)
	if scroll_container != null:
		scroll_container.gui_input.connect(_on_scroll_bg_gui_input)
		_setup_scrollbar_styling()
	if current_deck != null:
		populate_deck(current_deck)

func _setup_scrollbar_styling() -> void:
	var v_bar = scroll_container.get_v_scroll_bar()
	if v_bar != null:
		v_bar.custom_minimum_size.x = 8
		var track = StyleBoxFlat.new()
		track.bg_color = Color(0.04, 0.035, 0.06, 0.6)
		track.set_corner_radius_all(4)
		v_bar.add_theme_stylebox_override("scroll", track)
		var grabber = StyleBoxFlat.new()
		grabber.bg_color = Color(0.52, 0.42, 0.26, 0.85)
		grabber.set_corner_radius_all(4)
		v_bar.add_theme_stylebox_override("grabber", grabber)
		var grabber_hl = StyleBoxFlat.new()
		grabber_hl.bg_color = Color(0.85, 0.72, 0.42, 0.95)
		grabber_hl.set_corner_radius_all(4)
		v_bar.add_theme_stylebox_override("grabber_highlight", grabber_hl)

func _on_scroll_bg_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_is_scroll_dragging = true
			_scroll_drag_last_y = event.global_position.y
		else:
			_is_scroll_dragging = false
	elif event is InputEventMouseMotion and _is_scroll_dragging:
		var dy = event.global_position.y - _scroll_drag_last_y
		_scroll_drag_last_y = event.global_position.y
		scroll_container.scroll_vertical -= int(dy)

func open(deck: DeckData = null) -> void:
	if preview_popup != null:
		preview_popup.visible = false
	if deck != null:
		populate_deck(deck)
	elif current_deck != null:
		populate_deck(current_deck)
	_is_scroll_dragging = false
	visible = true
	modulate.a = 0.0
	var tw = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "modulate:a", 1.0, 0.18)

func close() -> void:
	if preview_popup != null and preview_popup.visible:
		close_card_preview()
		return
	var tw = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "modulate:a", 0.0, 0.15)
	tw.tween_callback(func():
		visible = false
		modal_closed.emit()
	)

func _on_backdrop_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close()

func _on_preview_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close_card_preview()

func show_card_preview(card_data: CardData) -> void:
	if preview_popup == null or big_card_slot == null or card_data == null:
		return
	for child in big_card_slot.get_children():
		child.queue_free()
		
	var big_card = card_scene.instantiate() as CardUI
	big_card.card_data = card_data
	big_card.pivot_offset = Vector2(120, 170)
	big_card.position = Vector2(20, 30)
	big_card.scale = Vector2(1.0, 1.0)
	big_card.disable_internal_hover = true
	big_card.mouse_filter = Control.MOUSE_FILTER_PASS
	big_card_slot.add_child(big_card)
	
	# Tap card itself also closes
	big_card.gui_input.connect(_on_preview_gui_input)
	
	preview_popup.visible = true
	preview_popup.modulate.a = 0.0
	var tw = preview_popup.create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(preview_popup, "modulate:a", 1.0, 0.16)
	tw.tween_property(big_card, "scale", Vector2(1.25, 1.25), 0.22)

func close_card_preview() -> void:
	if preview_popup == null or not preview_popup.visible:
		return
	var tw = preview_popup.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(preview_popup, "modulate:a", 0.0, 0.12)
	tw.tween_callback(func():
		preview_popup.visible = false
		if big_card_slot != null:
			for child in big_card_slot.get_children():
				child.queue_free()
	)

func set_tray_title(title_text: String) -> void:
	if title_label != null:
		title_label.text = title_text

func populate_deck(deck: DeckData) -> void:
	current_deck = deck
	if cards_container == null and has_node("Panel/ScrollContainer/MarginBox/CardsContainer"):
		cards_container = $Panel/ScrollContainer/MarginBox/CardsContainer
	clear_cards()
	if deck == null:
		if count_label != null:
			count_label.text = "0 Souls in Grimoire"
		return
		
	if count_label != null:
		count_label.text = "%d Souls in Grimoire" % deck.cards.size()
		
	if scroll_container != null:
		scroll_container.scroll_vertical = 0
		
	if cards_container == null:
		return
		
	for card_data in deck.cards:
		if card_data == null:
			continue
			
		var slot = Control.new()
		slot.custom_minimum_size = Vector2(168, 238)
		slot.mouse_filter = Control.MOUSE_FILTER_PASS
		
		var card_instance = card_scene.instantiate() as CardUI
		card_instance.card_data = card_data
		card_instance.disable_internal_hover = true
		card_instance.pivot_offset = Vector2(120, 170)
		card_instance.position = Vector2(-36, -51)
		card_instance.scale = Vector2(0.70, 0.70)
		card_instance.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		slot.add_child(card_instance)
		cards_container.add_child(slot)
		
		# Hover effects
		card_instance.mouse_entered.connect(func():
			card_instance.z_index = 5
			var tw = card_instance.create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tw.tween_property(card_instance, "scale", Vector2(0.77, 0.77), 0.12)
			tw.tween_property(card_instance, "modulate", Color(1.15, 1.18, 1.3), 0.12)
		)
		card_instance.mouse_exited.connect(func():
			card_instance.z_index = 0
			var tw = card_instance.create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tw.tween_property(card_instance, "scale", Vector2(0.70, 0.70), 0.12)
			tw.tween_property(card_instance, "modulate", Color.WHITE, 0.12)
		)
		
		# Drag to scroll & selection
		card_instance.card_clicked.connect(func(c):
			_on_card_clicked(c)
		)
		card_instance.card_drag_started.connect(func(_c, g_pos):
			_is_scroll_dragging = true
			_scroll_drag_last_y = g_pos.y
		)
		card_instance.card_drag_moved.connect(func(_c, g_pos):
			if _is_scroll_dragging:
				var dy = g_pos.y - _scroll_drag_last_y
				_scroll_drag_last_y = g_pos.y
				scroll_container.scroll_vertical -= int(dy)
		)
		card_instance.card_drag_ended.connect(func(_c, _g_pos):
			_is_scroll_dragging = false
		)

func clear_cards() -> void:
	if cards_container == null:
		return
	for child in cards_container.get_children():
		child.queue_free()

func _on_card_clicked(card_data: CardData) -> void:
	show_card_preview(card_data)
	card_selected.emit(card_data)
