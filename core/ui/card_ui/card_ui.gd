class_name CardUI
extends Control

signal card_clicked(card_data: CardData)

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

func _ready() -> void:
	pivot_offset = size / 2.0
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	
	if card_data != null:
		update_display()

func update_display() -> void:
	if card_data == null:
		return
		
	cost_label.text = str(card_data.cost)
	title_label.text = card_data.title
	desc_label.text = card_data.description
	
	# Format type string
	match card_data.card_type:
		CardData.CardType.ATTACK:
			type_label.text = "ATTACK"
		CardData.CardType.SKILL:
			type_label.text = "SKILL"
		CardData.CardType.POWER:
			type_label.text = "POWER"
		CardData.CardType.SUMMON:
			type_label.text = "SUMMON"
		_:
			type_label.text = "CARD"

func _on_mouse_entered() -> void:
	if _hover_tween and _hover_tween.is_valid():
		_hover_tween.kill()
	z_index = 10
	_hover_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.12)

func _on_mouse_exited() -> void:
	if _hover_tween and _hover_tween.is_valid():
		_hover_tween.kill()
	z_index = 0
	_hover_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(self, "scale", Vector2.ONE, 0.12)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_clicked.emit(card_data)
