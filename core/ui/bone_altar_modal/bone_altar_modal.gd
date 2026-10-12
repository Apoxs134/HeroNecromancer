class_name BoneAltarModal
extends Control

signal altar_completed(summary: String)
signal dismissed

enum AltarMode {
	CHOICE,
	SELECT_PURGE,
	SELECT_SACRIFICE_FOR_UPGRADE,
	SELECT_TARGET_FOR_UPGRADE
}

@onready var title_label: Label = $Panel/TitleLabel
@onready var subtitle_label: Label = $Panel/SubtitleLabel
@onready var choice_container: HBoxContainer = $Panel/ChoiceContainer

@onready var heal_card: Button = $Panel/ChoiceContainer/HealCard
@onready var heal_badge_label: Label = $Panel/ChoiceContainer/HealCard/ActionBadge/BadgeLabel
@onready var purge_card: Button = $Panel/ChoiceContainer/PurgeCard
@onready var purge_badge_label: Label = $Panel/ChoiceContainer/PurgeCard/ActionBadge/BadgeLabel
@onready var upgrade_card: Button = $Panel/ChoiceContainer/UpgradeCard
@onready var upgrade_badge_label: Label = $Panel/ChoiceContainer/UpgradeCard/ActionBadge/BadgeLabel

@onready var cards_scroll: ScrollContainer = $Panel/CardsScroll
@onready var cards_container: GridContainer = $Panel/CardsScroll/MarginBox/CardsContainer if has_node("Panel/CardsScroll/MarginBox/CardsContainer") else $Panel/CardsScroll/CardsContainer
@onready var nav_buttons: HBoxContainer = $Panel/NavButtons if has_node("Panel/NavButtons") else null
@onready var return_button: Button = $Panel/NavButtons/ReturnButton if has_node("Panel/NavButtons/ReturnButton") else null
@onready var back_button: Button = $Panel/NavButtons/BackButton if has_node("Panel/NavButtons/BackButton") else $Panel/BackButton

# Popups
@onready var single_card_popup: Control = $SingleCardPopup if has_node("SingleCardPopup") else null
@onready var single_popup_title: Label = $SingleCardPopup/PopupPanel/Title if has_node("SingleCardPopup/PopupPanel/Title") else null
@onready var single_popup_subtitle: Label = $SingleCardPopup/PopupPanel/Subtitle if has_node("SingleCardPopup/PopupPanel/Subtitle") else null
@onready var single_card_slot: Control = $SingleCardPopup/PopupPanel/CardSlot if has_node("SingleCardPopup/PopupPanel/CardSlot") else null
@onready var single_confirm_btn: Button = $SingleCardPopup/PopupPanel/ButtonsHBox/ConfirmBtn if has_node("SingleCardPopup/PopupPanel/ButtonsHBox/ConfirmBtn") else null
@onready var single_cancel_btn: Button = $SingleCardPopup/PopupPanel/ButtonsHBox/CancelBtn if has_node("SingleCardPopup/PopupPanel/ButtonsHBox/CancelBtn") else null

@onready var transmute_popup: Control = $TransmutePopup if has_node("TransmutePopup") else null
@onready var transmute_subtitle: Label = $TransmutePopup/PopupPanel/Subtitle if has_node("TransmutePopup/PopupPanel/Subtitle") else null
@onready var fuel_slot: Control = $TransmutePopup/PopupPanel/CardsComparison/FuelBox/FuelSlot if has_node("TransmutePopup/PopupPanel/CardsComparison/FuelBox/FuelSlot") else null
@onready var target_slot: Control = $TransmutePopup/PopupPanel/CardsComparison/TargetBox/TargetSlot if has_node("TransmutePopup/PopupPanel/CardsComparison/TargetBox/TargetSlot") else null
@onready var transmute_confirm_btn: Button = $TransmutePopup/PopupPanel/ButtonsHBox/ConfirmBtn if has_node("TransmutePopup/PopupPanel/ButtonsHBox/ConfirmBtn") else null
@onready var transmute_cancel_btn: Button = $TransmutePopup/PopupPanel/ButtonsHBox/CancelBtn if has_node("TransmutePopup/PopupPanel/ButtonsHBox/CancelBtn") else null

# Backwards compatibility getters
var heal_button: Button:
	get: return heal_card
var purge_button: Button:
	get: return purge_card
var upgrade_button: Button:
	get: return upgrade_card

var _card_ui_scene: PackedScene = preload("res://core/ui/card_ui/card_ui.tscn")
var _current_mode: AltarMode = AltarMode.CHOICE
var _card_to_sacrifice: CardData = null
var _pending_selected_card: CardData = null

var _is_scroll_dragging: bool = false
var _scroll_drag_last_y: float = 0.0
var _is_busy: bool = false

func _ready() -> void:
	visible = false
	_close_all_popups()
	
	heal_card.pressed.connect(_on_heal_selected)
	purge_card.pressed.connect(_on_purge_selected)
	upgrade_card.pressed.connect(_on_upgrade_selected)
	
	if back_button != null:
		back_button.pressed.connect(_on_back_pressed)
	if return_button != null:
		return_button.pressed.connect(_on_return_pressed)
		
	if single_confirm_btn != null:
		single_confirm_btn.pressed.connect(_on_single_confirm_pressed)
	if single_cancel_btn != null:
		single_cancel_btn.pressed.connect(_close_all_popups)
		
	if transmute_confirm_btn != null:
		transmute_confirm_btn.pressed.connect(_on_transmute_confirm_pressed)
	if transmute_cancel_btn != null:
		transmute_cancel_btn.pressed.connect(_close_all_popups)
		
	if single_card_popup != null:
		var single_backdrop = single_card_popup.get_node_or_null("Backdrop") as ColorRect
		if single_backdrop != null:
			single_backdrop.gui_input.connect(func(ev):
				if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
					_close_all_popups()
			)
			
	if transmute_popup != null:
		var trans_backdrop = transmute_popup.get_node_or_null("Backdrop") as ColorRect
		if trans_backdrop != null:
			trans_backdrop.gui_input.connect(func(ev):
				if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
					_close_all_popups()
			)
	
	_setup_card_hover_fx(heal_card)
	_setup_card_hover_fx(purge_card)
	_setup_card_hover_fx(upgrade_card)
	_setup_scrollbar_styling()
	
	if cards_scroll != null:
		cards_scroll.gui_input.connect(_on_scroll_bg_gui_input)

func _setup_scrollbar_styling() -> void:
	if cards_scroll == null:
		return
	var v_bar = cards_scroll.get_v_scroll_bar()
	if v_bar != null:
		v_bar.custom_minimum_size.x = 8
		var track = StyleBoxFlat.new()
		track.bg_color = Color(0.08, 0.1, 0.14, 0.5)
		track.set_corner_radius_all(4)
		v_bar.add_theme_stylebox_override("scroll", track)
		var grabber = StyleBoxFlat.new()
		grabber.bg_color = Color(0.85, 0.45, 0.35, 0.8)
		grabber.set_corner_radius_all(4)
		v_bar.add_theme_stylebox_override("grabber", grabber)
		var grabber_hl = StyleBoxFlat.new()
		grabber_hl.bg_color = Color(1.0, 0.6, 0.45, 0.95)
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
		cards_scroll.scroll_vertical -= int(dy)

func _setup_card_hover_fx(btn: Button) -> void:
	btn.pivot_offset = Vector2(160, 155)
	btn.mouse_entered.connect(func():
		if not btn.disabled:
			var tw = btn.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tw.tween_property(btn, "scale", Vector2(1.025, 1.025), 0.12)
	)
	btn.mouse_exited.connect(func():
		var tw = btn.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(btn, "scale", Vector2.ONE, 0.12)
	)

func open_altar() -> void:
	_card_to_sacrifice = null
	_pending_selected_card = null
	_is_busy = false
	_close_all_popups()
	_show_choice_view()
	visible = true
	modulate.a = 0.0
	var tw = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "modulate:a", 1.0, 0.22)

func _show_choice_view() -> void:
	_current_mode = AltarMode.CHOICE
	_card_to_sacrifice = null
	_pending_selected_card = null
	_is_busy = false
	_is_scroll_dragging = false
	_close_all_popups()
	
	title_label.text = "THE BONE ALTAR"
	subtitle_label.text = "Ancient souls whisper from the crypt. Choose your sacred ritual:"
	subtitle_label.add_theme_color_override("font_color", Color(0.88, 0.86, 0.92, 1))
	choice_container.visible = true
	cards_scroll.visible = false
	if nav_buttons != null:
		nav_buttons.visible = false
	elif back_button != null:
		back_button.visible = false
	
	var deck = GameManager.active_deck
	var can_purge = CardUpgradeModel.can_sacrifice(deck, CardUpgradeModel.MIN_DECK_SIZE)
	purge_card.disabled = not can_purge
	purge_card.modulate = Color.WHITE if can_purge else Color(0.55, 0.55, 0.6, 0.65)
	if not can_purge:
		purge_badge_label.text = "Purge (Min 10 Cards Req)"
	else:
		purge_badge_label.text = "Sacrifice Card"
		
	var can_up = deck != null and deck.cards.size() > CardUpgradeModel.MIN_DECK_SIZE
	upgrade_card.disabled = not can_up
	upgrade_card.modulate = Color.WHITE if can_up else Color(0.55, 0.55, 0.6, 0.65)
	if not can_up:
		upgrade_badge_label.text = "Transmute (Min 11 Cards Req)"
	else:
		upgrade_badge_label.text = "Sacrifice & Upgrade"

func _on_heal_selected() -> void:
	if _is_busy:
		return
	_is_busy = true
	var heal_amt = mini(14, GameManager.crusade_max_hp - GameManager.crusade_hero_hp)
	GameManager.crusade_hero_hp = mini(GameManager.crusade_max_hp, GameManager.crusade_hero_hp + 14)
	_finish_altar("Communed at Bone Altar: Restored +%d HP (%d/%d)." % [heal_amt, GameManager.crusade_hero_hp, GameManager.crusade_max_hp])

func _on_purge_selected() -> void:
	_current_mode = AltarMode.SELECT_PURGE
	choice_container.visible = false
	cards_scroll.visible = true
	if nav_buttons != null:
		nav_buttons.visible = true
		if return_button != null:
			return_button.visible = false
		if back_button != null:
			back_button.text = "« Back to Choices"
	elif back_button != null:
		back_button.visible = true
		back_button.text = "« Back to Choices"
		
	title_label.text = "SOUL SACRIFICE"
	subtitle_label.text = "🔥 Select a spell or skill card from your Grimoire to permanently sacrifice (Crew members cannot be sacrificed):"
	subtitle_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.45, 1))
	_populate_cards_list(func(c: CardData): return c != null and c.card_type != CardData.CardType.SUMMON)

func _on_upgrade_selected() -> void:
	_current_mode = AltarMode.SELECT_SACRIFICE_FOR_UPGRADE
	_card_to_sacrifice = null
	choice_container.visible = false
	cards_scroll.visible = true
	if nav_buttons != null:
		nav_buttons.visible = true
		if return_button != null:
			return_button.visible = false
		if back_button != null:
			back_button.text = "« Back to Choices"
	elif back_button != null:
		back_button.visible = true
		back_button.text = "« Back to Choices"
		
	title_label.text = "SOUL TRANSMUTATION (Step 1/2)"
	subtitle_label.text = "⚡ Select a fuel card to SACRIFICE for the ritual (Crew members cannot be sacrificed):"
	subtitle_label.add_theme_color_override("font_color", Color(0.88, 0.75, 1.0, 1))
	_populate_cards_list(func(c: CardData): return c != null and c.card_type != CardData.CardType.SUMMON)

func _show_upgrade_step_2() -> void:
	_current_mode = AltarMode.SELECT_TARGET_FOR_UPGRADE
	choice_container.visible = false
	cards_scroll.visible = true
	if nav_buttons != null:
		nav_buttons.visible = true
		if return_button != null:
			return_button.visible = true
			return_button.text = "« Reselect Fuel Card"
		if back_button != null:
			back_button.text = "✕ Cancel to Altar"
	elif back_button != null:
		back_button.visible = true
		back_button.text = "✕ Cancel to Altar"
		
	title_label.text = "SOUL TRANSMUTATION (Step 2/2)"
	subtitle_label.text = "🔥 FUEL: '%s'   |   Select target card to permanently EMPOWER (+):" % (_card_to_sacrifice.title if _card_to_sacrifice else "")
	subtitle_label.add_theme_color_override("font_color", Color(0.96, 0.85, 0.5, 1))
	_populate_cards_list(func(c: CardData):
		return c != _card_to_sacrifice and CardUpgradeModel.can_upgrade(c)
	)

func _on_return_pressed() -> void:
	_close_all_popups()
	_on_upgrade_selected()

func _on_back_pressed() -> void:
	_close_all_popups()
	_show_choice_view()

func _populate_cards_list(filter_fn: Callable) -> void:
	for child in cards_container.get_children():
		child.queue_free()
		
	var deck = GameManager.active_deck
	if deck == null:
		return
		
	cards_scroll.scroll_vertical = 0
	
	for card in deck.cards:
		if not filter_fn.call(card):
			continue
			
		var slot = Control.new()
		slot.custom_minimum_size = Vector2(168, 238)
		slot.mouse_filter = Control.MOUSE_FILTER_PASS
		
		var sel_border = Panel.new()
		sel_border.name = "SelectionBorder"
		sel_border.set_anchors_preset(Control.PRESET_FULL_RECT)
		sel_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sel_border.visible = false
		
		var sel_style = StyleBoxFlat.new()
		sel_style.bg_color = Color(0.1, 0.15, 0.25, 0.35)
		sel_style.border_width_left = 3
		sel_style.border_width_top = 3
		sel_style.border_width_right = 3
		sel_style.border_width_bottom = 3
		sel_style.border_color = Color(1.0, 0.85, 0.25, 1.0)
		sel_style.set_corner_radius_all(8)
		sel_style.shadow_color = Color(1.0, 0.8, 0.2, 0.65)
		sel_style.shadow_size = 12
		sel_border.add_theme_stylebox_override("panel", sel_style)
		
		var card_ui = _card_ui_scene.instantiate() as CardUI
		card_ui.card_data = card
		card_ui.disable_internal_hover = true
		card_ui.scale = Vector2(0.70, 0.70)
		card_ui.position = Vector2.ZERO
		card_ui.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		slot.add_child(card_ui)
		slot.add_child(sel_border)
		cards_container.add_child(slot)
		
		card_ui.pivot_offset = Vector2.ZERO
		
		card_ui.mouse_entered.connect(func():
			_on_card_hovered(card_ui, sel_border)
		)
		card_ui.mouse_exited.connect(func():
			_on_card_unhovered(card_ui, sel_border)
		)
		card_ui.card_clicked.connect(func(c_data: CardData):
			_on_card_chosen(c_data, slot)
		)
		card_ui.card_drag_started.connect(func(_c_node: CardUI, g_pos: Vector2):
			_is_scroll_dragging = true
			_scroll_drag_last_y = g_pos.y
		)
		card_ui.card_drag_moved.connect(func(_c_node: CardUI, g_pos: Vector2):
			if _is_scroll_dragging:
				var dy = g_pos.y - _scroll_drag_last_y
				_scroll_drag_last_y = g_pos.y
				cards_scroll.scroll_vertical -= int(dy)
		)
		card_ui.card_drag_ended.connect(func(_c_node: CardUI, _g_pos: Vector2):
			_is_scroll_dragging = false
		)

func _on_card_hovered(card_ui: CardUI, sel_border: Panel) -> void:
	card_ui.z_index = 5
	if not sel_border.visible:
		var tw = card_ui.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(card_ui, "modulate", Color(1.15, 1.15, 1.25), 0.1)

func _on_card_unhovered(card_ui: CardUI, sel_border: Panel) -> void:
	card_ui.z_index = 0
	if not sel_border.visible:
		var tw = card_ui.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(card_ui, "modulate", Color.WHITE, 0.1)

func _on_card_chosen(card: CardData, _slot: Control = null) -> void:
	if _is_busy or card == null:
		return
		
	_pending_selected_card = card
	
	match _current_mode:
		AltarMode.SELECT_PURGE:
			_show_single_card_popup(
				"CONFIRM SOUL SACRIFICE",
				"Permanently burn '%s' to ash from your Grimoire?" % card.title,
				card,
				"🔥 Confirm Sacrifice"
			)
		AltarMode.SELECT_SACRIFICE_FOR_UPGRADE:
			_show_single_card_popup(
				"SELECT SACRIFICE FUEL",
				"Sacrifice '%s' as fuel to empower another card?" % card.title,
				card,
				"⚡ Select as Fuel"
			)
		AltarMode.SELECT_TARGET_FOR_UPGRADE:
			_show_transmute_popup(_card_to_sacrifice, card)

func _show_single_card_popup(title_text: String, sub_text: String, card: CardData, btn_text: String) -> void:
	if single_card_popup == null:
		return
	single_popup_title.text = title_text
	single_popup_subtitle.text = sub_text
	single_confirm_btn.text = btn_text
	
	for child in single_card_slot.get_children():
		child.queue_free()
	var big_card = _card_ui_scene.instantiate() as CardUI
	big_card.card_data = card
	big_card.scale = Vector2(1.05, 1.05)
	big_card.position = Vector2.ZERO
	big_card.disable_internal_hover = true
	big_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	single_card_slot.add_child(big_card)
	big_card.pivot_offset = Vector2.ZERO
	
	single_card_popup.visible = true
	single_card_popup.modulate.a = 0.0
	var tw = single_card_popup.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(single_card_popup, "modulate:a", 1.0, 0.14)

func _show_transmute_popup(f_card: CardData, t_card: CardData) -> void:
	if transmute_popup == null or f_card == null or t_card == null:
		return
	transmute_subtitle.text = "Sacrifice '%s' to permanently empower '%s+'!" % [f_card.title, t_card.title]
	
	for child in fuel_slot.get_children():
		child.queue_free()
	var fuel_card_ui = _card_ui_scene.instantiate() as CardUI
	fuel_card_ui.card_data = f_card
	fuel_card_ui.scale = Vector2(0.90, 0.90)
	fuel_card_ui.position = Vector2.ZERO
	fuel_card_ui.disable_internal_hover = true
	fuel_card_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fuel_slot.add_child(fuel_card_ui)
	fuel_card_ui.pivot_offset = Vector2.ZERO
	
	for child in target_slot.get_children():
		child.queue_free()
	var upgraded_card_data = CardUpgradeModel.upgrade_card(t_card)
	var target_card_ui = _card_ui_scene.instantiate() as CardUI
	target_card_ui.card_data = upgraded_card_data if upgraded_card_data != null else t_card
	target_card_ui.scale = Vector2(0.90, 0.90)
	target_card_ui.position = Vector2.ZERO
	target_card_ui.disable_internal_hover = true
	target_card_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	target_slot.add_child(target_card_ui)
	target_card_ui.pivot_offset = Vector2.ZERO
	
	transmute_popup.visible = true
	transmute_popup.modulate.a = 0.0
	var tw = transmute_popup.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(transmute_popup, "modulate:a", 1.0, 0.14)

func _close_all_popups() -> void:
	if single_card_popup != null:
		single_card_popup.visible = false
	if transmute_popup != null:
		transmute_popup.visible = false

func _on_single_confirm_pressed() -> void:
	if _pending_selected_card == null:
		_close_all_popups()
		return
		
	var card = _pending_selected_card
	_close_all_popups()
	
	var deck = GameManager.active_deck
	if deck == null:
		return
		
	match _current_mode:
		AltarMode.SELECT_PURGE:
			if _is_busy:
				return
			_is_busy = true
			var ok = CardUpgradeModel.sacrifice_card(deck, card)
			if ok:
				_finish_altar("Sacrificed and burned '%s'. Grimoire thinned to %d cards." % [card.title, deck.cards.size()])
			else:
				_is_busy = false
		AltarMode.SELECT_SACRIFICE_FOR_UPGRADE:
			_card_to_sacrifice = card
			_show_upgrade_step_2()

func _on_transmute_confirm_pressed() -> void:
	if _pending_selected_card == null or _card_to_sacrifice == null:
		_close_all_popups()
		return
		
	var target_card = _pending_selected_card
	var fuel_card = _card_to_sacrifice
	_close_all_popups()
	
	if _is_busy:
		return
	_is_busy = true
	
	var deck = GameManager.active_deck
	if deck == null:
		_is_busy = false
		return
		
	var ok = CardUpgradeModel.sacrifice_and_upgrade(deck, fuel_card, target_card)
	if ok:
		_finish_altar("Transmuted at Bone Altar: Sacrificed '%s' to empower '%s+'!" % [fuel_card.title, target_card.title])
	else:
		_is_busy = false
		_show_choice_view()

func _finish_altar(summary_text: String) -> void:
	var tw = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "modulate:a", 0.0, 0.18)
	tw.tween_callback(func():
		visible = false
		_is_busy = false
		altar_completed.emit(summary_text)
		dismissed.emit()
	)
