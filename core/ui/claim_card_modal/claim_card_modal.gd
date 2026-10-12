class_name ClaimCardModal
extends Control

signal cards_claimed(cards: Array[CardData])
signal dismissed

@onready var title_label: Label = $Panel/TitleLabel
@onready var subtitle_label: Label = $Panel/SubtitleLabel
@onready var cards_container: HBoxContainer = $Panel/CardsContainer
@onready var claim_button: Button = $Panel/ClaimButton

var _card_ui_scene: PackedScene = preload("res://core/ui/card_ui/card_ui.tscn")
var _active_cards: Array[CardData] = []
var is_choice_mode: bool = false
var _selected_card: CardData = null
var _is_claiming: bool = false

func _ready() -> void:
	visible = false
	claim_button.pressed.connect(_on_claim_pressed)

func show_reward(cards: Array[CardData], title: String = "NEW CARDS ACQUIRED", subtitle: String = "Added to your Grimoire — Hover to inspect:", choice_mode: bool = false) -> void:
	_active_cards = cards
	is_choice_mode = choice_mode
	_selected_card = null
	_is_claiming = false
	title_label.text = title
	subtitle_label.text = subtitle
	
	if is_choice_mode:
		claim_button.text = "Skip / Take No Cards"
		claim_button.disabled = false
	else:
		claim_button.text = "Claim & Continue  [ Enter ]"
		claim_button.disabled = false
	
	for child in cards_container.get_children():
		child.queue_free()
		
	for card in cards:
		var card_node = _card_ui_scene.instantiate() as CardUI
		card_node.card_data = card
		card_node.pivot_offset = Vector2(120, 170)
		cards_container.add_child(card_node)
		
		# Selection glow border
		var border = Panel.new()
		border.name = "SelectionBorder"
		border.set_anchors_preset(Control.PRESET_FULL_RECT)
		border.mouse_filter = Control.MOUSE_FILTER_IGNORE
		border.visible = false
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.95, 0.82, 0.3, 0.12)
		style.border_color = Color(1.0, 0.88, 0.38, 0.95)
		style.set_border_width_all(3)
		style.set_corner_radius_all(10)
		style.shadow_color = Color(1.0, 0.8, 0.2, 0.65)
		style.shadow_size = 16
		border.add_theme_stylebox_override("panel", style)
		card_node.add_child(border)
		
		if is_choice_mode:
			card_node.disable_internal_hover = true
			var click_btn = Button.new()
			click_btn.name = "CardSelectButton"
			click_btn.set_anchors_preset(Control.PRESET_FULL_RECT)
			click_btn.flat = true
			click_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			click_btn.focus_mode = Control.FOCUS_NONE
			
			var empty_style = StyleBoxEmpty.new()
			click_btn.add_theme_stylebox_override("normal", empty_style)
			click_btn.add_theme_stylebox_override("hover", empty_style)
			click_btn.add_theme_stylebox_override("pressed", empty_style)
			click_btn.add_theme_stylebox_override("disabled", empty_style)
			click_btn.add_theme_stylebox_override("focus", empty_style)
			
			click_btn.mouse_entered.connect(func():
				if _selected_card != card:
					var tw = card_node.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
					tw.tween_property(card_node, "scale", Vector2(1.06, 1.06), 0.12)
					tw.parallel().tween_property(card_node, "modulate", Color(1.15, 1.15, 1.2), 0.12)
			)
			click_btn.mouse_exited.connect(func():
				if _selected_card != card:
					var target_scale = Vector2(0.92, 0.92) if _selected_card != null else Vector2.ONE
					var target_mod = Color(0.65, 0.65, 0.75, 0.85) if _selected_card != null else Color.WHITE
					var tw = card_node.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
					tw.tween_property(card_node, "scale", target_scale, 0.12)
					tw.parallel().tween_property(card_node, "modulate", target_mod, 0.12)
			)
			click_btn.pressed.connect(func():
				_on_card_clicked(card)
			)
			card_node.add_child(click_btn)
		
	visible = true
	modulate.a = 0.0
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.22)

func _on_card_clicked(card: CardData) -> void:
	if _selected_card == card:
		# Second click confirms selection
		_on_card_confirmed(card)
		return
		
	_selected_card = card
	claim_button.text = "⚔ Claim '%s'" % card.title
	_refresh_card_selection_visuals()

func _refresh_card_selection_visuals() -> void:
	for child in cards_container.get_children():
		var card_node = child as CardUI
		if card_node == null:
			continue
		var border = card_node.get_node_or_null("SelectionBorder") as Panel
		var is_sel = (card_node.card_data == _selected_card)
		
		if border != null:
			border.visible = is_sel
			
		var tw = card_node.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		if is_sel:
			card_node.z_index = 10
			tw.tween_property(card_node, "scale", Vector2(1.18, 1.18), 0.16)
			tw.parallel().tween_property(card_node, "modulate", Color(1.22, 1.20, 1.08), 0.16)
		else:
			card_node.z_index = 0
			var target_scale = Vector2(0.92, 0.92) if _selected_card != null else Vector2.ONE
			var target_mod = Color(0.65, 0.65, 0.75, 0.85) if _selected_card != null else Color.WHITE
			tw.tween_property(card_node, "scale", target_scale, 0.16)
			tw.parallel().tween_property(card_node, "modulate", target_mod, 0.16)

func _on_card_confirmed(card: CardData) -> void:
	if _is_claiming:
		return
	_is_claiming = true
	_finish_and_claim([card] if card != null else [])

func _on_claim_pressed() -> void:
	if is_choice_mode:
		if _selected_card != null:
			_on_card_confirmed(_selected_card)
		else:
			_on_card_confirmed(null)
	else:
		_finish_and_claim(_active_cards)

func _finish_and_claim(cards_to_grant: Array[CardData]) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.18)
	tween.tween_callback(func():
		visible = false
		cards_claimed.emit(cards_to_grant)
		dismissed.emit()
	)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE)):
		_on_claim_pressed()
		get_viewport().set_input_as_handled()
