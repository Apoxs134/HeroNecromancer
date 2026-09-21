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

func _ready() -> void:
	visible = false
	claim_button.pressed.connect(_on_claim_pressed)

func show_reward(cards: Array[CardData], title: String = "NEW CARDS ACQUIRED", subtitle: String = "Added to your Grimoire — Hover to inspect:") -> void:
	_active_cards = cards
	title_label.text = title
	subtitle_label.text = subtitle
	
	# Clear existing card children
	for child in cards_container.get_children():
		child.queue_free()
		
	# Populate new cards without scrolling
	for card in cards:
		var card_node = _card_ui_scene.instantiate() as CardUI
		card_node.card_data = card
		cards_container.add_child(card_node)
		
	visible = true
	modulate.a = 0.0
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.22)

func _on_claim_pressed() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.18)
	tween.tween_callback(func():
		visible = false
		cards_claimed.emit(_active_cards)
		dismissed.emit()
	)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE)):
		_on_claim_pressed()
		get_viewport().set_input_as_handled()
