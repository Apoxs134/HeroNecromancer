class_name BattleFormation
extends Control

## Battle Formation scene allowing visual positioning and z-index ordering
## of Player, Summon slots, and Enemy slots directly in the Godot 2D editor.

@onready var hero_slot: Control = $HeroSlot
@onready var summon_slot_0: Control = $SummonSlot_0
@onready var summon_slot_1: Control = $SummonSlot_1
@onready var summon_slot_2: Control = $SummonSlot_2

@onready var enemy_slot_0: Control = $EnemySlot_0
@onready var enemy_slot_1: Control = $EnemySlot_1
@onready var enemy_slot_2: Control = $EnemySlot_2
@onready var enemy_slot_3: Control = $EnemySlot_3

func _ready() -> void:
	# Hide editor previews at runtime
	_hide_editor_previews()

func _hide_editor_previews() -> void:
	for slot in [enemy_slot_0, enemy_slot_1, enemy_slot_2, enemy_slot_3]:
		if slot != null:
			var prev = slot.get_node_or_null("Preview")
			if prev != null:
				prev.visible = false

func get_hero_slot() -> Control:
	return hero_slot

func get_summon_slot(index: int) -> Control:
	match index:
		0: return summon_slot_0
		1: return summon_slot_1
		2: return summon_slot_2
		_: return null

func get_summon_slots() -> Array[Control]:
	return [summon_slot_0, summon_slot_1, summon_slot_2]

func get_enemy_slot(index: int) -> Control:
	match index:
		0: return enemy_slot_0
		1: return enemy_slot_1
		2: return enemy_slot_2
		3: return enemy_slot_3
		_: return null

func get_enemy_slots() -> Array[Control]:
	return [enemy_slot_0, enemy_slot_1, enemy_slot_2, enemy_slot_3]
