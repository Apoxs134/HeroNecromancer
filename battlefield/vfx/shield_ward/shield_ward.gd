extends Node2D
class_name ShieldWard

@onready var shield_sprite: TextureRect = $ShieldSprite
@onready var ring_sprite: TextureRect = $RingSprite

const HEX_TEX = preload("res://battlefield/vfx/shield_ward/shield_hex.svg")

func play(tint: Color = Color(0.4, 0.75, 1.0)) -> void:
	shield_sprite.modulate = tint
	shield_sprite.scale = Vector2(0.3, 0.3)
	shield_sprite.pivot_offset = shield_sprite.size * 0.5
	
	ring_sprite.modulate = tint
	ring_sprite.scale = Vector2(0.2, 0.2)
	ring_sprite.pivot_offset = ring_sprite.size * 0.5
	
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(shield_sprite, "scale", Vector2(1.2, 1.2), 0.2)
	tw.tween_property(ring_sprite, "scale", Vector2(1.4, 1.4), 0.22)
	
	tw.chain().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(shield_sprite, "scale", Vector2(1.0, 1.0), 0.18)
	tw.tween_property(ring_sprite, "modulate:a", 0.0, 0.18)
	
	tw.chain().tween_property(shield_sprite, "modulate:a", 0.0, 0.25).set_delay(0.12)
	tw.chain().tween_callback(queue_free)

static func create_at(parent: Node, global_pos: Vector2, tint: Color = Color(0.45, 0.75, 1.0)) -> ShieldWard:
	var scene = load("res://battlefield/vfx/shield_ward/shield_ward.tscn") as PackedScene
	if scene == null:
		return null
	var inst = scene.instantiate() as ShieldWard
	parent.add_child(inst)
	inst.global_position = global_pos
	inst.play(tint)
	return inst
