extends Node2D

@export_group("Data-Driven Profile")
## Drop an AreaProfile resource here (e.g. res://core/resources/data/charnel_trench_profile.tres)
@export var area_profile: AreaProfile

@export_group("Manual Enum Overrides")
@export var target_state: GameManager.GameState = GameManager.GameState.DIALOG
@export var zone: AreaProfile.AreaZone = AreaProfile.AreaZone.CHARNEL_TRENCH
@export var chapter: AreaProfile.Chapter = AreaProfile.Chapter.CHAPTER_0_PROLOGUE
@export var dialog_id: AreaProfile.DialogId = AreaProfile.DialogId.INTRO_SCENE
@export var custom_deck: DeckData

func _ready() -> void:
	print("HeroNecromancer boot sequence initialized.")
	
	if area_profile != null:
		print("Booting with AreaProfile: %s" % area_profile.resource_name)
		GameManager.apply_profile(area_profile, true)
		return
		
	var fallback_profile = AreaProfile.new()
	fallback_profile.target_state = target_state
	fallback_profile.zone = zone
	fallback_profile.chapter = chapter
	fallback_profile.dialog_id = dialog_id
	fallback_profile.deck = custom_deck if custom_deck != null else load("res://core/cards/data/starter_vanguard_deck.tres") as DeckData
	GameManager.apply_profile(fallback_profile, true)

