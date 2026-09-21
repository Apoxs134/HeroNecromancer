extends Control

@onready var test_card_1: CardUI = $MarginContainer/VBoxContainer/CardsPreview/CardUI1
@onready var test_card_2: CardUI = $MarginContainer/VBoxContainer/CardsPreview/CardUI2
@onready var test_card_3: CardUI = $MarginContainer/VBoxContainer/CardsPreview/CardUI3
@onready var test_card_4: CardUI = $MarginContainer/VBoxContainer/CardsPreview/CardUI4
@onready var open_modal_btn: Button = $MarginContainer/VBoxContainer/ButtonsBar/OpenModalButton
@onready var claim_modal: ClaimCardModal = $ClaimCardModal

func _ready() -> void:
	open_modal_btn.pressed.connect(_on_open_modal_pressed)
	
	# Load starter cards for preview
	var pale_smite = load("res://core/cards/data/pale_smite.tres") as CardData
	var grave_ward = load("res://core/cards/data/grave_ward.tres") as CardData
	var vargas_bulwark = load("res://core/cards/data/vargas_bulwark.tres") as CardData
	var kaelen_volley = load("res://core/cards/data/kaelen_volley.tres") as CardData
	
	if test_card_1 and pale_smite:
		test_card_1.card_data = pale_smite
	if test_card_2 and grave_ward:
		test_card_2.card_data = grave_ward
	if test_card_3 and vargas_bulwark:
		test_card_3.card_data = vargas_bulwark
	if test_card_4 and kaelen_volley:
		test_card_4.card_data = kaelen_volley

func _on_open_modal_pressed() -> void:
	var pale_smite = load("res://core/cards/data/pale_smite.tres") as CardData
	var grave_ward = load("res://core/cards/data/grave_ward.tres") as CardData
	var vargas_bulwark = load("res://core/cards/data/vargas_bulwark.tres") as CardData
	var kaelen_volley = load("res://core/cards/data/kaelen_volley.tres") as CardData
	
	var cards: Array[CardData] = [pale_smite, grave_ward, vargas_bulwark, kaelen_volley]
	claim_modal.show_reward(cards, "THE FALLEN VANGUARD", "10 Starter Cards Added to Your Grimoire:")
