class_name BattleArena
extends Control

const DamageImpact = preload("res://battlefield/vfx/damage_impact/damage_impact.gd")
const SoulHarvest = preload("res://battlefield/vfx/soul_harvest/soul_harvest.gd")
const SummonBurst = preload("res://battlefield/vfx/summon_burst/summon_burst.gd")
const ShieldWard = preload("res://battlefield/vfx/shield_ward/shield_ward.gd")
const HealBuff = preload("res://battlefield/vfx/heal_buff/heal_buff.gd")

const CINZEL_BOLD: FontFile = preload("res://ui/fonts/Cinzel/static/Cinzel-Bold.ttf")
const CINZEL_SEMIBOLD: FontFile = preload("res://ui/fonts/Cinzel/static/Cinzel-SemiBold.ttf")
const CRIMSON_REGULAR: FontFile = preload("res://ui/fonts/Crimson_Pro/static/CrimsonPro-Regular.ttf")
const CRIMSON_ITALIC: FontFile = preload("res://ui/fonts/Crimson_Pro/static/CrimsonPro-MediumItalic.ttf")


@export var hero_texture: Texture2D = preload("res://core/battle/input_commander.webp")
@export var card_scene: PackedScene = preload("res://core/ui/card_ui/card_ui.tscn")
@export var scout_texture: Texture2D = preload("res://core/battle/chapter1/Peasant Militia Scout.webp")
@export var farmer_texture: Texture2D = preload("res://core/battle/chapter1/Enraged Farmer.webp")
@export var slash_texture: Texture2D = preload("res://battlefield/assets/vfx_slash.svg")

# Chapter 1 Enemy Sprites Mapping
const CHAPTER_1_ENEMY_TEXTURES: Dictionary = {
	"peasant militia scout": preload("res://core/battle/chapter1/Peasant Militia Scout.webp"),
	"enraged farmer": preload("res://core/battle/chapter1/Enraged Farmer.webp"),
	"militia vanguard": preload("res://core/battle/chapter1/Militia Vanguard.webp"),
	"armed townsperson": preload("res://core/battle/chapter1/Armed Townsperson.webp"),
	"armed townspersons": preload("res://core/battle/chapter1/Armed Townsperson.webp"),
	"hound of oakhaven": preload("res://core/battle/chapter1/Hound of Oakhaven.webp"),
	"zealot templar": preload("res://core/battle/chapter1/Zealot Templar.webp"),
	"holy warhound": preload("res://core/battle/chapter1/Holy Warhound.webp"),
	"pyre crossbowman": preload("res://core/battle/chapter1/Pyre Crossbowman.webp"),
	"garrison captain boros": preload("res://core/battle/chapter1/Garrison Captain Boros.webp"),
	"tower halberdier": preload("res://core/battle/chapter1/Tower Halberdier.webp"),
	"tower halberdiers": preload("res://core/battle/chapter1/Tower Halberdier.webp"),
	"militia bowman": preload("res://core/battle/chapter1/Militia Bowman.webp"),
}

# Chapter 2 Enemy Sprites Mapping
const CHAPTER_2_ENEMY_TEXTURES: Dictionary = {
	"inquisition crossbowman": preload("res://core/battle/chapter2/Inquisition Crossbowman.webp"),
	"templar halberdier": preload("res://core/battle/chapter2/Templar Halberdier.webp"),
	"templar halberdiers": preload("res://core/battle/chapter2/Templar Halberdier.webp"),
	"hounds of mourning": preload("res://core/battle/chapter2/Hounds of Mourning.webp"),
	"hound of mourning": preload("res://core/battle/chapter2/Hounds of Mourning.webp"),
	"grand judiciar vane": preload("res://core/battle/chapter2/Grand Judiciar Vane.webp"),
	"purifying templars": preload("res://core/battle/chapter2/Purifying Templars.webp"),
	"purifying templar": preload("res://core/battle/chapter2/Purifying Templars.webp"),
	"iron maiden vanguard": preload("res://core/battle/chapter2/Iron Maiden Vanguard.webp"),
	"high inquisitor malakor": preload("res://core/battle/chapter2/High Inquisitor Malakor.webp"),
	"sanctified golem": preload("res://core/battle/chapter2/Sanctified Golem.webp"),
	"sun-oath executioners": preload("res://core/battle/chapter2/Sun-Oath Executioners.webp"),
	"sun-oath executioner": preload("res://core/battle/chapter2/Sun-Oath Executioners.webp"),
}

# Chapter 3 Enemy Sprites Mapping
const CHAPTER_3_ENEMY_TEXTURES: Dictionary = {
	"citadel halberdier": preload("res://core/battle/chapter3/Citadel Halberdier.webp"),
	"citadel halberdiers": preload("res://core/battle/chapter3/Citadel Halberdier.webp"),
	"royal arbalestier": preload("res://core/battle/chapter3/Royal Arbalestier.webp"),
	"palace gilded knight": preload("res://core/battle/chapter3/Palace Gilded Knight.webp"),
	"captain lorian of the guard": preload("res://core/battle/chapter3/Captain Lorian of the Guard.webp"),
	"captain lorian": preload("res://core/battle/chapter3/Captain Lorian of the Guard.webp"),
	"golden templar champion": preload("res://core/battle/chapter3/Golden Templar Champion.webp"),
	"grand justiciar golem": preload("res://core/battle/chapter3/Grand Justiciar Golem.webp"),
	"king alden the betrayer": preload("res://core/battle/chapter3/King Alden the Betrayer.webp"),
	"king alden": preload("res://core/battle/chapter3/King Alden the Betrayer.webp"),
	"royal sun-golem": preload("res://core/battle/chapter3/Royal Sun-Golem.webp"),
	"royal sun golem": preload("res://core/battle/chapter3/Royal Sun-Golem.webp"),
	"high chancellor malakor's shade": preload("res://core/battle/chapter3/High Chancellor Shade.webp"),
	"high chancellor shade": preload("res://core/battle/chapter3/High Chancellor Shade.webp"),
}

# Character Visual Scaling & Foot Y-Offset Alignment Profiles
const CHARACTER_VISUAL_PROFILES: Dictionary = {
	# Companions & Allies
	"vargas": {"scale": 1.25, "y_offset": 2.0, "shadow_scale": 1.26, "shadow_y": 0.0},
	"boros": {"scale": 1.22, "y_offset": 0.0, "shadow_scale": 1.22, "shadow_y": 0.0},
	"kaelen": {"scale": 0.98, "y_offset": 0.0, "shadow_scale": 0.98, "shadow_y": 0.0},
	"lyra": {"scale": 1.00, "y_offset": -2.0, "shadow_scale": 0.96, "shadow_y": 2.0},
	"malakor": {"scale": 1.10, "y_offset": 0.0, "shadow_scale": 1.10, "shadow_y": 0.0},
	"inquisitor": {"scale": 1.10, "y_offset": 0.0, "shadow_scale": 1.10, "shadow_y": 0.0},
	"hero": {"scale": 1.00, "y_offset": 0.0, "shadow_scale": 1.00, "shadow_y": 0.0},
	"malignis": {"scale": 1.00, "y_offset": 0.0, "shadow_scale": 1.00, "shadow_y": 0.0},

	# Chapter 1 Enemies
	"peasant militia scout": {"scale": 0.86, "y_offset": 2.0, "shadow_scale": 0.86, "shadow_y": 0.0},
	"enraged farmer": {"scale": 0.88, "y_offset": 3.0, "shadow_scale": 0.88, "shadow_y": 0.0},
	"armed townsperson": {"scale": 0.92, "y_offset": 1.0, "shadow_scale": 0.92, "shadow_y": 0.0},
	"militia vanguard": {"scale": 1.02, "y_offset": 2.0, "shadow_scale": 1.02, "shadow_y": 0.0},
	"hound of oakhaven": {"scale": 0.82, "y_offset": 4.0, "shadow_scale": 0.85, "shadow_y": -2.0, "intent_y_adjust": 18.0},
	"holy warhound": {"scale": 0.82, "y_offset": 4.0, "shadow_scale": 0.85, "shadow_y": -2.0, "intent_y_adjust": 18.0},
	"zealot templar": {"scale": 1.02, "y_offset": 0.0, "shadow_scale": 1.02, "shadow_y": 0.0},
	"pyre crossbowman": {"scale": 0.94, "y_offset": 0.0, "shadow_scale": 0.94, "shadow_y": 0.0},
	"militia bowman": {"scale": 0.92, "y_offset": 0.0, "shadow_scale": 0.92, "shadow_y": 0.0},
	"tower halberdier": {"scale": 1.05, "y_offset": 0.0, "shadow_scale": 1.05, "shadow_y": 0.0},
	"garrison captain boros": {"scale": 1.24, "y_offset": 0.0, "shadow_scale": 1.24, "shadow_y": 0.0},

	# Chapter 2 Enemies
	"inquisition crossbowman": {"scale": 0.94, "y_offset": 0.0, "shadow_scale": 0.94, "shadow_y": 0.0},
	"templar halberdier": {"scale": 1.05, "y_offset": 0.0, "shadow_scale": 1.05, "shadow_y": 0.0},
	"hounds of mourning": {"scale": 0.84, "y_offset": 3.0, "shadow_scale": 0.86, "shadow_y": -2.0, "intent_y_adjust": 18.0},
	"grand judiciar vane": {"scale": 1.16, "y_offset": 0.0, "shadow_scale": 1.16, "shadow_y": 0.0},
	"purifying templars": {"scale": 1.02, "y_offset": 0.0, "shadow_scale": 1.02, "shadow_y": 0.0},
	"sun-oath executioners": {"scale": 1.08, "y_offset": 0.0, "shadow_scale": 1.08, "shadow_y": 0.0},
	"iron maiden vanguard": {"scale": 1.24, "y_offset": 0.0, "shadow_scale": 1.25, "shadow_y": 0.0},
	"sanctified golem": {"scale": 1.28, "y_offset": 0.0, "shadow_scale": 1.28, "shadow_y": 0.0},
	"high inquisitor malakor": {"scale": 1.15, "y_offset": 0.0, "shadow_scale": 1.15, "shadow_y": 0.0},

	# Chapter 3 Enemies
	"citadel halberdier": {"scale": 1.05, "y_offset": 0.0, "shadow_scale": 1.05, "shadow_y": 0.0},
	"royal arbalestier": {"scale": 0.95, "y_offset": 5.0, "shadow_scale": 0.95, "shadow_y": 2.0},
	"palace gilded knight": {"scale": 1.10, "y_offset": 0.0, "shadow_scale": 1.10, "shadow_y": 0.0},
	"captain lorian of the guard": {"scale": 1.18, "y_offset": 0.0, "shadow_scale": 1.18, "shadow_y": 0.0},
	"golden templar champion": {"scale": 1.12, "y_offset": 0.0, "shadow_scale": 1.12, "shadow_y": 0.0},
	"grand justiciar golem": {"scale": 1.28, "y_offset": 0.0, "shadow_scale": 1.28, "shadow_y": 0.0},
	"royal sun-golem": {"scale": 1.28, "y_offset": 0.0, "shadow_scale": 1.28, "shadow_y": 0.0},
	"high chancellor shade": {"scale": 1.08, "y_offset": -8.0, "shadow_scale": 0.92, "shadow_y": 14.0},
	"high chancellor malakor's shade": {"scale": 1.08, "y_offset": -8.0, "shadow_scale": 0.92, "shadow_y": 14.0},
	"king alden the betrayer": {"scale": 1.25, "y_offset": 0.0, "shadow_scale": 1.25, "shadow_y": 0.0},
}

# Intent & Targeting Textures
@export var intent_attack_texture: Texture2D = preload("res://battlefield/assets/icon_intent_attack.svg")
@export var intent_defend_texture: Texture2D = preload("res://battlefield/assets/icon_intent_defend.svg")
@export var intent_buff_texture: Texture2D = preload("res://battlefield/assets/icon_intent_buff.svg")
@export var target_reticle_texture: Texture2D = preload("res://core/battle/target_battle.webp")

enum DragTargetType {
	ENEMY_SINGLE,
	ENEMY_ALL,
	ALLY_HERO,
	ALLY_SUMMON,
	SUMMON_SPAWN,
	GENERAL_ARENA
}

# UI Groups
@onready var background_texture: TextureRect = $BackgroundTexture
@onready var combat_ui: Control = $CombatUI
@onready var title_label: Label = find_child("Title", true, false) as Label
@onready var energy_badge: Label = find_child("EnergyBadge", true, false) as Label
@onready var deck_piles_label: Label = find_child("DeckPilesLabel", true, false) as Label
@onready var soul_crucible: Control = $CombatUI/SoulCrucible if has_node("CombatUI/SoulCrucible") else null
@onready var orb_texture: TextureRect = $CombatUI/SoulCrucible/OrbTexture if has_node("CombatUI/SoulCrucible/OrbTexture") else null
@onready var energy_num_label: Label = $CombatUI/SoulCrucible/EnergyNumLabel if has_node("CombatUI/SoulCrucible/EnergyNumLabel") else null

@onready var battle_formation: BattleFormation = $CombatUI/SideBattleField/BattleFormation if has_node("CombatUI/SideBattleField/BattleFormation") else null

# Alliance Side (Left)
@onready var hero_sprite: TextureRect = $CombatUI/SideBattleField/BattleFormation/HeroSlot/HeroSprite if has_node("CombatUI/SideBattleField/BattleFormation/HeroSlot/HeroSprite") else null
@onready var hero_hp_bar: ProgressBar = $CombatUI/SideBattleField/BattleFormation/HeroSlot/HeroHPBar if has_node("CombatUI/SideBattleField/BattleFormation/HeroSlot/HeroHPBar") else null
@onready var hero_status_label: Label = $CombatUI/SideBattleField/BattleFormation/HeroSlot/HeroStatusLabel if has_node("CombatUI/SideBattleField/BattleFormation/HeroSlot/HeroStatusLabel") else null

@onready var vanguard_container: Control = $CombatUI/SideBattleField/BattleFormation/SummonSlot_0 if has_node("CombatUI/SideBattleField/BattleFormation/SummonSlot_0") else null
@onready var vanguard_name: Label = $CombatUI/SideBattleField/BattleFormation/SummonSlot_0/VanguardName if has_node("CombatUI/SideBattleField/BattleFormation/SummonSlot_0/VanguardName") else null
@onready var vanguard_sprite: TextureRect = $CombatUI/SideBattleField/BattleFormation/SummonSlot_0/VanguardSprite if has_node("CombatUI/SideBattleField/BattleFormation/SummonSlot_0/VanguardSprite") else null
@onready var vanguard_hp_bar: ProgressBar = $CombatUI/SideBattleField/BattleFormation/SummonSlot_0/VanguardHPBar if has_node("CombatUI/SideBattleField/BattleFormation/SummonSlot_0/VanguardHPBar") else null
@onready var vanguard_status_label: Label = $CombatUI/SideBattleField/BattleFormation/SummonSlot_0/VanguardStatusLabel if has_node("CombatUI/SideBattleField/BattleFormation/SummonSlot_0/VanguardStatusLabel") else null

@onready var slot1_container: Control = $CombatUI/SideBattleField/BattleFormation/SummonSlot_1 if has_node("CombatUI/SideBattleField/BattleFormation/SummonSlot_1") else null
@onready var slot1_name: Label = $CombatUI/SideBattleField/BattleFormation/SummonSlot_1/Slot1Name if has_node("CombatUI/SideBattleField/BattleFormation/SummonSlot_1/Slot1Name") else null
@onready var slot1_sprite: TextureRect = $CombatUI/SideBattleField/BattleFormation/SummonSlot_1/Slot1Sprite if has_node("CombatUI/SideBattleField/BattleFormation/SummonSlot_1/Slot1Sprite") else null
@onready var slot1_hp_bar: ProgressBar = $CombatUI/SideBattleField/BattleFormation/SummonSlot_1/Slot1HPBar if has_node("CombatUI/SideBattleField/BattleFormation/SummonSlot_1/Slot1HPBar") else null
@onready var slot1_status_label: Label = $CombatUI/SideBattleField/BattleFormation/SummonSlot_1/Slot1StatusLabel if has_node("CombatUI/SideBattleField/BattleFormation/SummonSlot_1/Slot1StatusLabel") else null

@onready var slot2_container: Control = $CombatUI/SideBattleField/BattleFormation/SummonSlot_2 if has_node("CombatUI/SideBattleField/BattleFormation/SummonSlot_2") else null
@onready var slot2_name: Label = $CombatUI/SideBattleField/BattleFormation/SummonSlot_2/Slot2Name if has_node("CombatUI/SideBattleField/BattleFormation/SummonSlot_2/Slot2Name") else null
@onready var slot2_sprite: TextureRect = $CombatUI/SideBattleField/BattleFormation/SummonSlot_2/Slot2Sprite if has_node("CombatUI/SideBattleField/BattleFormation/SummonSlot_2/Slot2Sprite") else null
@onready var slot2_hp_bar: ProgressBar = $CombatUI/SideBattleField/BattleFormation/SummonSlot_2/Slot2HPBar if has_node("CombatUI/SideBattleField/BattleFormation/SummonSlot_2/Slot2HPBar") else null
@onready var slot2_status_label: Label = $CombatUI/SideBattleField/BattleFormation/SummonSlot_2/Slot2StatusLabel if has_node("CombatUI/SideBattleField/BattleFormation/SummonSlot_2/Slot2StatusLabel") else null

var companion_textures: Dictionary = {
	"vargas": preload("res://core/battle/vargas_summon.webp"),
	"kaelen": preload("res://core/battle/kaelen_summon.webp"),
	"lyra": preload("res://core/battle/lyra_summon.webp"),
	"boros": preload("res://core/battle/boros_summon.webp"),
	"malakor": preload("res://core/battle/inquisitor_summon.webp"),
	"default": preload("res://battlefield/assets/minion_vargas.svg")
}

var _shadow_mat_left: ShaderMaterial = null
var _shadow_mat_right: ShaderMaterial = null
var _slot_sprites_base_y: Array[float] = []
var _slot_silhouette_shadows: Array[TextureRect] = []
var _hero_silhouette_shadow: TextureRect = null

func _get_shadow_material(facing_left: bool) -> ShaderMaterial:
	if facing_left:
		if _shadow_mat_left == null:
			_shadow_mat_left = ShaderMaterial.new()
			_shadow_mat_left.shader = preload("res://battlefield/battle_arena/character_shadow.gdshader")
			_shadow_mat_left.set_shader_parameter("skew_x", -0.25)
		return _shadow_mat_left
	else:
		if _shadow_mat_right == null:
			_shadow_mat_right = ShaderMaterial.new()
			_shadow_mat_right.shader = preload("res://battlefield/battle_arena/character_shadow.gdshader")
			_shadow_mat_right.set_shader_parameter("skew_x", 0.25)
		return _shadow_mat_right

func _get_character_visual_profile(raw_name: String) -> Dictionary:
	var key = raw_name.strip_edges().to_lower()
	if CHARACTER_VISUAL_PROFILES.has(key):
		return CHARACTER_VISUAL_PROFILES[key]
	for k in CHARACTER_VISUAL_PROFILES.keys():
		if k in key or key in k:
			return CHARACTER_VISUAL_PROFILES[k]
	if key.contains("golem"):
		return {"scale": 1.28, "y_offset": 0.0, "shadow_scale": 1.28, "shadow_y": 0.0}
	if key.contains("vargas"):
		return {"scale": 1.25, "y_offset": 2.0, "shadow_scale": 1.26, "shadow_y": 0.0}
	if key.contains("hound"):
		return {"scale": 0.83, "y_offset": 3.5, "shadow_scale": 0.85, "shadow_y": -2.0}
	return {"scale": 1.0, "y_offset": 0.0, "shadow_scale": 1.0, "shadow_y": 0.0}

func _setup_hero_and_summon_shadows() -> void:
	if hero_sprite != null and is_instance_valid(hero_sprite):
		var hp = hero_sprite.get_parent()
		if hp != null and hp.get_node_or_null("HeroSilhouette") == null:
			_hero_silhouette_shadow = TextureRect.new()
			_hero_silhouette_shadow.name = "HeroSilhouette"
			_hero_silhouette_shadow.texture = hero_sprite.texture
			_hero_silhouette_shadow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			_hero_silhouette_shadow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			_hero_silhouette_shadow.size = hero_sprite.size
			_hero_silhouette_shadow.position = hero_sprite.position
			_hero_silhouette_shadow.pivot_offset = Vector2(hero_sprite.size.x * 0.5, hero_sprite.size.y * 0.95)
			_hero_silhouette_shadow.scale = Vector2(1.05, 0.28)
			_hero_silhouette_shadow.material = _get_shadow_material(false)
			_hero_silhouette_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
			hp.add_child(_hero_silhouette_shadow)
			hp.move_child(_hero_silhouette_shadow, hero_sprite.get_index())
		hero_sprite.pivot_offset = Vector2(hero_sprite.size.x * 0.5, hero_sprite.size.y * 0.95)

	_slot_sprites_base_y.clear()
	_slot_silhouette_shadows.clear()
	for spr in _get_slot_sprites():
		if spr != null and is_instance_valid(spr):
			_slot_sprites_base_y.append(spr.position.y)
			var p = spr.get_parent()
			var sil = p.get_node_or_null("SlotSilhouette") as TextureRect
			if sil == null:
				sil = TextureRect.new()
				sil.name = "SlotSilhouette"
				sil.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				sil.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				sil.size = spr.size
				sil.position = spr.position
				sil.pivot_offset = Vector2(spr.size.x * 0.5, spr.size.y * 0.95)
				sil.material = _get_shadow_material(false)
				sil.mouse_filter = Control.MOUSE_FILTER_IGNORE
				sil.visible = false
				p.add_child(sil)
				p.move_child(sil, spr.get_index())
			_slot_silhouette_shadows.append(sil)

# Combat Feedback & Controls
@onready var combat_log_label: Label = find_child("CombatLogLabel", true, false) as Label
@onready var hand_area: Control = $CombatUI/HandArea
@onready var end_turn_button: Button = $CombatUI/BottomControls/EndTurnButton
@onready var help_button: Button = $CombatUI/BottomControls/HelpButton
@onready var auto_battle_button: Button = $CombatUI/BottomControls/AutoBattleButton if has_node("CombatUI/BottomControls/AutoBattleButton") else null
@onready var speed_button: Button = $CombatUI/BottomControls/SpeedButton if has_node("CombatUI/BottomControls/SpeedButton") else null
@onready var debug_skip_button: Button = $CombatUI/DebugSkipButton
@onready var vfx_layer: Control = $CombatUI/VFXLayer

var auto_battle_enabled: bool = false
var auto_battle_speed: float = 1.0
var _auto_battle_loop_active: bool = false
var inspect_callout_panel: Panel = null
var _inspected_enemy_index: int = -1
var _inspect_tween: Tween = null
var _inspect_open_msec: int = 0

# Tutorial & Dialogue Overlays
@onready var tutorial_overlay: ColorRect = $TutorialOverlay
@onready var tutorial_guide_panel: Panel = $TutorialOverlay/TutorialGuidePanel
@onready var guide_title_label: Label = find_child("GuideTitle", true, false) as Label
@onready var guide_content_label: Label = find_child("GuideContent", true, false) as Label
@onready var guide_image: TextureRect = find_child("GuideImage", true, false) as TextureRect
@onready var next_guide_button: Button = find_child("NextGuideButton", true, false) as Button
@onready var close_guide_button: Button = find_child("CloseGuideButton", true, false) as Button

@onready var event_overlay: ColorRect = $EventOverlay
@onready var speaker_label: Label = find_child("SpeakerLabel", true, false) as Label
@onready var message_label: Label = $EventOverlay/Panel/MessageLabel

@onready var victory_overlay: ColorRect = $VictoryOverlay
@onready var victory_button: Button = $VictoryOverlay/VictoryPanel/VictoryButton
@onready var claim_card_modal: ClaimCardModal = $ClaimCardModal

# Encounter & State
var encounter_res: EncounterData = null
var is_tutorial: bool = false
var dialog_lines: Array = []
var current_dialog_index: int = 0
var _last_advance_msec: int = 0

# Player Combat Stats
var player_hp: int = 30
var player_max_hp: int = 30
var player_block: int = 0
var player_energy: int = 3
var max_energy: int = 3
var combat_turn_count: int = 1

var vanguard_active: bool = false
var vanguard_hp: int = 0
var vanguard_max_hp: int = 12

const MAX_SUMMON_SLOTS: int = 3
var active_summons: Array[Dictionary] = []

# Slay the Spire 2 Active Deck (10 Cards Max)
const MAX_ACTIVE_DECK: int = 10
var draw_pile: Array[CardData] = []
var hand_cards: Array[CardUI] = []
var discard_pile: Array[CardData] = []

# Enemy Combatants & Target Selection
var enemies: Array[Dictionary] = []
var enemy_ui_nodes: Array[Control] = []
var selected_target_index: int = 0
var _dead_enemy_notified: Dictionary = {}

# Targeting Curve & Drag State
var targeting_line: Line2D = null
var targeting_reticle_tip: TextureRect = null
var active_drag_card: CardUI = null

# Tutorial Tips
var current_guide_step: int = 0
const TUTORIAL_TIPS = [
	{
		"title": "⚔ 1. SOUL ENERGY",
		"content": "You possess 3 Soul Energy per turn (top-center). Every card costs energy to cast. Spend it wisely to balance attack and minion defense.",
		"image": "res://ui/energy_display_ui.webp"
	},
	{
		"title": "🎯 2. TARGETING ENEMIES",
		"content": "Tap any enemy to target them, or drag a card directly toward an enemy with the targeting arrow! Both tap and drag targeting work together seamlessly.",
		"image": "res://core/battle/target_battle.webp"
	},
	{
		"title": "🛡 3. INTENTS & AFFLICTIONS",
		"content": "Above enemies: Action Intents (⚔ Attack, 🛡 Defend, 💀 Buff). Below enemies: Afflictions (🩸 Vulnerable +50% dmg, 💥 Weak, ☠ Poison)!",
		"image": "res://battlefield/assets/cards/vargas_bulwark.webp"
	},
	{
		"title": "🔄 4. ENDING TURNS",
		"content": "When energy is spent, click [End Turn]. Your grimoire draws from your 10-card deck, recycling discards when exhausted.",
		"image": "res://core/battle/vargas_summon.webp"
	}
]

func _ready() -> void:
	if hero_texture != null and hero_sprite != null:
		hero_sprite.texture = hero_texture
	if vanguard_container != null:
		vanguard_container.visible = false
	if slot1_container != null:
		slot1_container.visible = false
	if slot2_container != null:
		slot2_container.visible = false
	_connect_signals()
	_setup_targeting_vfx()
	_setup_hero_and_summon_shadows()
	_load_encounter_parameters()
	_setup_deck()
	_setup_combatants()
	_update_stats_ui()
	_update_summon_slots_ui()
	if hand_area != null:
		hand_area.z_index = 0
	
	# Initial Target Selection: Foremost enemy
	_auto_select_next_living_target()
	
	# Point 1: Hide all combat UI until dialogue finishes
	if dialog_lines.size() > 0:
		combat_ui.visible = false
		tutorial_overlay.visible = false
		_show_dialog()
	else:
		combat_ui.visible = true
		_start_player_turn()
		if is_tutorial:
			_show_tutorial_guide(0)

func _connect_signals() -> void:
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	if help_button != null:
		help_button.pressed.connect(func(): _show_tutorial_guide(0))
	if auto_battle_button != null:
		auto_battle_button.pressed.connect(_on_auto_battle_toggle)
	if speed_button != null:
		speed_button.pressed.connect(_on_speed_toggle)
	if debug_skip_button != null:
		debug_skip_button.visible = GameManager.debug_battle_skip
		debug_skip_button.pressed.connect(_on_victory)
	if next_guide_button != null:
		next_guide_button.pressed.connect(_on_next_guide_step)
	if close_guide_button != null:
		close_guide_button.pressed.connect(_on_close_guide_pressed)
	if victory_button != null:
		victory_button.pressed.connect(_on_finish_battle)
	if claim_card_modal != null:
		claim_card_modal.cards_claimed.connect(_on_cards_drafted)

func _load_encounter_parameters() -> void:
	var tres_path: String = GameManager.active_params.get("encounter_tres", "")
	if not tres_path.is_empty() and ResourceLoader.exists(tres_path):
		encounter_res = load(tres_path) as EncounterData
		
	is_tutorial = GameManager.active_params.get("is_tutorial", false)
	dialog_lines = GameManager.active_params.get("tutorial_dialog", [])
	
	if encounter_res != null:
		title_label.text = encounter_res.title
		if encounter_res.bg_texture != null:
			background_texture.texture = encounter_res.bg_texture
		if not is_tutorial and (encounter_res.id == "ch1_battle_tutorial" or encounter_res.difficulty.to_lower() == "tutorial"):
			is_tutorial = true
		if dialog_lines.is_empty() and encounter_res.tutorial_dialog.size() > 0:
			dialog_lines = encounter_res.tutorial_dialog
	else:
		title_label.text = "BATTLE ARENA"

	# Load persistent crusade HP from GameManager
	if GameManager.crusade_hero_hp > 0:
		player_hp = GameManager.crusade_hero_hp
		player_max_hp = GameManager.crusade_max_hp
	else:
		player_hp = 30
		player_max_hp = 30
		GameManager.crusade_hero_hp = 30
		GameManager.crusade_max_hp = 30

	# Chapter-based Max Energy scaling: Ch1 (3), Ch2 (4), Ch3 (5)
	var chapter = GameManager.active_params.get("chapter", "")
	var enc_id = encounter_res.id.to_lower() if encounter_res != null else ""
	if chapter == "chapter_3" or chapter == "ch3" or enc_id.begins_with("ch3"):
		max_energy = 5
	elif chapter == "chapter_2" or chapter == "ch2" or enc_id.begins_with("ch2"):
		max_energy = 4
	else:
		max_energy = 3
	player_energy = max_energy

# ----------------- Deck Management -----------------
func _setup_deck() -> void:
	draw_pile.clear()
	discard_pile.clear()
	combat_turn_count = 1
	
	var source_cards: Array = []
	if GameManager.active_deck != null and GameManager.active_deck.cards.size() > 0:
		source_cards = GameManager.active_deck.cards.duplicate()
	else:
		# Starter 10-card deck (4 Pale Smite, 4 Grave Ward, 1 Vargas Bulwark, 1 Kaelen Volley)
		var c_vargas = load("res://core/cards/data/vargas_bulwark.tres") as CardData
		var c_pale = load("res://core/cards/data/pale_smite.tres") as CardData
		var c_ward = load("res://core/cards/data/grave_ward.tres") as CardData
		var c_kaelen = load("res://core/cards/data/kaelen_volley.tres") as CardData
		source_cards = [c_pale, c_pale, c_pale, c_pale, c_ward, c_ward, c_ward, c_ward, c_vargas, c_kaelen]
		
	for card in source_cards:
		if card != null:
			draw_pile.append(card)
			
	draw_pile.shuffle()

func _draw_cards(count: int) -> void:
	for i in range(count):
		if hand_cards.size() >= 6:
			break
		if draw_pile.is_empty():
			if discard_pile.is_empty():
				break
			# Reshuffle discard pile into draw pile
			draw_pile = discard_pile.duplicate()
			discard_pile.clear()
			draw_pile.shuffle()
			combat_log_label.text = "Reshuffled Grimoire Discard Pile into Draw Pile."
			
		var card_data = draw_pile.pop_front()
		_spawn_card_to_hand(card_data)
		
	_resort_hand(true)
	_update_stats_ui()
	_update_hand_card_modes()

func _spawn_card_to_hand(card_data: CardData) -> void:
	if card_data == null:
		return
	var card_inst = card_scene.instantiate() as CardUI
	card_inst.card_data = card_data
	card_inst.disable_internal_hover = true
	card_inst.custom_minimum_size = Vector2(170, 240)
	card_inst.size = Vector2(170, 240)
	card_inst.pivot_offset = Vector2(85.0, 200.0)
	
	card_inst.card_clicked.connect(_on_card_clicked.bind(card_inst))
	card_inst.card_hovered.connect(_on_card_hovered)
	card_inst.card_unhovered.connect(_on_card_unhovered)
	card_inst.card_drag_started.connect(_on_card_drag_started)
	card_inst.card_drag_moved.connect(_on_card_drag_moved)
	card_inst.card_drag_ended.connect(_on_card_drag_ended)
	card_inst.set_playable(_is_card_playable(card_data))
	
	hand_area.add_child(card_inst)
	hand_cards.append(card_inst)

# ----------------- Slay the Spire 2 Fan Rotation & Resorting -----------------
func _resort_hand(animated: bool = true) -> void:
	var total: int = hand_cards.size()
	if total == 0:
		return
		
	var area_w: float = hand_area.size.x
	if area_w <= 100.0:
		area_w = 1100.0
		
	var center_x: float = area_w / 2.0
	var base_y: float = 20.0
	var max_angle_deg: float = minf(26.0, float(total - 1) * 6.5)
	var card_spacing: float = minf(135.0, 750.0 / maxf(1.0, float(total - 1)))
	
	for i in range(total):
		var card = hand_cards[i]
		if not is_instance_valid(card):
			continue
			
		var norm: float = 0.0
		if total > 1:
			norm = (float(i) - float(total - 1) / 2.0) / (float(total - 1) / 2.0)
			
		var rot_rad: float = norm * deg_to_rad(max_angle_deg / 2.0)
		var target_x: float = center_x + (float(i) - float(total - 1) / 2.0) * card_spacing - 85.0
		var target_y: float = base_y + absf(norm) * 22.0
		var target_pos: Vector2 = Vector2(target_x, target_y)
		var target_scale: Vector2 = Vector2(0.82, 0.82)
		
		card.set_meta("fan_pos", target_pos)
		card.set_meta("fan_rot", rot_rad)
		card.set_meta("fan_z", i)
		card.z_index = i
		
		if animated:
			var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tw.tween_property(card, "position", target_pos, 0.24)
			tw.tween_property(card, "rotation", rot_rad, 0.24)
			tw.tween_property(card, "scale", target_scale, 0.24)
		else:
			card.position = target_pos
			card.rotation = rot_rad
			card.scale = target_scale

func _on_card_hovered(card: CardUI) -> void:
	if not is_instance_valid(card) or not hand_cards.has(card) or active_drag_card != null:
		return
	card.z_index = 70
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(card, "rotation", 0.0, 0.12)
	tw.tween_property(card, "scale", Vector2(1.0, 1.0), 0.12)
	tw.tween_property(card, "position:y", -45.0, 0.12)

func _on_card_unhovered(card: CardUI) -> void:
	if not is_instance_valid(card) or not hand_cards.has(card) or active_drag_card != null:
		return
	var orig_pos = card.get_meta("fan_pos", card.position)
	var orig_rot = card.get_meta("fan_rot", 0.0)
	var orig_z = card.get_meta("fan_z", 0)
	card.z_index = orig_z
	
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(card, "rotation", orig_rot, 0.14)
	tw.tween_property(card, "scale", Vector2(0.82, 0.82), 0.14)
	tw.tween_property(card, "position", orig_pos, 0.14)

# ----------------- Drag & Targeting Curve Systems -----------------
func _setup_targeting_vfx() -> void:
	targeting_line = Line2D.new()
	targeting_line.name = "TargetingLine"
	targeting_line.width = 6.0
	targeting_line.default_color = Color(0.3, 0.9, 1.0, 0.9)
	targeting_line.joint_mode = Line2D.LINE_JOINT_ROUND
	targeting_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	targeting_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	targeting_line.visible = false
	targeting_line.z_index = 50
	
	var grad = Gradient.new()
	grad.set_color(0, Color(0.2, 0.6, 1.0, 0.45))
	grad.set_color(1, Color(0.4, 0.95, 1.0, 0.95))
	targeting_line.gradient = grad
	
	vfx_layer.add_child(targeting_line)
	
	targeting_reticle_tip = TextureRect.new()
	targeting_reticle_tip.name = "TargetingReticleTip"
	targeting_reticle_tip.texture = target_reticle_texture
	targeting_reticle_tip.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	targeting_reticle_tip.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	targeting_reticle_tip.size = Vector2(40, 40)
	targeting_reticle_tip.pivot_offset = Vector2(20, 20)
	targeting_reticle_tip.modulate = Color.WHITE
	targeting_reticle_tip.visible = false
	targeting_reticle_tip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	targeting_reticle_tip.z_index = 51
	vfx_layer.add_child(targeting_reticle_tip)

func _on_card_drag_started(card: CardUI, global_pos: Vector2) -> void:
	if event_overlay.visible or tutorial_overlay.visible:
		return
	_hide_enemy_inspect_callout()
	active_drag_card = card
	card.z_index = 80
	
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(card, "rotation", 0.0, 0.1)
	tw.tween_property(card, "scale", Vector2(0.95, 0.95), 0.1)
	tw.tween_property(card, "position:y", -50.0, 0.1)
	
	_update_drag_targeting(card, global_pos)

func _on_card_drag_moved(card: CardUI, global_pos: Vector2) -> void:
	if active_drag_card != card:
		return
	_update_drag_targeting(card, global_pos)

func _get_card_drag_type(card: CardUI) -> int:
	if card == null or card.card_data == null:
		return DragTargetType.GENERAL_ARENA
		
	var data = card.card_data
	
	# 1. Unsummon / Burst mode or Minion targeting cards
	if card.is_unsummon_mode:
		return DragTargetType.ALLY_SUMMON
		
	if data.card_type == CardData.CardType.SUMMON:
		var has_existing = _find_active_summon_index_for_card(data) != -1
		var slots_full = active_summons.size() >= MAX_SUMMON_SLOTS
		if has_existing or slots_full:
			return DragTargetType.ALLY_SUMMON
		else:
			return DragTargetType.SUMMON_SPAWN
			
	if data.id == "charnel_sacrifice" or data.target_type == CardData.TargetType.MINION:
		return DragTargetType.ALLY_SUMMON
		
	# 2. Enemy targets
	if data.target_type == CardData.TargetType.ENEMY_ALL:
		return DragTargetType.ENEMY_ALL
		
	if data.card_type == CardData.CardType.ATTACK or data.target_type == CardData.TargetType.ENEMY_SINGLE:
		return DragTargetType.ENEMY_SINGLE
		
	# 3. Ally / Hero target (Skills, Shields, Self-buffs)
	if data.target_type == CardData.TargetType.SELF or data.card_type == CardData.CardType.SKILL:
		return DragTargetType.ALLY_HERO
		
	return DragTargetType.GENERAL_ARENA

func _get_hero_center() -> Vector2:
	if is_instance_valid(battle_formation) and battle_formation.hero_slot != null:
		return battle_formation.hero_slot.get_global_rect().get_center()
	if is_instance_valid(hero_sprite):
		return hero_sprite.get_global_rect().get_center()
	return Vector2(100.0, 200.0)

func _find_closest_enemy_magnet(global_pos: Vector2, max_dist: float = 200.0) -> int:
	var closest_idx: int = -1
	var closest_dist: float = max_dist * max_dist
	for i in range(enemy_ui_nodes.size()):
		if i >= enemies.size() or enemies[i]["hp"] <= 0:
			continue
		var node = enemy_ui_nodes[i]
		if not is_instance_valid(node) or not node.is_visible_in_tree():
			continue
		var rect = node.get_global_rect()
		var center = rect.get_center()
		if rect.grow(32.0).has_point(global_pos):
			return i
		var d2 = global_pos.distance_squared_to(center)
		if d2 < closest_dist:
			closest_dist = d2
			closest_idx = i
	return closest_idx

func _get_all_enemies_center() -> Vector2:
	var total_pos = Vector2.ZERO
	var count = 0
	for i in range(enemy_ui_nodes.size()):
		if i < enemies.size() and enemies[i]["hp"] > 0:
			var node = enemy_ui_nodes[i]
			if is_instance_valid(node) and node.is_visible_in_tree():
				total_pos += node.get_global_rect().get_center()
				count += 1
	if count > 0:
		return total_pos / float(count)
	return Vector2(900.0, 200.0)

func _find_closest_summon_magnet(global_pos: Vector2, max_dist: float = 200.0) -> int:
	var closest_idx: int = -1
	var closest_dist: float = max_dist * max_dist
	var containers = _get_slot_containers()
	for s_idx in range(active_summons.size()):
		var slot_idx: int = active_summons[s_idx].get("slot_index", -1)
		if slot_idx >= 0 and slot_idx < containers.size():
			var c = containers[slot_idx]
			if is_instance_valid(c):
				var center = c.get_global_rect().get_center()
				if c.get_global_rect().grow(35.0).has_point(global_pos):
					return s_idx
				var d2 = global_pos.distance_squared_to(center)
				if d2 < closest_dist:
					closest_dist = d2
					closest_idx = s_idx
	return closest_idx

func _get_free_summon_slot_center() -> Vector2:
	var used_slots: Array[int] = []
	for s in active_summons:
		used_slots.append(s.get("slot_index", 0))
	var free_slot = 0
	for i in range(MAX_SUMMON_SLOTS):
		if not used_slots.has(i):
			free_slot = i
			break
	var containers = _get_slot_containers()
	if free_slot < containers.size() and is_instance_valid(containers[free_slot]):
		return containers[free_slot].get_global_rect().get_center()
	return Vector2(300.0, 200.0)

func _on_card_drag_ended(card: CardUI, global_pos: Vector2) -> void:
	if targeting_line != null:
		targeting_line.visible = false
	if targeting_reticle_tip != null:
		targeting_reticle_tip.visible = false
	active_drag_card = null
	
	var drag_type = _get_card_drag_type(card)
	
	var is_above_hand = global_pos.y < (hand_area.global_position.y - 20.0)
	var hovered_enemy_idx = _find_closest_enemy_magnet(global_pos, 160.0)
	var hovered_summon_idx = _find_closest_summon_magnet(global_pos, 160.0)
	var hero_center = _get_hero_center()
	var near_hero = global_pos.distance_to(hero_center) < 180.0
	
	if hovered_enemy_idx != -1 or hovered_summon_idx != -1 or near_hero:
		is_above_hand = true
		
	if not is_above_hand:
		_cancel_card_drag(card)
		return

	match drag_type:
		DragTargetType.ENEMY_SINGLE:
			# Reject attacks dragged onto player / allies!
			if _is_point_over_allies(global_pos):
				combat_log_label.text = "⚠️ Attacks can only target enemies!"
				_spawn_floating_text("TARGET ENEMY", card.global_position, Color(1.0, 0.4, 0.4))
				_cancel_card_drag(card)
				return
				
			if hovered_enemy_idx != -1:
				_select_target_enemy(hovered_enemy_idx)
				_on_card_played(card.card_data, card)
				return
				
			# Dropped in general combat arena: use selected enemy or next alive
			if selected_target_index >= 0 and selected_target_index < enemies.size() and enemies[selected_target_index]["hp"] > 0:
				_on_card_played(card.card_data, card)
				return
			else:
				var next_alive = _get_first_alive_enemy_index()
				if next_alive != -1:
					_select_target_enemy(next_alive)
					_on_card_played(card.card_data, card)
					return
				else:
					combat_log_label.text = "⚠️ No living enemies remaining!"
					_cancel_card_drag(card)
					return

		DragTargetType.ENEMY_ALL:
			if _is_point_over_allies(global_pos):
				combat_log_label.text = "⚠️ AOE attacks target enemies!"
				_spawn_floating_text("TARGET ENEMIES", card.global_position, Color(1.0, 0.4, 0.4))
				_cancel_card_drag(card)
				return
			_on_card_played(card.card_data, card)

		DragTargetType.ALLY_HERO:
			_on_card_played(card.card_data, card)

		DragTargetType.ALLY_SUMMON:
			if active_summons.is_empty():
				combat_log_label.text = "⚠️ Requires an active summon to detonate/sacrifice!"
				_spawn_floating_text("NO SUMMON", card.global_position, Color(1.0, 0.4, 0.4))
				_cancel_card_drag(card)
				return
			if hovered_summon_idx != -1:
				_on_unsummon_played(card, hovered_summon_idx)
				return
			else:
				var target_s_idx = _find_active_summon_index_for_card(card.card_data)
				if target_s_idx == -1 and active_summons.size() > 0:
					target_s_idx = 0
				if target_s_idx != -1:
					_on_unsummon_played(card, target_s_idx)
					return
				else:
					_on_card_played(card.card_data, card)
					return

		DragTargetType.SUMMON_SPAWN:
			if active_summons.size() >= MAX_SUMMON_SLOTS:
				combat_log_label.text = "⚠️ Summon slots are full (3/3)!"
				_spawn_floating_text("SLOTS FULL", card.global_position, Color(1.0, 0.4, 0.4))
				_cancel_card_drag(card)
				return
			_on_card_played(card.card_data, card)

		_:
			_on_card_played(card.card_data, card)

func _cancel_card_drag(card: CardUI) -> void:
	_resort_hand(true)

func _update_drag_targeting(card: CardUI, global_pos: Vector2) -> void:
	if targeting_line == null or targeting_reticle_tip == null:
		return
		
	var drag_type = _get_card_drag_type(card)
	var hovered_enemy_idx = _find_enemy_under_point(global_pos)
	if hovered_enemy_idx != -1:
		_select_target_enemy(hovered_enemy_idx)
		
	var start_pos = card.global_position + Vector2(card.size.x * 0.5 * card.scale.x, 15.0)
	var end_pos = global_pos
	
	match drag_type:
		DragTargetType.ENEMY_SINGLE:
			targeting_line.default_color = Color(1.0, 0.35, 0.35, 0.95)
			targeting_reticle_tip.modulate = Color(1.0, 0.35, 0.35, 0.95)
			var magnet_enemy_idx = _find_closest_enemy_magnet(global_pos, 220.0)
			if magnet_enemy_idx != -1:
				_select_target_enemy(magnet_enemy_idx)
				var enemy_node = enemy_ui_nodes[magnet_enemy_idx]
				end_pos = enemy_node.get_global_rect().get_center()
				
		DragTargetType.ENEMY_ALL:
			targeting_line.default_color = Color(0.88, 0.45, 1.0, 0.95)
			targeting_reticle_tip.modulate = Color(0.88, 0.45, 1.0, 0.95)
			var aoe_center = _get_all_enemies_center()
			if global_pos.distance_to(aoe_center) < 260.0 or global_pos.x > (get_viewport_rect().size.x * 0.45):
				end_pos = aoe_center
				
		DragTargetType.ALLY_HERO:
			targeting_line.default_color = Color(0.35, 0.85, 1.0, 0.95)
			targeting_reticle_tip.modulate = Color(0.35, 0.85, 1.0, 0.95)
			var hero_center = _get_hero_center()
			if global_pos.distance_to(hero_center) < 240.0 or global_pos.x < (get_viewport_rect().size.x * 0.32):
				end_pos = hero_center
				
		DragTargetType.ALLY_SUMMON:
			targeting_line.default_color = Color(1.0, 0.68, 0.25, 0.95)
			targeting_reticle_tip.modulate = Color(1.0, 0.68, 0.25, 0.95)
			var magnet_summon_idx = _find_closest_summon_magnet(global_pos, 220.0)
			if magnet_summon_idx != -1:
				var containers = _get_slot_containers()
				var slot_idx: int = active_summons[magnet_summon_idx].get("slot_index", -1)
				if slot_idx >= 0 and slot_idx < containers.size():
					end_pos = containers[slot_idx].get_global_rect().get_center()
			elif active_summons.size() > 0:
				var def_slot_idx: int = active_summons[0].get("slot_index", 0)
				var containers = _get_slot_containers()
				if def_slot_idx < containers.size():
					var def_center = containers[def_slot_idx].get_global_rect().get_center()
					if global_pos.distance_to(def_center) < 240.0:
						end_pos = def_center
						
		DragTargetType.SUMMON_SPAWN:
			targeting_line.default_color = Color(0.35, 1.0, 0.65, 0.95)
			targeting_reticle_tip.modulate = Color(0.35, 1.0, 0.65, 0.95)
			var free_center = _get_free_summon_slot_center()
			if global_pos.distance_to(free_center) < 240.0 or (global_pos.x > 140.0 and global_pos.x < 620.0 and global_pos.y < 360.0):
				end_pos = free_center
				
		_:
			targeting_line.default_color = Color(0.75, 0.65, 1.0, 0.9)
			targeting_reticle_tip.modulate = Color(0.75, 0.65, 1.0, 0.95)
			
	var p0 = targeting_line.to_local(start_pos)
	var p2 = targeting_line.to_local(end_pos)
	
	var curve_pts = _calculate_bezier_points(p0, p2, 18)
	targeting_line.points = curve_pts
	targeting_line.visible = true
	
	targeting_reticle_tip.global_position = end_pos - targeting_reticle_tip.size * 0.5
	if curve_pts.size() >= 2:
		var last_dir = (curve_pts[curve_pts.size() - 1] - curve_pts[curve_pts.size() - 2]).normalized()
		targeting_reticle_tip.rotation = last_dir.angle() + PI * 0.5
	targeting_reticle_tip.visible = true

func _calculate_bezier_points(p0: Vector2, p2: Vector2, segments: int = 18) -> PackedVector2Array:
	var points = PackedVector2Array()
	var mid_x = (p0.x + p2.x) * 0.5
	var delta_y = absf(p2.y - p0.y)
	var p1 = Vector2(mid_x, minf(p0.y, p2.y) - maxf(100.0, delta_y * 0.4))
	
	for s in range(segments + 1):
		var t = float(s) / float(segments)
		var q0 = p0.lerp(p1, t)
		var q1 = p1.lerp(p2, t)
		var pt = q0.lerp(q1, t)
		points.append(pt)
		
	return points

func _find_enemy_under_point(global_pos: Vector2) -> int:
	return _find_closest_enemy_magnet(global_pos, 50.0)

func _get_enemy_texture(e_name: String) -> Texture2D:
	var key: String = e_name.strip_edges().to_lower()
	var all_dicts: Array = [CHAPTER_1_ENEMY_TEXTURES, CHAPTER_2_ENEMY_TEXTURES, CHAPTER_3_ENEMY_TEXTURES]
	for d in all_dicts:
		if d.has(key):
			return d[key]
	for d in all_dicts:
		for k in d.keys():
			if k in key or key in k:
				return d[k]
	if key.contains("farmer"):
		return farmer_texture
	return scout_texture

# ----------------- Enemies, Targeting & Afflictions (Side-View) -----------------
func _setup_combatants() -> void:
	for node in enemy_ui_nodes:
		if is_instance_valid(node):
			node.queue_free()
	enemy_ui_nodes.clear()
	enemies.clear()
	_dead_enemy_notified.clear()
	
	var chapter = GameManager.active_params.get("chapter", "")
	var enemy_names: Array = GameManager.active_params.get("generated_enemies", [])
	if enemy_names.is_empty():
		enemy_names = EncounterGenerator.get_enemies_for_encounter(encounter_res, chapter)
	
	for i in range(enemy_names.size()):
		var e_name = str(enemy_names[i])
		var max_hp = 14 + (i * 6)
		var dmg = 4 + (i * 2)

		# Specialized archetype stats for Act 1, 2, and 3
		if e_name.contains("Alden"):
			max_hp = 58
			dmg = 7
		elif e_name.contains("Malakor"):
			max_hp = 38
			dmg = 6
		elif e_name.contains("Golem"):
			max_hp = 32
			dmg = 6
		elif e_name.contains("Lorian") or e_name.contains("Vane"):
			max_hp = 32
			dmg = 6
		elif e_name.contains("Knight") or e_name.contains("Champion"):
			max_hp = 26
			dmg = 5
		elif e_name.contains("Captain") or e_name.contains("Boros"):
			max_hp = 34
			dmg = 6

		var tex: Texture2D = _get_enemy_texture(e_name)
			
		var enemy_data: Dictionary = {
			"name": e_name,
			"hp": max_hp,
			"max_hp": max_hp,
			"damage": dmg,
			"block": 0,
			"thorns": 0,
			"intent_type": "attack",
			"intent_val": dmg,
			"texture": tex,
			"afflictions": {
				"vulnerable": 0,
				"weak": 0,
				"bleed": 0
			}
		}
		enemies.append(enemy_data)
		_create_enemy_ui(enemy_data, i)

func _damage_enemy(target_idx: int, dmg: int) -> int:
	if target_idx < 0 or target_idx >= enemies.size() or enemies[target_idx]["hp"] <= 0:
		return 0
	var enemy = enemies[target_idx]
	var cur_block: int = enemy.get("block", 0)
	var unblocked = maxi(0, dmg - cur_block)
	enemy["block"] = maxi(0, cur_block - dmg)
	enemy["hp"] -= unblocked

	if cur_block > 0 and target_idx < enemy_ui_nodes.size():
		var absorbed = mini(cur_block, dmg)
		var e_pos = enemy_ui_nodes[target_idx].global_position + Vector2(40, -20)
		_spawn_floating_text("GUARDED -%d" % absorbed, e_pos, Color(0.4, 0.8, 1.0))

	# Enemy Thorns / Riposte recoil
	if enemy.get("thorns", 0) > 0 and dmg > 0:
		var recoil: int = enemy["thorns"]
		player_hp = maxi(0, player_hp - recoil)
		if is_instance_valid(hero_sprite):
			_spawn_floating_text("RIPOSTE! -%d HP" % recoil, hero_sprite.global_position + Vector2(0, -30), Color(1.0, 0.3, 0.3))
			_shake_node(hero_sprite)
		combat_log_label.text += " (Riposte: -%d HP)" % recoil

	return unblocked

func _create_enemy_ui(data: Dictionary, index: int) -> void:
	var container = Control.new()
	container.name = "Enemy_%d" % index
	container.custom_minimum_size = Vector2(210, 310)
	container.size = Vector2(210, 310)
	container.mouse_filter = Control.MOUSE_FILTER_STOP
	container.gui_input.connect(_on_enemy_input.bind(index))
	
	var slot = battle_formation.get_enemy_slot(index) if battle_formation != null else null
	if slot != null:
		container.z_index = slot.z_index
	else:
		container.z_index = 4 - index
		
	var content = Control.new()
	content.name = "Content"
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	container.add_child(content)
	
	var e_name = data.get("name", "")
	var prof = _get_character_visual_profile(e_name)
	var scale_val: float = prof["scale"]
	var y_off: float = prof["y_offset"]
	var sh_scale: float = scale_val * prof.get("shadow_scale", 1.0)

	# Dynamic Y position for intention panel and targeting reticle based on character scale & height
	var intent_y: float = 6.0 + y_off - 195.0 * (scale_val - 1.0) + prof.get("intent_y_adjust", 0.0)
	var reticle_y: float = intent_y - 54.0

	# Reticle Icon (Rendered behind IntentBadge, enlarged to 100x100 with eyes resting above intention)
	var reticle_icon = TextureRect.new()
	reticle_icon.name = "ReticleIcon"
	reticle_icon.texture = target_reticle_texture
	reticle_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	reticle_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	reticle_icon.size = Vector2(100, 100)
	reticle_icon.pivot_offset = Vector2(50, 50)
	reticle_icon.position = Vector2(55, reticle_y)
	reticle_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reticle_icon.visible = (index == selected_target_index)
	content.add_child(reticle_icon)
	
	# 1. Above Enemy: Action Intent Badge (Icon + Value) - Tap to inspect!
	var intent_bg = Panel.new()
	intent_bg.name = "IntentBadge"
	intent_bg.size = Vector2(84, 28)
	intent_bg.position = Vector2(63, intent_y)
	intent_bg.mouse_filter = Control.MOUSE_FILTER_PASS
	intent_bg.gui_input.connect(func(event):
		var is_click = (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventScreenTouch and event.pressed)
		if is_click:
			_on_enemy_info_pressed(index)
			get_viewport().set_input_as_handled()
	)
	
	var style_intent = StyleBoxFlat.new()
	style_intent.bg_color = Color(0.18, 0.05, 0.08, 0.95)
	style_intent.set_border_width_all(1)
	style_intent.border_color = Color(0.95, 0.35, 0.35, 0.85)
	style_intent.set_corner_radius_all(6)
	intent_bg.add_theme_stylebox_override("panel", style_intent)
	content.add_child(intent_bg)
	
	var intent_hbox = HBoxContainer.new()
	intent_hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	intent_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	intent_hbox.add_theme_constant_override("separation", 6)
	intent_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	intent_bg.add_child(intent_hbox)
	
	var intent_icon = TextureRect.new()
	intent_icon.name = "IntentIcon"
	intent_icon.custom_minimum_size = Vector2(18, 18)
	intent_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	intent_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	intent_icon.texture = intent_attack_texture
	intent_hbox.add_child(intent_icon)
	
	var intent_lbl = Label.new()
	intent_lbl.name = "IntentLabel"
	intent_lbl.text = str(data["intent_val"])
	intent_lbl.add_theme_font_override("font", CINZEL_BOLD)
	intent_lbl.add_theme_color_override("font_color", Color(1.0, 0.7, 0.4))
	intent_lbl.add_theme_font_size_override("font_size", 14)
	intent_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	intent_hbox.add_child(intent_lbl)

	# Ground Ambient Contact Shadow
	var shadow = TextureRect.new()
	shadow.name = "GroundShadow"
	shadow.texture = preload("res://battlefield/assets/ground_shadow.svg")
	shadow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shadow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	shadow.size = Vector2(170, 36)
	shadow.position = Vector2(20, 218 + y_off * 0.5)
	shadow.pivot_offset = Vector2(85, 18)
	shadow.scale = Vector2(sh_scale, sh_scale)
	shadow.modulate = Color(1.0, 1.0, 1.0, 0.40)
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(shadow)

	# Dynamic Character Silhouette Shadow (Projects character's exact silhouette onto ground)
	var sil_shadow = TextureRect.new()
	sil_shadow.name = "CharacterShadow"
	sil_shadow.texture = data["texture"]
	sil_shadow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sil_shadow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sil_shadow.size = Vector2(182, 202)
	sil_shadow.position = Vector2(14, 36 + y_off + prof.get("shadow_y", 0.0))
	sil_shadow.pivot_offset = Vector2(91, 195)
	sil_shadow.scale = Vector2(-sh_scale * 1.05, sh_scale * 0.28)
	sil_shadow.material = _get_shadow_material(true)
	sil_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(sil_shadow)

	# 2. Enemy Sprite TextureRect (Pivot at feet 91, 195)
	var spr = TextureRect.new()
	spr.name = "EnemySprite"
	spr.texture = data["texture"]
	spr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	spr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	spr.size = Vector2(182, 202)
	spr.position = Vector2(14, 36 + y_off)
	spr.pivot_offset = Vector2(91, 195)
	spr.scale = Vector2(-scale_val, scale_val)
	spr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(spr)
	
	# Enemy Name
	var name_lbl = Label.new()
	name_lbl.text = data["name"]
	name_lbl.size = Vector2(210, 18)
	name_lbl.position = Vector2(0, 240)
	name_lbl.add_theme_font_override("font", CINZEL_SEMIBOLD)
	name_lbl.add_theme_color_override("font_color", Color(0.95, 0.88, 0.88))
	name_lbl.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	name_lbl.add_theme_constant_override("shadow_offset_y", 1)
	name_lbl.add_theme_font_size_override("font_size", 13)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(name_lbl)
	
	# Enemy HP Bar
	var hp_bar = ProgressBar.new()
	hp_bar.name = "HPBar"
	hp_bar.max_value = data["max_hp"]
	hp_bar.value = data["hp"]
	hp_bar.show_percentage = false
	hp_bar.size = Vector2(170, 12)
	hp_bar.position = Vector2(20, 260)
	hp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var style_bg = StyleBoxFlat.new()
	style_bg.bg_color = Color(0.12, 0.1, 0.14, 0.9)
	style_bg.set_corner_radius_all(3)
	var style_fill = StyleBoxFlat.new()
	style_fill.bg_color = Color(0.85, 0.28, 0.28)
	style_fill.set_corner_radius_all(3)
	hp_bar.add_theme_stylebox_override("background", style_bg)
	hp_bar.add_theme_stylebox_override("fill", style_fill)
	content.add_child(hp_bar)
	
	# Enemy HP Label (High-Contrast with Shadow)
	var hp_lbl = Label.new()
	hp_lbl.name = "HPLabel"
	hp_lbl.size = Vector2(210, 16)
	hp_lbl.position = Vector2(0, 274)
	hp_lbl.text = "HP: %d/%d" % [data["hp"], data["max_hp"]]
	hp_lbl.add_theme_font_override("font", CINZEL_BOLD)
	hp_lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.95))
	hp_lbl.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.95))
	hp_lbl.add_theme_constant_override("shadow_offset_x", 1)
	hp_lbl.add_theme_constant_override("shadow_offset_y", 1)
	hp_lbl.add_theme_font_size_override("font_size", 12)
	hp_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(hp_lbl)
	
	# 3. Below Enemy: Afflictions / Status Effects Tray
	var aff_tray = HBoxContainer.new()
	aff_tray.name = "AfflictionsTray"
	aff_tray.size = Vector2(210, 20)
	aff_tray.position = Vector2(0, 292)
	aff_tray.alignment = BoxContainer.ALIGNMENT_CENTER
	aff_tray.add_theme_constant_override("separation", 6)
	aff_tray.mouse_filter = Control.MOUSE_FILTER_PASS
	aff_tray.gui_input.connect(func(event):
		var is_click = (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventScreenTouch and event.pressed)
		if is_click:
			_on_enemy_info_pressed(index)
			get_viewport().set_input_as_handled()
	)
	content.add_child(aff_tray)
	
	if slot != null:
		slot.add_child(container)
	else:
		add_child(container)
	enemy_ui_nodes.append(container)

func _on_enemy_input(event: InputEvent, index: int) -> void:
	var is_click = (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventScreenTouch and event.pressed)
	if is_click:
		_select_target_enemy(index)
		get_viewport().set_input_as_handled()

func _on_enemy_info_pressed(index: int) -> void:
	_select_target_enemy(index)
	_show_enemy_inspect_callout(index)

func _select_target_enemy(index: int) -> void:
	if index < 0 or index >= enemies.size() or enemies[index]["hp"] <= 0:
		return
	selected_target_index = index
	_update_target_selection_ui()

func _auto_select_next_living_target() -> void:
	if selected_target_index >= 0 and selected_target_index < enemies.size() and enemies[selected_target_index]["hp"] > 0:
		_update_target_selection_ui()
		return
	for i in range(enemies.size()):
		if enemies[i]["hp"] > 0:
			selected_target_index = i
			_update_target_selection_ui()
			return

func _update_target_selection_ui() -> void:
	for i in range(enemy_ui_nodes.size()):
		var node = enemy_ui_nodes[i]
		var reticle_icon = node.find_child("ReticleIcon", true, false)
		var is_selected = (i == selected_target_index and enemies[i]["hp"] > 0)
		
		if reticle_icon != null:
			reticle_icon.visible = is_selected
			if is_selected:
				reticle_icon.scale = Vector2(1.25, 1.25)
				var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				tw.tween_property(reticle_icon, "scale", Vector2.ONE, 0.2)

func _update_stats_ui() -> void:
	if energy_badge != null:
		energy_badge.text = "⚡ Energy: %d / %d" % [player_energy, max_energy]
	if deck_piles_label != null:
		deck_piles_label.text = "🎴 Draw: %d  |  🪦 Discard: %d" % [draw_pile.size(), discard_pile.size()]
	
	# Update Soul Crucible Orb
	if energy_num_label != null:
		energy_num_label.text = "%d/%d" % [player_energy, max_energy]
		if player_energy <= 0:
			if orb_texture != null:
				orb_texture.modulate = Color(0.45, 0.45, 0.5, 0.65)
			energy_num_label.add_theme_color_override("font_color", Color(0.65, 0.65, 0.7))
		else:
			if orb_texture != null:
				orb_texture.modulate = Color(1.0, 1.0, 1.0, 1.0)
			energy_num_label.add_theme_color_override("font_color", Color(0.94, 0.99, 1.0))
			
	# Update Card Playability in Hand
	for card in hand_cards:
		if is_instance_valid(card) and card.card_data != null:
			card.set_playable(_is_card_playable(card.card_data))
	
	hero_hp_bar.max_value = player_max_hp
	hero_hp_bar.value = player_hp
	hero_status_label.text = "HP: %d/%d | 🛡 Block: %d" % [player_hp, player_max_hp, player_block]
	
	_update_summon_slots_ui()
	_update_hand_card_modes()
		
	for i in range(enemies.size()):
		if i < enemy_ui_nodes.size():
			var node = enemy_ui_nodes[i]
			var hp_bar = node.find_child("HPBar", true, false) as ProgressBar
			var hp_lbl = node.find_child("HPLabel", true, false) as Label
			var current_hp = enemies[i]["hp"]
			if hp_bar != null:
				hp_bar.value = maxi(0, current_hp)
			if hp_lbl != null:
				if current_hp <= 0:
					hp_lbl.text = "DEFEATED"
					if not _dead_enemy_notified.get(i, false):
						_dead_enemy_notified[i] = true
						var enemy_center = node.global_position + Vector2(85, 110)
						var dest = soul_crucible.global_position if soul_crucible != null else hero_sprite.global_position
						SoulHarvest.create(vfx_layer, enemy_center, dest, 4)
						var fade_tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
						fade_tw.tween_property(node, "modulate", Color(0.35, 0.35, 0.4, 0.45), 0.35)
					else:
						node.modulate = Color(0.35, 0.35, 0.4, 0.45)
				else:
					var blk = enemies[i].get("block", 0)
					if blk > 0:
						hp_lbl.text = "HP: %d/%d (🛡%d)" % [current_hp, enemies[i]["max_hp"], blk]
					else:
						hp_lbl.text = "HP: %d/%d" % [current_hp, enemies[i]["max_hp"]]
					
			# Update Dynamic Intent Badge
			var intent_lbl = node.find_child("IntentLabel", true, false) as Label
			var intent_icon = node.find_child("IntentIcon", true, false) as TextureRect
			var intent_badge = node.find_child("IntentBadge", true, false) as Panel
			if intent_lbl != null and intent_badge != null:
				if current_hp <= 0:
					intent_badge.visible = false
				else:
					intent_badge.visible = true
					var intent_info = _get_enemy_intent_info(enemies[i], i)
					intent_lbl.text = intent_info.get("badge_text", str(intent_info["damage"]))
					if intent_icon != null and intent_info.has("icon_texture") and intent_info["icon_texture"] != null:
						intent_icon.texture = intent_info["icon_texture"]
					intent_badge.tooltip_text = ""

			# Update Afflictions Tray
			var aff_tray = node.find_child("AfflictionsTray", true, false) as HBoxContainer
			if aff_tray != null:
				_render_afflictions(aff_tray, enemies[i]["afflictions"])
				
	_update_target_selection_ui()

func _is_card_playable(card_data: CardData) -> bool:
	if card_data == null:
		return false
	if card_data.cost > player_energy:
		return false
	if card_data.id == "charnel_sacrifice" or card_data.target_type == CardData.TargetType.MINION:
		if active_summons.is_empty():
			return false
	return true

func _render_afflictions(tray: HBoxContainer, affs: Dictionary) -> void:
	for c in tray.get_children():
		c.queue_free()
		
	var vuln = affs.get("vulnerable", 0)
	if vuln > 0:
		_add_affliction_badge(tray, "🩸 %d" % vuln, Color(1.0, 0.45, 0.45), "Vulnerable: Takes +50% Damage from attacks")
		
	var weak = affs.get("weak", 0)
	if weak > 0:
		_add_affliction_badge(tray, "💥 %d" % weak, Color(1.0, 0.8, 0.4), "Weak: Deals 25% less attack damage")
		
	var bleed = affs.get("bleed", 0)
	if bleed > 0:
		_add_affliction_badge(tray, "☠ %d" % bleed, Color(0.85, 0.4, 0.95), "Bleed: Takes %d damage at end of turn" % bleed)

func _add_affliction_badge(tray: HBoxContainer, text: String, color: Color, _tooltip: String) -> void:
	var badge = Label.new()
	badge.text = text
	badge.tooltip_text = ""
	badge.mouse_filter = Control.MOUSE_FILTER_PASS
	badge.add_theme_font_override("font", CINZEL_SEMIBOLD)
	badge.add_theme_font_size_override("font_size", 12)
	badge.add_theme_color_override("font_color", color)
	tray.add_child(badge)

# ----------------- Card Execution & Enemy Effects -----------------
func _on_card_clicked(card_data: CardData, card_node: CardUI) -> void:
	if event_overlay.visible or tutorial_overlay.visible:
		return
	if not is_instance_valid(card_node) or card_data == null:
		return
	if not _is_card_playable(card_data):
		_shake_node(card_node)
		return

	# Single-enemy targeting / Attack cards
	if card_data.target_type == CardData.TargetType.ENEMY_SINGLE or card_data.card_type == CardData.CardType.ATTACK:
		if selected_target_index >= 0 and selected_target_index < enemies.size() and enemies[selected_target_index]["hp"] > 0:
			_on_card_played(card_data, card_node)
			return
			
		var target_idx = _get_first_alive_enemy_index()
		if target_idx != -1:
			_select_target_enemy(target_idx)
			_on_card_played(card_data, card_node)
			return
		else:
			_shake_node(card_node)
			combat_log_label.text = "⚠️ No living enemies to target!"
			return

	# Summon cards: if duplicate/unsummon mode, trigger burst of that active summon!
	if card_data.card_type == CardData.CardType.SUMMON:
		var active_idx = _find_active_summon_index_for_card(card_data)
		if active_idx != -1:
			_on_unsummon_played(card_node, active_idx)
			return
		elif active_summons.size() >= MAX_SUMMON_SLOTS and active_summons.size() > 0:
			_on_unsummon_played(card_node, 0)
			return

	# Self-buffs, Block skills, AOE spells, and new Summons execute immediately
	_on_card_played(card_data, card_node)

func _on_unsummon_played(card_node: CardUI, target_summon_idx: int) -> void:
	if event_overlay.visible or tutorial_overlay.visible:
		return
	if not is_instance_valid(card_node):
		return
	var card_data = card_node.card_data
	if not _is_card_playable(card_data):
		_shake_node(card_node)
		_resort_hand(true)
		return
		
	player_energy -= card_data.cost
	_pulse_crucible()
	discard_pile.append(card_data)
	hand_cards.erase(card_node)
	
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(card_node, "position:y", card_node.position.y - 120.0, 0.2)
	tw.tween_property(card_node, "modulate:a", 0.0, 0.2)
	tw.tween_property(card_node, "scale", Vector2(1.2, 1.2), 0.2)
	tw.chain().tween_callback(card_node.queue_free)
	
	_trigger_summon_burst(target_summon_idx, card_data)
	_resort_hand(true)
	_update_stats_ui()
	_update_hand_card_modes()
	_check_combat_resolution()

func _on_card_played(card_data: CardData, card_node: CardUI) -> void:
	if event_overlay.visible or tutorial_overlay.visible:
		return
	_hide_enemy_inspect_callout()
		
	if not _is_card_playable(card_data):
		if card_data.cost > player_energy:
			combat_log_label.text = "⚠ Insufficient Soul Energy! (Requires %d, have %d)" % [card_data.cost, player_energy]
		elif (card_data.id == "charnel_sacrifice" or card_data.target_type == CardData.TargetType.MINION) and active_summons.is_empty():
			combat_log_label.text = "⚠️ Charnel Sacrifice requires an active summon to sacrifice!"
		_shake_node(card_node)
		_resort_hand(true)
		return
		
	player_energy -= card_data.cost
	_pulse_crucible()
	discard_pile.append(card_data)
	hand_cards.erase(card_node)
	
	# Animate card dissolution/play
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(card_node, "position:y", card_node.position.y - 120.0, 0.2)
	tw.tween_property(card_node, "modulate:a", 0.0, 0.2)
	tw.tween_property(card_node, "scale", Vector2(1.2, 1.2), 0.2)
	tw.chain().tween_callback(card_node.queue_free)
	
	# Execute effect on targeted enemy
	match card_data.card_type:
		CardData.CardType.SUMMON:
			var existing_idx: int = -1
			for i in range(active_summons.size()):
				var check_id = card_data.summon_id if not card_data.summon_id.is_empty() else card_data.id
				if active_summons[i].get("id") == check_id or active_summons[i].get("card_id") == card_data.id:
					existing_idx = i
					break
			
			if existing_idx != -1:
				_trigger_summon_burst(existing_idx, card_data)
			else:
				if active_summons.size() >= MAX_SUMMON_SLOTS:
					combat_log_label.text = "⚠️ All 3 Summon Slots Full! Detonate or sacrifice an ally first."
					_spawn_floating_text("SLOTS FULL (3/3)", hero_sprite.global_position, Color(1, 0.4, 0.4))
				else:
					_summon_companion(card_data)
			
		CardData.CardType.ATTACK:
			# Verify valid target; fallback to next alive enemy if needed
			var target_idx = selected_target_index
			if target_idx < 0 or target_idx >= enemies.size() or enemies[target_idx]["hp"] <= 0:
				target_idx = _get_first_alive_enemy_index()
				selected_target_index = target_idx
				
			if target_idx >= 0:
				var dmg = card_data.damage if card_data.damage > 0 else 7
				# Apply Vulnerable bonus (+50% dmg)
				if enemies[target_idx]["afflictions"]["vulnerable"] > 0:
					dmg = int(dmg * 1.5)
					
				if card_data.apply_vulnerable > 0:
					enemies[target_idx]["afflictions"]["vulnerable"] += card_data.apply_vulnerable
				if card_data.apply_weak > 0:
					enemies[target_idx]["afflictions"]["weak"] += card_data.apply_weak
				if card_data.apply_bleed > 0:
					enemies[target_idx]["afflictions"]["bleed"] += card_data.apply_bleed

				var unblocked = _damage_enemy(target_idx, dmg)
				combat_log_label.text = "⚔ Cast %s! Dealt %d damage to %s." % [card_data.title, unblocked, enemies[target_idx]["name"]]
				_play_enemy_impact_vfx(target_idx, unblocked)
				
				# If enemy died, handle fatal tempo triggers and auto-retarget
				if enemies[target_idx]["hp"] <= 0:
					if card_data.fatal_energy_refund > 0:
						player_energy = mini(player_energy + card_data.fatal_energy_refund, max_energy + 2)
						_spawn_floating_text("⚡ TEMPO +%d ENERGY" % card_data.fatal_energy_refund, hero_sprite.global_position + Vector2(0, -35), Color(0.4, 0.9, 1.0))
						combat_log_label.text += " (Fatal: +%d Energy!)" % card_data.fatal_energy_refund
					if card_data.fatal_draw > 0:
						_draw_cards(card_data.fatal_draw)
						_spawn_floating_text("TEMPO DRAW +%d" % card_data.fatal_draw, hero_sprite.global_position + Vector2(0, -55), Color(0.9, 0.8, 0.3))
					_auto_select_next_living_target()
			else:
				combat_log_label.text = "Cast %s, but no enemies remain!" % card_data.title
				
		CardData.CardType.SPELL:
			if card_data.id == "charnel_sacrifice":
				if active_summons.size() > 0:
					var sacrificed = active_summons[0]
					_trigger_summon_burst(0, sacrificed["card_data"])
					player_energy = mini(player_energy + 2, max_energy + 2)
					_draw_cards(2)
					combat_log_label.text = "🩸 Charnel Sacrifice! Consumed %s to burst, gained +2 Energy & drew 2 cards!" % sacrificed["name"]
					_spawn_floating_text("+2 ENERGY & DRAW 2", hero_sprite.global_position + Vector2(0, -30), Color(0.8, 0.6, 1.0))
				else:
					combat_log_label.text = "Charnel Sacrifice: No active summons to sacrifice!"
					_spawn_floating_text("NO SUMMONS", hero_sprite.global_position, Color(0.8, 0.5, 0.5))
			
			var target_idx = selected_target_index
			if target_idx < 0 or target_idx >= enemies.size() or enemies[target_idx]["hp"] <= 0:
				target_idx = _get_first_alive_enemy_index()
				selected_target_index = target_idx
				
			if card_data.heal > 0:
				var healed = mini(card_data.heal, player_max_hp - player_hp)
				player_hp += healed
			if card_data.block > 0:
				player_block += card_data.block
				_play_hero_block_vfx(card_data.block)
				
			if card_data.damage > 0 and target_idx >= 0:
				var dmg = card_data.damage
				if enemies[target_idx]["afflictions"]["vulnerable"] > 0:
					dmg = int(dmg * 1.5)
				if card_data.apply_vulnerable > 0:
					enemies[target_idx]["afflictions"]["vulnerable"] += card_data.apply_vulnerable
				if card_data.apply_weak > 0:
					enemies[target_idx]["afflictions"]["weak"] += card_data.apply_weak
				if card_data.apply_bleed > 0:
					enemies[target_idx]["afflictions"]["bleed"] += card_data.apply_bleed
				var unblocked = _damage_enemy(target_idx, dmg)
				_play_enemy_impact_vfx(target_idx, unblocked)
				combat_log_label.text = "🔮 Chanted %s! Dealt %d damage to %s." % [card_data.title, unblocked, enemies[target_idx]["name"]]
				if enemies[target_idx]["hp"] <= 0:
					if card_data.fatal_energy_refund > 0:
						player_energy = mini(player_energy + card_data.fatal_energy_refund, max_energy + 2)
						_spawn_floating_text("⚡ TEMPO +%d ENERGY" % card_data.fatal_energy_refund, hero_sprite.global_position + Vector2(0, -35), Color(0.4, 0.9, 1.0))
					if card_data.fatal_draw > 0:
						_draw_cards(card_data.fatal_draw)
					_auto_select_next_living_target()
			elif card_data.apply_bleed > 0 or card_data.apply_weak > 0:
				for e in enemies:
					if e["hp"] > 0:
						e["afflictions"]["bleed"] += card_data.apply_bleed
						e["afflictions"]["weak"] += card_data.apply_weak
				combat_log_label.text = "🔮 Chanted %s! Afflicted all enemies." % card_data.title
			else:
				combat_log_label.text = "🔮 Chanted %s." % card_data.title

		CardData.CardType.SKILL, CardData.CardType.POWER:
			var block_gain = card_data.block if card_data.block > 0 else 6
			player_block += block_gain
			combat_log_label.text = "🛡 Cast %s! Gained %d Block." % [card_data.title, block_gain]
			_play_hero_block_vfx(block_gain)
			
		_:
			combat_log_label.text = "Played %s." % card_data.title
			
	# Point 3: Instantly resort remaining hand cards in fan
	_resort_hand(true)
	_update_stats_ui()
	_check_combat_resolution()

# ----------------- Visual Effects & Impacts -----------------
func _play_enemy_impact_vfx(enemy_idx: int, damage: int) -> void:
	if enemy_idx < 0 or enemy_idx >= enemy_ui_nodes.size():
		return
	var enemy_node = enemy_ui_nodes[enemy_idx]
	var spr = enemy_node.find_child("EnemySprite", true, false) as TextureRect
	var global_center = enemy_node.global_position + Vector2(85, 110)
	
	# 1. Spawn Layered Damage Impact VFX
	var impact_type = DamageImpact.ImpactType.SLASH
	if damage >= 20:
		impact_type = DamageImpact.ImpactType.HEAVY_SLASH
	elif damage >= 12:
		impact_type = DamageImpact.ImpactType.SLASH
	DamageImpact.create_at(vfx_layer, global_center, impact_type, damage)
	
	# 2. Shake & Flash enemy sprite
	if spr != null:
		var orig_x = spr.position.x
		var shake_tw = create_tween()
		spr.modulate = Color(2.5, 0.4, 0.4)
		shake_tw.tween_property(spr, "position:x", orig_x + 14.0, 0.04)
		shake_tw.tween_property(spr, "position:x", orig_x - 12.0, 0.04)
		shake_tw.tween_property(spr, "position:x", orig_x + 6.0, 0.04)
		shake_tw.tween_property(spr, "position:x", orig_x, 0.04)
		shake_tw.parallel().tween_property(spr, "modulate", Color(1, 1, 1), 0.2)
		
	# 3. Floating Damage Number
	_spawn_floating_text("-%d" % damage, global_center, Color(1.0, 0.3, 0.3))

func _get_slot_containers() -> Array[Control]:
	if is_instance_valid(battle_formation):
		return battle_formation.get_summon_slots()
	return [vanguard_container, slot1_container, slot2_container]

func _find_summon_under_point(global_pos: Vector2) -> int:
	var containers = _get_slot_containers()
	for s_idx in range(active_summons.size()):
		var slot_idx: int = active_summons[s_idx].get("slot_index", -1)
		if slot_idx >= 0 and slot_idx < containers.size():
			var c = containers[slot_idx]
			if is_instance_valid(c):
				var rect = c.get_global_rect().grow(35.0)
				if rect.has_point(global_pos):
					return s_idx
	return -1

func _find_active_summon_index_for_card(card_data: CardData) -> int:
	if card_data == null:
		return -1
	var check_id = card_data.summon_id if not card_data.summon_id.is_empty() else card_data.id
	check_id = check_id.to_lower()
	for i in range(active_summons.size()):
		var s = active_summons[i]
		var sid: String = s.get("id", "").to_lower()
		var scid: String = s.get("card_id", "").to_lower()
		if sid == check_id or scid == card_data.id.to_lower():
			return i
		if not sid.is_empty() and (check_id.contains(sid) or sid.contains(check_id)):
			return i
		if (card_data.id.to_lower().contains("vargas") and sid.contains("vargas")) \
		   or (card_data.id.to_lower().contains("kaelen") and sid.contains("kaelen")) \
		   or (card_data.id.to_lower().contains("lyra") and sid.contains("lyra")) \
		   or (card_data.id.to_lower().contains("boros") and sid.contains("boros")) \
		   or (card_data.id.to_lower().contains("malakor") and sid.contains("malakor")):
			return i
	return -1

func _is_point_over_allies(global_pos: Vector2) -> bool:
	var hero_center = _get_hero_center()
	if global_pos.distance_to(hero_center) < 140.0:
		return true
	if is_instance_valid(battle_formation) and battle_formation.hero_slot != null:
		if battle_formation.hero_slot.get_global_rect().grow(30.0).has_point(global_pos):
			return true
	elif is_instance_valid(hero_sprite):
		var hero_rect = hero_sprite.get_global_rect().grow(30.0)
		if hero_rect.has_point(global_pos):
			return true
	return _find_summon_under_point(global_pos) != -1 or _find_closest_summon_magnet(global_pos, 140.0) != -1

func _update_hand_card_modes() -> void:
	for card in hand_cards:
		if not is_instance_valid(card) or card.card_data == null:
			continue
		if card.card_data.card_type == CardData.CardType.SUMMON:
			var active_idx = _find_active_summon_index_for_card(card.card_data)
			if active_idx != -1:
				var summon = active_summons[active_idx]
				var sname: String = summon.get("name", "Ally")
				var b_dmg = card.card_data.burst_damage if card.card_data.burst_damage > 0 else (16 if summon.get("id", "").contains("kaelen") else (22 if summon.get("id", "").contains("boros") else (10 if summon.get("id", "").contains("vargas") else 0)))
				var b_hl = card.card_data.burst_heal if card.card_data.burst_heal > 0 else (12 if summon.get("id", "").contains("lyra") else 0)
				var b_blk = card.card_data.burst_block if card.card_data.burst_block > 0 else (15 if summon.get("id", "").contains("lyra") else (18 if summon.get("id", "").contains("vargas") else 0))
				var parts: Array[String] = []
				if b_dmg > 0: parts.append("%d AOE Dmg" % b_dmg)
				if b_blk > 0: parts.append("%d Block" % b_blk)
				if b_hl > 0: parts.append("%d Heal" % b_hl)
				card.set_unsummon_mode(true, sname, ", ".join(parts))
			else:
				card.set_unsummon_mode(false)

func _get_slot_sprites() -> Array[TextureRect]:
	return [vanguard_sprite, slot1_sprite, slot2_sprite]

func _get_slot_hp_bars() -> Array[ProgressBar]:
	return [vanguard_hp_bar, slot1_hp_bar, slot2_hp_bar]

func _get_slot_names() -> Array[Label]:
	return [vanguard_name, slot1_name, slot2_name]

func _get_slot_status_labels() -> Array[Label]:
	return [vanguard_status_label, slot1_status_label, slot2_status_label]

func _update_summon_slots_ui() -> void:
	var sprites = _get_slot_sprites()
	var bars = _get_slot_hp_bars()
	var names = _get_slot_names()
	var labels = _get_slot_status_labels()
	var containers = _get_slot_containers()
	
	for i in range(MAX_SUMMON_SLOTS):
		if i >= sprites.size():
			continue
		var spr = sprites[i]
		var bar = bars[i]
		var lbl = names[i]
		var stat = labels[i]
		var cont = containers[i] if i < containers.size() else null
		
		var found_summon: Dictionary = {}
		for s in active_summons:
			if s.get("slot_index", -1) == i:
				found_summon = s
				break
				
		if not found_summon.is_empty():
			if cont != null:
				cont.visible = true
			var s_id: String = found_summon.get("id", "").to_lower()
			var prof = _get_character_visual_profile(s_id)
			var s_scale: float = prof["scale"]
			var y_off: float = prof["y_offset"]
			
			if spr != null:
				if s_id.contains("vargas"):
					spr.texture = companion_textures["vargas"]
				elif s_id.contains("kaelen"):
					spr.texture = companion_textures["kaelen"]
				elif s_id.contains("lyra"):
					spr.texture = companion_textures["lyra"]
				elif s_id.contains("boros"):
					spr.texture = companion_textures["boros"]
				elif s_id.contains("malakor"):
					spr.texture = companion_textures["malakor"]
				else:
					spr.texture = companion_textures["default"]
				spr.modulate = Color(1.1, 1.2, 1.3, 1.0)
				spr.pivot_offset = Vector2(spr.size.x * 0.5, spr.size.y * 0.95)
				spr.scale = Vector2(s_scale, s_scale)
				if i < _slot_sprites_base_y.size():
					spr.position.y = _slot_sprites_base_y[i] + y_off
				
			if i < _slot_silhouette_shadows.size():
				var sil = _slot_silhouette_shadows[i]
				if sil != null and spr != null:
					sil.texture = spr.texture
					sil.visible = true
					sil.pivot_offset = Vector2(spr.size.x * 0.5, spr.size.y * 0.95)
					var sh_scale = s_scale * prof.get("shadow_scale", 1.0)
					sil.scale = Vector2(sh_scale * 1.05, sh_scale * 0.28)
					sil.position.y = spr.position.y + prof.get("shadow_y", 0.0)

			if lbl != null:
				lbl.text = found_summon.get("name", "Companion")
			
			if found_summon.get("has_taunt", false):
				if bar != null:
					bar.visible = true
					bar.max_value = found_summon.get("max_hp", 12)
					bar.value = found_summon.get("hp", 0)
				if stat != null:
					stat.text = "%s: %d/%d HP (Taunt)" % [found_summon.get("name"), found_summon.get("hp"), found_summon.get("max_hp")]
					stat.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0))
			else:
				if bar != null:
					bar.visible = false
				if stat != null:
					if s_id.contains("kaelen"):
						stat.text = "🏹 4 Dmg/Turn"
						stat.add_theme_color_override("font_color", Color(0.3, 0.9, 0.9))
					elif s_id.contains("lyra"):
						stat.text = "✨ +2 Blk, +1 HP"
						stat.add_theme_color_override("font_color", Color(0.9, 0.8, 0.3))
					elif s_id.contains("malakor"):
						stat.text = "🔥 3 Sun-Flame/Turn"
						stat.add_theme_color_override("font_color", Color(1.0, 0.6, 0.2))
					else:
						stat.text = "Active Spirit"
						stat.add_theme_color_override("font_color", Color(0.7, 0.8, 1.0))
		else:
			# Hide empty slot during gameplay - only visible when summoned!
			if cont != null:
				cont.visible = false
			if i < _slot_silhouette_shadows.size():
				var sil = _slot_silhouette_shadows[i]
				if sil != null:
					sil.visible = false
			if spr != null:
				spr.texture = companion_textures["default"]
				spr.modulate = Color(1.0, 1.0, 1.0, 0.25)
				spr.scale = Vector2(1.0, 1.0)
				if i < _slot_sprites_base_y.size():
					spr.position.y = _slot_sprites_base_y[i]
			if lbl != null:
				lbl.text = "Slot %d" % (i + 1)
			if bar != null:
				bar.visible = false
			if stat != null:
				stat.text = "[ Empty Slot ]"
				stat.add_theme_color_override("font_color", Color(0.55, 0.52, 0.65))

func _play_summon_vfx(slot_idx: int, sname: String) -> void:
	var sprites = _get_slot_sprites()
	if slot_idx < sprites.size():
		var spr = sprites[slot_idx]
		var prof = _get_character_visual_profile(sname)
		var target_scale = prof.get("scale", 1.0)
		var seal_pos = spr.global_position + Vector2(spr.size.x * 0.5 if spr.size.x > 0 else 50.0, spr.size.y * 0.7 if spr.size.y > 0 else 80.0)
		SummonBurst.create_at(vfx_layer, seal_pos)
		spr.pivot_offset = Vector2(spr.size.x * 0.5, spr.size.y * 0.95)
		spr.scale = Vector2(target_scale * 1.25, target_scale * 1.25)
		var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(spr, "scale", Vector2(target_scale, target_scale), 0.3)
		tw.tween_property(spr, "modulate", Color(1.2, 1.4, 1.6, 1.0), 0.2)
		_spawn_floating_text("+SUMMON %s" % sname.to_upper(), spr.global_position + Vector2(10, 30), Color(0.4, 0.85, 1.0))

func _play_vanguard_summon_vfx() -> void:
	_play_summon_vfx(0, "Vargas")

func _summon_companion(card_data: CardData) -> void:
	var used_slots: Array[int] = []
	for s in active_summons:
		used_slots.append(s.get("slot_index", 0))
	
	var free_slot = 0
	for i in range(MAX_SUMMON_SLOTS):
		if not used_slots.has(i):
			free_slot = i
			break
			
	var sid = card_data.summon_id if not card_data.summon_id.is_empty() else card_data.id
	var c_name = "Vargas" if sid.contains("vargas") else ("Kaelen" if sid.contains("kaelen") else ("Lyra" if sid.contains("lyra") else ("Boros" if sid.contains("boros") else ("Malakor" if sid.contains("malakor") else card_data.title))))
	var c_hp = card_data.summon_hp if card_data.summon_hp > 0 else (12 if sid.contains("vargas") else (16 if sid.contains("boros") else (14 if sid.contains("malakor") else 0)))
	var is_taunt = c_hp > 0 and (sid.contains("vargas") or sid.contains("boros"))
	
	var summon_entry: Dictionary = {
		"id": sid,
		"card_id": card_data.id,
		"name": c_name,
		"card_data": card_data,
		"hp": c_hp,
		"max_hp": c_hp,
		"has_taunt": is_taunt,
		"slot_index": free_slot
	}
	
	active_summons.append(summon_entry)
	if sid.contains("vargas"):
		vanguard_active = true
		vanguard_hp = c_hp
		vanguard_max_hp = c_hp
		
	if card_data.block > 0:
		player_block += card_data.block
		_play_hero_block_vfx(card_data.block)
		
	_update_summon_slots_ui()
	_update_hand_card_modes()
	_play_summon_vfx(free_slot, c_name)
	combat_log_label.text = "🛡 Summoned %s in Slot %d!" % [c_name, free_slot + 1]

func _trigger_summon_burst(idx: int, card_data: CardData) -> void:
	if idx < 0 or idx >= active_summons.size():
		return
	var summon = active_summons[idx]
	var sname: String = summon.get("name", "Ally")
	var slot_idx: int = summon.get("slot_index", 0)
	var summon_card: CardData = summon.get("card_data", card_data)
	
	var burst_dmg = summon_card.burst_damage if (summon_card != null and summon_card.burst_damage > 0) else (16 if summon.get("id", "").contains("kaelen") else (22 if summon.get("id", "").contains("boros") else (10 if summon.get("id", "").contains("vargas") else 0)))
	var burst_hl = summon_card.burst_heal if (summon_card != null and summon_card.burst_heal > 0) else (12 if summon.get("id", "").contains("lyra") else 0)
	var burst_blk = summon_card.burst_block if (summon_card != null and summon_card.burst_block > 0) else (15 if summon.get("id", "").contains("lyra") else (18 if summon.get("id", "").contains("vargas") else 0))
	
	var sprites = _get_slot_sprites()
	if slot_idx < sprites.size():
		_shake_node(sprites[slot_idx])
		_spawn_floating_text("BURST DETONATION!", sprites[slot_idx].global_position + Vector2(10, 0), Color(1.0, 0.8, 0.2))
	
	if burst_dmg > 0:
		for i in range(enemies.size()):
			if enemies[i]["hp"] > 0:
				enemies[i]["hp"] -= burst_dmg
				_play_enemy_impact_vfx(i, burst_dmg)
				var e_pos = enemy_ui_nodes[i].global_position + Vector2(20, -10) if i < enemy_ui_nodes.size() else global_position
				_spawn_floating_text("BURST -%d" % burst_dmg, e_pos, Color(1.0, 0.4, 0.2))
		_auto_select_next_living_target()
		
	if burst_hl > 0:
		var healed = mini(burst_hl, player_max_hp - player_hp)
		player_hp += healed
		_spawn_floating_text("+%d HP" % healed, hero_sprite.global_position + Vector2(0, -30), Color(0.4, 1.0, 0.5))
		
	if burst_blk > 0:
		player_block += burst_blk
		_play_hero_block_vfx(burst_blk)
		
	combat_log_label.text = "💥 Burst Detonation! %s consumed: %d AOE Dmg, %d Heal, %d Block!" % [sname, burst_dmg, burst_hl, burst_blk]
	
	if summon.get("id", "") == "vargas_spirit":
		vanguard_active = false
	active_summons.remove_at(idx)
	_update_summon_slots_ui()
	_update_hand_card_modes()

func _trigger_companions_turn_actions() -> void:
	var sprites = _get_slot_sprites()
	for summon in active_summons:
		var sid: String = summon.get("id", "").to_lower()
		var sname: String = summon.get("name", "Companion")
		var slot_idx: int = summon.get("slot_index", 0)
		
		if sid.contains("kaelen"):
			var target_idx = selected_target_index
			if target_idx < 0 or target_idx >= enemies.size() or enemies[target_idx]["hp"] <= 0:
				target_idx = _get_first_alive_enemy_index()
			if target_idx >= 0:
				var dmg = 4
				if enemies[target_idx]["afflictions"]["vulnerable"] > 0:
					dmg = int(dmg * 1.5)
				var unblocked = _damage_enemy(target_idx, dmg)
				_play_enemy_impact_vfx(target_idx, unblocked)
				var e_pos = enemy_ui_nodes[target_idx].global_position + Vector2(20, -10) if target_idx < enemy_ui_nodes.size() else global_position
				_spawn_floating_text("SNIPE! -%d" % unblocked, e_pos, Color(0.3, 0.8, 1.0))
				combat_log_label.text = "🏹 Kaelen snipes %s for %d damage!" % [enemies[target_idx]["name"], unblocked]
				if enemies[target_idx]["hp"] <= 0:
					_auto_select_next_living_target()
		elif sid.contains("lyra"):
			player_block += 2
			var healed = mini(1, player_max_hp - player_hp)
			player_hp += healed
			_play_hero_block_vfx(2)
			if healed > 0:
				HealBuff.create_at(vfx_layer, hero_sprite.global_position + Vector2(65, 75))
			_spawn_floating_text("+2 BLK & +%d HP" % healed, hero_sprite.global_position + Vector2(0, -30), Color(0.4, 1.0, 0.6))
			combat_log_label.text = "✨ Lyra's benediction grants +2 Block and restores %d HP!" % healed
		elif sid.contains("boros"):
			var hit_any = false
			for i in range(enemies.size()):
				if enemies[i]["hp"] > 0:
					var unblocked = _damage_enemy(i, 4)
					_play_enemy_impact_vfx(i, unblocked)
					hit_any = true
			if hit_any:
				combat_log_label.text = "⚔ Boros cleaves all enemies for 4 damage!"
				if slot_idx < sprites.size():
					_shake_node(sprites[slot_idx])
		elif sid.contains("malakor"):
			var branded = false
			for i in range(enemies.size()):
				if enemies[i]["hp"] > 0:
					enemies[i]["afflictions"]["bleed"] = enemies[i]["afflictions"].get("bleed", 0) + 3
					if i < enemy_ui_nodes.size():
						_spawn_floating_text("SUN-FLAME +3", enemy_ui_nodes[i].global_position + Vector2(20, -10), Color(1.0, 0.55, 0.15))
						_shake_node(enemy_ui_nodes[i])
					branded = true
			if branded:
				combat_log_label.text = "🔥 Inquisitor Malakor brands all enemies with 3 Sun-Flame!"
				if slot_idx < sprites.size():
					_shake_node(sprites[slot_idx])

func _play_hero_block_vfx(block_gain: int) -> void:
	hero_sprite.modulate = Color(1.3, 1.3, 1.8)
	var tw = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(hero_sprite, "modulate", Color.WHITE, 0.25)
	ShieldWard.create_at(vfx_layer, hero_sprite.global_position + Vector2(65, 75))
	_spawn_floating_text("+%d BLOCK" % block_gain, hero_sprite.global_position + Vector2(60, 40), Color(0.45, 0.75, 1.0))

func _spawn_floating_text(text: String, global_pos: Vector2, color: Color) -> void:
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_override("font", CINZEL_BOLD)
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_constant_override("outline_size", 4)
	lbl.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.08, 0.9))
	lbl.global_position = global_pos + Vector2(-30, -20)
	lbl.pivot_offset = Vector2(30, 15)
	lbl.scale = Vector2(1.35, 1.35)
	vfx_layer.add_child(lbl)
	
	var tw = create_tween().set_parallel(true)
	tw.tween_property(lbl, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(lbl, "position:y", lbl.position.y - 45.0, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.45).set_delay(0.12)
	tw.chain().tween_callback(lbl.queue_free)

func _shake_node(node: Control) -> void:
	var orig_x = node.position.x
	var tw = create_tween()
	tw.tween_property(node, "position:x", orig_x + 8.0, 0.04)
	tw.tween_property(node, "position:x", orig_x - 8.0, 0.04)
	tw.tween_property(node, "position:x", orig_x, 0.04)

func _get_first_alive_enemy_index() -> int:
	for i in range(enemies.size()):
		if enemies[i]["hp"] > 0:
			return i
	return -1

# ----------------- Round / Turn Flow -----------------
func _pulse_crucible() -> void:
	if soul_crucible != null:
		var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(soul_crucible, "scale", Vector2(1.18, 1.18), 0.09)
		tw.tween_property(soul_crucible, "scale", Vector2.ONE, 0.16)

func _start_player_turn() -> void:
	player_energy = max_energy
	player_block = 0
	_auto_select_next_living_target()
	_draw_cards(5 - hand_cards.size())
	combat_log_label.text = "Your Turn! Play cards from your hand."
	_update_stats_ui()
	_update_hand_card_modes()
	_pulse_crucible()
	if auto_battle_enabled:
		_trigger_auto_battle_step()

func _on_auto_battle_toggle() -> void:
	auto_battle_enabled = not auto_battle_enabled
	if auto_battle_button != null:
		if auto_battle_enabled:
			auto_battle_button.text = "🤖 Auto: ON"
			auto_battle_button.add_theme_color_override("font_color", Color(0.4, 1.0, 0.7))
			combat_log_label.text = "🤖 Auto-Battler engaged! Bot pilot active."
			_trigger_auto_battle_step()
		else:
			auto_battle_button.text = "🤖 Auto: OFF"
			auto_battle_button.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
			combat_log_label.text = "Manual control restored."

func _on_speed_toggle() -> void:
	if auto_battle_speed == 1.0:
		auto_battle_speed = 2.0
		if speed_button != null:
			speed_button.text = "⚡ 2x"
	elif auto_battle_speed == 2.0:
		auto_battle_speed = 4.0
		if speed_button != null:
			speed_button.text = "⚡ 4x"
	else:
		auto_battle_speed = 1.0
		if speed_button != null:
			speed_button.text = "⚡ 1x"

func _trigger_auto_battle_step() -> void:
	if not auto_battle_enabled or _auto_battle_loop_active:
		return
	if event_overlay.visible or tutorial_overlay.visible or victory_overlay.visible:
		return
	_auto_battle_loop_active = true
	_run_auto_battle_sequence()

func _run_auto_battle_sequence() -> void:
	while auto_battle_enabled and not is_queued_for_deletion():
		if event_overlay.visible or tutorial_overlay.visible or victory_overlay.visible:
			break
		if _get_first_alive_enemy_index() == -1 or player_hp <= 0:
			break

		var playable_card_ui: CardUI = null
		var lowest_cost = 99
		for card_ui in hand_cards:
			if is_instance_valid(card_ui) and card_ui.card_data != null and _is_card_playable(card_ui.card_data):
				if card_ui.card_data.card_type == CardData.CardType.SUMMON and active_summons.size() < MAX_SUMMON_SLOTS:
					playable_card_ui = card_ui
					break
				if playable_card_ui == null or card_ui.card_data.cost < lowest_cost:
					playable_card_ui = card_ui
					lowest_cost = card_ui.card_data.cost

		if playable_card_ui != null:
			var target_idx = -1
			var lowest_hp = 9999
			for i in range(enemies.size()):
				if enemies[i]["hp"] > 0 and enemies[i]["hp"] < lowest_hp:
					lowest_hp = enemies[i]["hp"]
					target_idx = i
			if target_idx != -1:
				_select_target_enemy(target_idx)

			var wait_time = maxf(0.08, 0.42 / auto_battle_speed)
			await get_tree().create_timer(wait_time).timeout
			if not auto_battle_enabled or not is_instance_valid(playable_card_ui):
				break

			_on_card_played(playable_card_ui.card_data, playable_card_ui)
			await get_tree().create_timer(maxf(0.06, 0.28 / auto_battle_speed)).timeout
		else:
			var wait_time = maxf(0.08, 0.35 / auto_battle_speed)
			await get_tree().create_timer(wait_time).timeout
			if auto_battle_enabled and not event_overlay.visible and not victory_overlay.visible:
				_on_end_turn_pressed()
			break

	_auto_battle_loop_active = false

func _on_end_turn_pressed() -> void:
	if event_overlay.visible or tutorial_overlay.visible:
		return
	_hide_enemy_inspect_callout()
		
	# 1. Trigger companion turn actions (Kaelen snipe, Lyra benediction, Boros cleave)
	_trigger_companions_turn_actions()
	_update_stats_ui()
	
	# Check if all enemies were defeated by companion actions
	var alive_foes = 0
	for enemy in enemies:
		if enemy["hp"] > 0:
			alive_foes += 1
	if alive_foes == 0:
		_on_victory()
		return
		
	# 2. Reset Enemy Block & Execute Planned Enemy Intents
	for e in enemies:
		e["block"] = 0
		e["thorns"] = 0
		
	combat_turn_count += 1
	var alive_count = 0
	for e_idx in range(enemies.size()):
		var enemy = enemies[e_idx]
		if enemy["hp"] <= 0:
			continue

		alive_count += 1
		var e_name: String = enemy["name"]
		var intent_info = _get_enemy_intent_info(enemy, e_idx)
		var incoming_dmg = intent_info.get("damage", enemy["damage"])
		var bypass_vanguard: bool = intent_info.get("bypass_vanguard", false)
		var cleave_damage: int = intent_info.get("cleave_damage", 0)
		var spr_node = enemy_ui_nodes[e_idx] if e_idx < enemy_ui_nodes.size() else null
		var spr_pos = spr_node.global_position + Vector2(60, 20) if spr_node != null else global_position

		# Execute Non-Attack Intent Actions
		var i_type = intent_info.get("type", "attack")
		match i_type:
			"charge":
				combat_log_label.text = "⏳ %s channels Solar Core (Cataclysm Charge)!" % e_name
				_spawn_floating_text("⏳ CHARGING!", spr_pos, Color(1.0, 0.7, 0.2))
				incoming_dmg = 0
			"defend":
				var blk = intent_info.get("block_gain", 8)
				enemy["block"] = blk
				combat_log_label.text = "🛡 %s adopts defensive guard (+%d Block)!" % [e_name, blk]
				_spawn_floating_text("+%d BLOCK" % blk, spr_pos, Color(0.4, 0.8, 1.0))
				incoming_dmg = 0
			"guard_squad":
				var blk = intent_info.get("block_gain", 5)
				for ally in enemies:
					if ally["hp"] > 0:
						ally["block"] = ally.get("block", 0) + blk
				combat_log_label.text = "🛡 %s fortifies squad (+%d Block to allies)!" % [e_name, blk]
				_spawn_floating_text("PHALANX +%d" % blk, spr_pos, Color(0.4, 0.8, 1.0))
				incoming_dmg = 0
			"riposte":
				enemy["block"] = 10
				enemy["thorns"] = 4
				combat_log_label.text = "⚔️🛡️ %s adopts Riposte Stance (+10 Block, 4 Reflect)!" % e_name
				_spawn_floating_text("RIPOSTE STANCE", spr_pos, Color(1.0, 0.8, 0.2))
				incoming_dmg = 0
			"rally":
				for ally in enemies:
					if ally != enemy and ally["hp"] > 0:
						ally["damage"] += 2
				combat_log_label.text = "🎺 %s sounds Rallying Warhorn (+2 Dmg to squad)!" % e_name
				_spawn_floating_text("RALLY! +2 DMG", spr_pos, Color(1.0, 0.4, 0.2))
				incoming_dmg = 0
			"howl":
				combat_log_label.text = "🐺 %s bellows a terrifying Howl!" % e_name
				if is_instance_valid(hero_sprite):
					_spawn_floating_text("TERRIFYING HOWL", hero_sprite.global_position, Color(0.8, 0.4, 0.8))
				incoming_dmg = 0
			"rest":
				combat_log_label.text = "🐾 %s prowls cautiously!" % e_name
				incoming_dmg = 0

		# Boss Scaling & Mechanics
		if e_name.contains("Alden"):
			if combat_turn_count > 8:
				enemy["damage"] += 2
				combat_log_label.text = "King Alden GOES BERSERK! Damage surged to %d!" % enemy["damage"]
			else:
				enemy["damage"] += 1
				combat_log_label.text = "King Alden enrages! Damage increased to %d." % enemy["damage"]
			
			# Anti-Turtle: Shield puncture if player stacks 16+ block
			if player_block >= 16:
				var puncture = int(player_block * 0.20)
				player_block -= puncture
				player_hp = maxi(0, player_hp - puncture)
				_spawn_floating_text("SHIELD SHATTER! -%d HP" % puncture, hero_sprite.global_position, Color(1, 0.3, 0.3))
				_shake_node(hero_sprite)
				combat_log_label.text = "King Alden's Royal Blade punctures guard for %d direct damage!" % puncture
			
			# Royal Banishment: Banishes 1 active summon every 3 turns
			if combat_turn_count % 3 == 0 and active_summons.size() > 0:
				var purged = active_summons.pop_front()
				if purged.get("id", "") == "vargas_spirit":
					vanguard_active = false
				var spr_list = _get_slot_sprites()
				var p_slot = purged.get("slot_index", 0)
				if p_slot < spr_list.size():
					_spawn_floating_text("BANISHED!", spr_list[p_slot].global_position + Vector2(20, 20), Color(1.0, 0.9, 0.2))
					_shake_node(spr_list[p_slot])
				combat_log_label.text = "King Alden executes Royal Banishment! %s is dispelled!" % purged["name"]
				_update_summon_slots_ui()
		elif e_name.contains("Malakor"):
			if combat_turn_count % 3 == 0:
				var bleed_dmg = 2
				player_hp = maxi(0, player_hp - bleed_dmg)
				_spawn_floating_text("SUN-FLAME! -%d HP" % bleed_dmg, hero_sprite.global_position, Color(1, 0.5, 0.1))
				combat_log_label.text = "Malakor brands the Hero with Sun-Flame (-%d HP)!" % bleed_dmg
				
				# Holy Purge: Disperse accumulated block and banish 1 active summon
				if player_block > 8:
					var dispelled = int(player_block * 0.5)
					player_block -= dispelled
					_spawn_floating_text("DISPEL -%d" % dispelled, hero_sprite.global_position, Color(1.0, 0.8, 0.2))
				
				if active_summons.size() > 0:
					var purged = active_summons.pop_front()
					if purged.get("id", "") == "vargas_spirit":
						vanguard_active = false
					var spr_list = _get_slot_sprites()
					var p_slot = purged.get("slot_index", 0)
					if p_slot < spr_list.size():
						_spawn_floating_text("PURGED!", spr_list[p_slot].global_position + Vector2(20, 20), Color(1.0, 0.9, 0.2))
						_shake_node(spr_list[p_slot])
					combat_log_label.text = "Malakor casts HOLY PURGE! %s is banished from the battlefield!" % purged["name"]
					_update_summon_slots_ui()

		# If enemy is weak, reduce damage by 25%
		if enemy["afflictions"]["weak"] > 0 and incoming_dmg > 0:
			incoming_dmg = maxi(1, int(incoming_dmg * 0.75))
			
		# Check for active Taunt summon (Vargas, Boros, etc.)
		if incoming_dmg > 0:
			var taunt_target: Dictionary = {}
			var taunt_idx: int = -1
			for i in range(active_summons.size()):
				if active_summons[i].get("has_taunt", false) and active_summons[i].get("hp", 0) > 0:
					taunt_target = active_summons[i]
					taunt_idx = i
					break
			
			if not taunt_target.is_empty() and not bypass_vanguard:
				taunt_target["hp"] -= incoming_dmg
				combat_log_label.text = "%s strikes %s for %d damage!" % [enemy["name"], taunt_target["name"], incoming_dmg]
				var t_slot = taunt_target.get("slot_index", 0)
				var spr_list = _get_slot_sprites()
				if t_slot < spr_list.size():
					_shake_node(spr_list[t_slot])
					DamageImpact.create_at(vfx_layer, spr_list[t_slot].global_position + Vector2(35, 45), DamageImpact.ImpactType.SLASH, incoming_dmg)
				if taunt_target["hp"] <= 0:
					combat_log_label.text += " %s has fallen!" % taunt_target["name"]
					if t_slot < spr_list.size():
						_spawn_floating_text("FALLEN", spr_list[t_slot].global_position + Vector2(20, 20), Color(0.9, 0.3, 0.3))
					if taunt_target.get("id", "") == "vargas_spirit":
						vanguard_active = false
					active_summons.remove_at(taunt_idx)
					_update_summon_slots_ui()
			else:
				var net_dmg = maxi(0, incoming_dmg - player_block)
				player_block = maxi(0, player_block - incoming_dmg)
				player_hp = maxi(0, player_hp - net_dmg)
				combat_log_label.text = "%s strikes the Hero for %d damage!" % [enemy["name"], net_dmg]
				_shake_node(hero_sprite)
				if net_dmg > 0:
					DamageImpact.create_at(vfx_layer, hero_sprite.global_position + Vector2(55, 65), DamageImpact.ImpactType.SLASH, net_dmg)

			# Cleave damage from sweeps
			if cleave_damage > 0:
				var unblocked_cleave = maxi(0, cleave_damage - player_block)
				player_block = maxi(0, player_block - cleave_damage)
				player_hp = maxi(0, player_hp - unblocked_cleave)
				if unblocked_cleave > 0 and is_instance_valid(hero_sprite):
					_spawn_floating_text("CLEAVE -%d" % unblocked_cleave, hero_sprite.global_position, Color(1.0, 0.4, 0.4))

		# Afflictions tick down at round end
		for aff_key in enemy["afflictions"].keys():
			if enemy["afflictions"][aff_key] > 0:
				enemy["afflictions"][aff_key] -= 1
					
	_update_stats_ui()
	
	if alive_count == 0:
		_on_victory()
		return
		
	if player_hp <= 0:
		combat_log_label.text = "The Hero has fallen in battle..."
		return
		
	# New player turn
	_start_player_turn()

func _check_combat_resolution() -> void:
	if _get_first_alive_enemy_index() == -1:
		_on_victory()

func _has_any_summon_card() -> bool:
	if GameManager.active_deck != null and GameManager.active_deck.cards.size() > 0:
		for c in GameManager.active_deck.cards:
			if c != null and c.card_type == CardData.CardType.SUMMON:
				return true
	for c in draw_pile + discard_pile:
		if c != null and c.card_type == CardData.CardType.SUMMON:
			return true
	for card_ui in hand_cards:
		if is_instance_valid(card_ui) and card_ui.card_data != null and card_ui.card_data.card_type == CardData.CardType.SUMMON:
			return true
	return active_summons.size() > 0

func _on_victory() -> void:
	if claim_card_modal != null and not is_tutorial:
		# Check for 1-time guaranteed boss conquest summons (Boros after Act I, Malakor after Act II)
		var boss_reward: CardData = _get_boss_conquest_card()
		if boss_reward != null and not _deck_has_card(boss_reward.id):
			claim_card_modal.show_reward([boss_reward], "CONQUEST: SOUL BOUND", "You bound the defeated commander into your Grimoire as a permanent summon:", false)
			return

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
		
		# Enforce no summon cards in spoils of war
		pool = pool.filter(func(c: CardData): return c != null and c.card_type != CardData.CardType.SUMMON)
			
		pool.shuffle()
		var offerings: Array[CardData] = [pool[0], pool[1], pool[2]]
		claim_card_modal.show_reward(offerings, "VICTORY ACHIEVED", "Claim spoils of battle — Choose 1 card for your Grimoire:", true)
	else:
		victory_overlay.visible = true

func _get_boss_conquest_card() -> CardData:
	if encounter_res == null:
		return null
	var enc_id = encounter_res.id.to_lower()
	var enc_title = encounter_res.title.to_lower()
	
	if enc_id == "ch1_boss_battle" or (enc_title.begins_with("boss") and (enc_title.contains("boros") or enc_title.contains("granary"))):
		return load("res://core/cards/data/boros_revenant.tres") as CardData
	elif enc_id == "ch2_boss_battle" or (enc_title.begins_with("boss") and enc_title.contains("malakor")):
		return load("res://core/cards/data/malakor_inquisitor.tres") as CardData
		
	return null

func _deck_has_card(card_id: String) -> bool:
	if GameManager.active_deck != null:
		for c in GameManager.active_deck.cards:
			if c != null and c.id == card_id:
				return true
	return false

func _on_cards_drafted(cards: Array[CardData]) -> void:
	if GameManager.active_deck == null:
		var starter = load("res://core/cards/data/starter_vanguard_deck.tres") as DeckData
		if starter != null:
			GameManager.active_deck = DeckData.new()
			GameManager.active_deck.deck_name = starter.deck_name
			GameManager.active_deck.cards = starter.cards.duplicate()
	if GameManager.active_deck != null:
		for card in cards:
			GameManager.active_deck.cards.append(card)
	_on_finish_battle()

func _on_finish_battle() -> void:
	GameManager.crusade_hero_hp = player_hp
	GameManager.crusade_max_hp = player_max_hp
	GameManager.complete_crusade_node()
	var next_dialog: String = GameManager.active_params.get("next_dialog_id", "")
	if next_dialog.is_empty() and encounter_res != null:
		next_dialog = encounter_res.next_dialog_id

	if not next_dialog.is_empty():
		GameManager.switch_state(GameManager.GameState.DIALOG, {
			"chapter": GameManager.active_params.get("chapter", "chapter_1"),
			"dialog_id": next_dialog
		})
	else:
		GameManager.switch_state(GameManager.GameState.WORLD_MAP, {
			"chapter": GameManager.active_params.get("chapter", "chapter_1"),
			"completed_encounter": encounter_res.id if encounter_res != null else "ch1_battle_tutorial",
			"pending_node_id": GameManager.active_params.get("pending_node_id", "")
		})

# ----------------- Dialog Presentation -----------------
func _show_dialog() -> void:
	current_dialog_index = 0
	_last_advance_msec = Time.get_ticks_msec() + 200
	event_overlay.visible = true
	_display_dialog_line()

func _display_dialog_line() -> void:
	if current_dialog_index < dialog_lines.size():
		var line = dialog_lines[current_dialog_index]
		speaker_label.text = line.get("speaker", "Tutorial")
		message_label.text = line.get("text", "")
	else:
		event_overlay.visible = false
		# Point 1: When dialogue finishes, reveal combat UI!
		combat_ui.visible = true
		_start_player_turn()
		if is_tutorial:
			_show_tutorial_guide(0)

func _advance_dialog() -> void:
	current_dialog_index += 1
	_display_dialog_line()

# ----------------- Tutorial Guide Handling -----------------
func _show_tutorial_guide(step: int) -> void:
	current_guide_step = clampi(step, 0, TUTORIAL_TIPS.size() - 1)
	var tip = TUTORIAL_TIPS[current_guide_step]
	guide_title_label.text = tip["title"]
	guide_content_label.text = tip["content"]
	if guide_image != null and tip.has("image"):
		var img_res = load(tip["image"])
		if img_res is Texture2D:
			guide_image.texture = img_res
			guide_image.visible = true
	tutorial_overlay.visible = true

func _on_next_guide_step() -> void:
	current_guide_step = (current_guide_step + 1) % TUTORIAL_TIPS.size()
	_show_tutorial_guide(current_guide_step)

func _on_close_guide_pressed() -> void:
	tutorial_overlay.visible = false
	combat_log_label.text = "Tutorial Active: Tap an enemy to target, then play a card!"

# ----------------- Input -----------------
func _input(event: InputEvent) -> void:
	if inspect_callout_panel != null and inspect_callout_panel.visible:
		var is_click = (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventScreenTouch and event.pressed)
		if is_click:
			if Time.get_ticks_msec() - _inspect_open_msec >= 250:
				var click_pos = event.position
				if not inspect_callout_panel.get_global_rect().has_point(click_pos):
					var on_badge = false
					for node in enemy_ui_nodes:
						if not is_instance_valid(node):
							continue
						var b1 = node.find_child("IntentBadge", true, false) as Control
						if b1 != null and b1.get_global_rect().has_point(click_pos):
							on_badge = true
							break
						var b2 = node.find_child("AfflictionsTray", true, false) as Control
						if b2 != null and b2.get_global_rect().has_point(click_pos):
							on_badge = true
							break
					if not on_badge:
						_hide_enemy_inspect_callout()

	if claim_card_modal != null and claim_card_modal.visible:
		return
	if not event_overlay.visible:
		return
	var is_tap = (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventScreenTouch and event.pressed)
	if not is_tap:
		return
	var now = Time.get_ticks_msec()
	if now < _last_advance_msec + 220:
		return
	_last_advance_msec = now
	_advance_dialog()
	get_viewport().set_input_as_handled()

# ----------------- Tactical Intel & Enemy Inspection -----------------
func _get_enemy_intent_info(enemy: Dictionary, e_idx: int = -1) -> Dictionary:
	if e_idx < 0:
		e_idx = enemies.find(enemy)
	var e_name: String = enemy.get("name", "")
	var base_dmg: int = enemy.get("damage", 6)
	if enemy.get("afflictions", {}).get("weak", 0) > 0:
		base_dmg = maxi(1, int(base_dmg * 0.75))
		
	var type = "attack"
	var badge_text = "%d" % base_dmg
	var icon_tex: Texture2D = intent_attack_texture
	var title = "Strike"
	var desc = "Will strike for %d damage." % base_dmg
	var specials: Array[String] = []
	var bypass_vanguard = false
	var cleave_dmg = 0
	var block_gain = 0

	# Bosses: Alden, Malakor
	if e_name.contains("Alden"):
		title = "Royal Execution"
		desc = "King Alden strikes for %d damage." % base_dmg
		if combat_turn_count % 3 == 0:
			specials.append("👑 Royal Banishment: Banishes 1 active summon.")
		if player_block >= 16:
			specials.append("🗡 Royal Shatter: Punctures 20% of block directly into HP.")
		specials.append("⚔ Enrages: +1 Dmg every turn (+2 after Turn 8).")
	elif e_name.contains("Malakor"):
		title = "Sun-Flame Brand"
		desc = "High Inquisitor Malakor strikes for %d damage." % base_dmg
		if combat_turn_count % 3 == 0:
			specials.append("🔥 Sun-Flame: -2 HP direct damage.")
			specials.append("✨ Holy Purge: Dispels 50% Block and banishes 1 summon.")
	elif e_name.contains("Golem"):
		if combat_turn_count % 3 == 1:
			type = "charge"
			base_dmg = 0
			badge_text = "CHG"
			icon_tex = intent_buff_texture
			title = "Cataclysm Charge"
			desc = "⏳ Channels Solar Core! Next turn unleashes 14 unblockable beam damage."
			specials.append("⏳ Prepares a devastating unblockable Solar Beam.")
		elif combat_turn_count % 3 == 2:
			type = "attack"
			base_dmg = 14
			bypass_vanguard = true
			badge_text = "14"
			icon_tex = intent_attack_texture
			title = "Solar Beam"
			desc = "💥 Fires high-intensity beam for 14 direct damage, piercing through summons!"
			specials.append("💥 Bypasses active summons directly to the Hero.")
		else:
			type = "defend"
			base_dmg = 0
			block_gain = 12
			badge_text = "12"
			icon_tex = intent_defend_texture
			title = "Coolant Barrier"
			desc = "🛡 Vents heat and hardens exterior plating (+12 Block)."
	elif e_name.contains("Maiden") or e_name.contains("Knight"):
		if (combat_turn_count + e_idx) % 3 == 1:
			type = "riposte"
			base_dmg = 0
			block_gain = 10
			badge_text = "10"
			icon_tex = intent_defend_texture
			title = "Riposte Stance"
			desc = "⚔️🛡️ Adopts counter stance (+10 Block). Reflects 4 recoil damage if attacked this round!"
			specials.append("⚔️ Riposte: Reflects 4 damage back to Hero if struck.")
		elif (combat_turn_count + e_idx) % 3 == 2:
			type = "attack"
			base_dmg += 2
			badge_text = "%d" % base_dmg
			icon_tex = intent_attack_texture
			title = "Heavy Thrust"
			desc = "Strikes for %d heavy piercing damage." % base_dmg
		else:
			type = "guard_squad"
			base_dmg = 0
			block_gain = 5
			badge_text = "+5"
			icon_tex = intent_defend_texture
			title = "Phalanx Guard"
			desc = "🛡 Grants +5 Block to all living allies."
	elif e_name.contains("Halberdier") or e_name.contains("Vanguard"):
		if (combat_turn_count + e_idx) % 2 == 1:
			type = "defend"
			base_dmg = 0
			block_gain = 8
			badge_text = "8"
			icon_tex = intent_defend_texture
			title = "Shield Wall"
			desc = "🛡 Locks shields and braces (+8 Block)."
		else:
			type = "attack"
			cleave_dmg = 4
			badge_text = "%d" % base_dmg
			icon_tex = intent_attack_texture
			title = "Sweeping Halberd"
			desc = "🪓 Sweeps for %d damage and cleaves 4 unblockable damage through summons." % base_dmg
			specials.append("🪓 Cleaves 4 unblockable damage directly to Hero.")
	elif e_name.contains("Arbalestier") or e_name.contains("Crossbowman") or e_name.contains("Bowman"):
		if (combat_turn_count + e_idx) % 2 == 1:
			type = "attack"
			base_dmg += 2
			bypass_vanguard = true
			badge_text = "%d" % base_dmg
			icon_tex = intent_attack_texture
			title = "Piercing Bolt"
			desc = "🏹 Fires armor-piercing projectile for %d damage, bypassing summons!" % base_dmg
			specials.append("🏹 Pierces through active summons.")
		else:
			type = "defend"
			base_dmg = 0
			block_gain = 5
			badge_text = "5"
			icon_tex = intent_defend_texture
			title = "Take Cover"
			desc = "🛡 Reloads from behind barricade (+5 Block)."
	elif e_name.contains("Hound"):
		if (combat_turn_count + e_idx) % 3 == 1:
			type = "howl"
			base_dmg = 0
			badge_text = "HOWL"
			icon_tex = intent_buff_texture
			title = "Terrifying Howl"
			desc = "🐺 Emits chilling howl: inflicts Frail on the Hero (-35% Block effectiveness)."
			specials.append("🐺 Inflicts Frail on Hero.")
		elif (combat_turn_count + e_idx) % 3 == 2:
			type = "attack"
			badge_text = "%d" % base_dmg
			icon_tex = intent_attack_texture
			title = "Savage Tear"
			desc = "🩸 Lunges for %d damage and inflicts 2 Bleed." % base_dmg
			specials.append("🩸 Inflicts 2 Bleed on hit.")
		else:
			type = "rest"
			base_dmg = 0
			badge_text = "REST"
			icon_tex = intent_buff_texture
			title = "Prowl"
			desc = "Stalks cautiously around the flank."
	elif (e_name.contains("Captain") or e_name.contains("Boros") or e_name.contains("Vane") or e_name.contains("Lorian")) and not e_name.contains("Alden"):
		if combat_turn_count % 3 == 1:
			type = "rally"
			base_dmg = 0
			badge_text = "+2"
			icon_tex = intent_buff_texture
			title = "Rallying Warhorn"
			desc = "🎺 Sounds battle horn: grants +2 permanent attack damage to all squad allies!"
			specials.append("🎺 Inspires allies with +2 Attack Damage.")
		elif combat_turn_count % 3 == 2:
			type = "attack"
			base_dmg += 2
			cleave_dmg = 3
			badge_text = "%d" % base_dmg
			icon_tex = intent_attack_texture
			title = "Commander's Cleave"
			desc = "Cleaves for %d damage and sweeps through active summons." % base_dmg
		else:
			type = "guard_squad"
			base_dmg = 0
			block_gain = 6
			badge_text = "+6"
			icon_tex = intent_defend_texture
			title = "Phalanx Command"
			desc = "🛡 Commands phalanx formation: grants +6 Block to all allies."
	else:
		badge_text = "%d" % base_dmg

	return {
		"type": type,
		"title": title,
		"damage": base_dmg,
		"badge_text": badge_text,
		"icon_texture": icon_tex,
		"desc": desc,
		"specials": specials,
		"bypass_vanguard": bypass_vanguard,
		"cleave_damage": cleave_dmg,
		"block_gain": block_gain
	}

func _format_afflictions_summary(affs: Dictionary) -> String:
	var parts: Array[String] = []
	if affs.get("vulnerable", 0) > 0:
		parts.append("🩸 Vulnerable x%d (+50%% dmg taken)" % affs["vulnerable"])
	if affs.get("weak", 0) > 0:
		parts.append("💥 Weak x%d (-25%% dmg dealt)" % affs["weak"])
	if affs.get("bleed", 0) > 0:
		parts.append("☠ Bleed x%d (takes %d dmg at end of turn)" % [affs["bleed"], affs["bleed"]])
	if parts.is_empty():
		return "None (Clean)"
	return ", ".join(parts)

func _format_enemy_tactical_intel(index: int) -> String:
	if index < 0 or index >= enemies.size():
		return ""
	var enemy = enemies[index]
	if enemy["hp"] <= 0:
		return "Target %s has fallen." % enemy["name"]
	var intent_info = _get_enemy_intent_info(enemy)
	var aff_str = _format_afflictions_summary(enemy["afflictions"])
	
	var text = "🎯 %s (%d/%d HP) • %s: %s" % [enemy["name"], enemy["hp"], enemy["max_hp"], intent_info["title"], intent_info["desc"]]
	if not intent_info["specials"].is_empty():
		text += " [%s]" % " | ".join(intent_info["specials"])
	text += " • Status: %s" % aff_str
	return text

func _show_enemy_inspect_callout(index: int) -> void:
	if index < 0 or index >= enemies.size() or enemies[index]["hp"] <= 0:
		_hide_enemy_inspect_callout()
		return
	if index >= enemy_ui_nodes.size():
		return

	# If already inspecting this exact enemy and was opened > 200ms ago, toggle it closed
	if _inspected_enemy_index == index and inspect_callout_panel != null and inspect_callout_panel.visible:
		if Time.get_ticks_msec() - _inspect_open_msec > 200:
			_hide_enemy_inspect_callout()
			return

	if _inspect_tween and _inspect_tween.is_valid():
		_inspect_tween.kill()

	_inspected_enemy_index = index
	_inspect_open_msec = Time.get_ticks_msec()
		
	var enemy = enemies[index]
	var enemy_node = enemy_ui_nodes[index]
	var intent_info = _get_enemy_intent_info(enemy)
	
	if inspect_callout_panel == null:
		inspect_callout_panel = Panel.new()
		inspect_callout_panel.name = "EnemyTacticalInspectPanel"
		inspect_callout_panel.custom_minimum_size = Vector2(260, 160)
		inspect_callout_panel.size = Vector2(260, 160)
		inspect_callout_panel.z_index = 30
		inspect_callout_panel.mouse_filter = Control.MOUSE_FILTER_PASS
		
		var p_style = StyleBoxFlat.new()
		p_style.bg_color = Color(0.06, 0.05, 0.09, 0.96)
		p_style.border_color = Color(0.85, 0.72, 0.35, 0.9)
		p_style.set_border_width_all(1)
		p_style.set_corner_radius_all(8)
		p_style.shadow_color = Color(0, 0, 0, 0.6)
		p_style.shadow_size = 12
		inspect_callout_panel.add_theme_stylebox_override("panel", p_style)
		
		var margin = MarginContainer.new()
		margin.name = "Margin"
		margin.set_anchors_preset(Control.PRESET_FULL_RECT)
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_top", 10)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_bottom", 10)
		margin.mouse_filter = Control.MOUSE_FILTER_PASS
		inspect_callout_panel.add_child(margin)
		
		var vbox = VBoxContainer.new()
		vbox.name = "ContentVBox"
		vbox.add_theme_constant_override("separation", 6)
		vbox.mouse_filter = Control.MOUSE_FILTER_PASS
		margin.add_child(vbox)
		
		combat_ui.add_child(inspect_callout_panel)
		
	var vbox = inspect_callout_panel.find_child("ContentVBox", true, false) as VBoxContainer
	if vbox == null:
		return
		
	for c in vbox.get_children():
		c.queue_free()
		
	# 1. Header Row: Name + HP + Close [X]
	var head_row = HBoxContainer.new()
	var name_lbl = Label.new()
	name_lbl.text = enemy["name"]
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_font_override("font", CINZEL_BOLD)
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", Color(0.95, 0.85, 0.55))
	head_row.add_child(name_lbl)
	
	var hp_lbl = Label.new()
	hp_lbl.text = "%d/%d HP" % [enemy["hp"], enemy["max_hp"]]
	hp_lbl.add_theme_font_override("font", CINZEL_BOLD)
	hp_lbl.add_theme_font_size_override("font_size", 12)
	hp_lbl.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
	head_row.add_child(hp_lbl)
	
	var close_btn = Button.new()
	close_btn.text = "✕"
	close_btn.custom_minimum_size = Vector2(20, 20)
	close_btn.flat = true
	close_btn.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	close_btn.pressed.connect(_hide_enemy_inspect_callout)
	head_row.add_child(close_btn)
	vbox.add_child(head_row)
	
	# Separator
	var sep = HSeparator.new()
	sep.modulate = Color(0.85, 0.72, 0.35, 0.4)
	vbox.add_child(sep)
	
	# 2. Upcoming Action / Intent
	var intent_title = Label.new()
	intent_title.text = "⚔ NEXT ACTION: %s" % intent_info["title"].to_upper()
	intent_title.add_theme_font_override("font", CINZEL_SEMIBOLD)
	intent_title.add_theme_font_size_override("font_size", 12)
	intent_title.add_theme_color_override("font_color", Color(1.0, 0.7, 0.3))
	vbox.add_child(intent_title)
	
	var intent_desc = Label.new()
	intent_desc.text = intent_info["desc"]
	intent_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intent_desc.add_theme_font_override("font", CRIMSON_REGULAR)
	intent_desc.add_theme_font_size_override("font_size", 13)
	intent_desc.add_theme_color_override("font_color", Color(0.88, 0.88, 0.92))
	vbox.add_child(intent_desc)
	
	# Specials (Boss Purge, Bleed, etc.)
	for sp in intent_info["specials"]:
		var sp_lbl = Label.new()
		sp_lbl.text = "• %s" % sp
		sp_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		sp_lbl.add_theme_font_override("font", CRIMSON_REGULAR)
		sp_lbl.add_theme_font_size_override("font_size", 12)
		sp_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
		vbox.add_child(sp_lbl)
		
	# 3. Status Afflictions
	var aff_head = Label.new()
	aff_head.text = "AFFLICTIONS:"
	aff_head.add_theme_font_override("font", CINZEL_SEMIBOLD)
	aff_head.add_theme_font_size_override("font_size", 11)
	aff_head.add_theme_color_override("font_color", Color(0.65, 0.65, 0.75))
	vbox.add_child(aff_head)
	
	var aff_detail = Label.new()
	aff_detail.text = _format_afflictions_summary(enemy["afflictions"])
	aff_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	aff_detail.add_theme_font_override("font", CRIMSON_REGULAR)
	aff_detail.add_theme_font_size_override("font_size", 12)
	aff_detail.add_theme_color_override("font_color", Color(0.85, 0.6, 0.95))
	vbox.add_child(aff_detail)
	
	# Adjust Height and Position
	inspect_callout_panel.reset_size()
	var target_pos = enemy_node.global_position + Vector2(-25, -inspect_callout_panel.size.y - 12)
	if target_pos.y < 35:
		target_pos.y = enemy_node.global_position.y + enemy_node.size.y + 10
	inspect_callout_panel.global_position = target_pos
	inspect_callout_panel.visible = true
	
	# Subtle pop-in animation
	inspect_callout_panel.modulate.a = 0.0
	_inspect_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_inspect_tween.tween_property(inspect_callout_panel, "modulate:a", 1.0, 0.12)

func _hide_enemy_inspect_callout() -> void:
	if _inspect_tween and _inspect_tween.is_valid():
		_inspect_tween.kill()
	_inspected_enemy_index = -1
	if inspect_callout_panel != null and inspect_callout_panel.visible:
		_inspect_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_inspect_tween.tween_property(inspect_callout_panel, "modulate:a", 0.0, 0.08)
		_inspect_tween.tween_callback(func():
			if inspect_callout_panel != null:
				inspect_callout_panel.visible = false
		)
