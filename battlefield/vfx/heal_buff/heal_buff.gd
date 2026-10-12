extends Node2D
class_name HealBuff

@onready var sparkle_particles: CPUParticles2D = $SparkleParticles
@onready var aura_ring: TextureRect = $AuraRing

func play(tint: Color = Color(0.4, 1.0, 0.6)) -> void:
	sparkle_particles.color = tint
	sparkle_particles.restart()
	sparkle_particles.emitting = true
	
	aura_ring.modulate = tint
	aura_ring.scale = Vector2(0.2, 0.2)
	aura_ring.pivot_offset = aura_ring.size * 0.5
	
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(aura_ring, "scale", Vector2(1.5, 1.5), 0.35)
	tw.tween_property(aura_ring, "modulate:a", 0.0, 0.35)
	
	tw.chain().tween_interval(0.2)
	tw.chain().tween_callback(queue_free)

static func create_at(parent: Node, global_pos: Vector2, tint: Color = Color(0.4, 1.0, 0.6)) -> HealBuff:
	var scene = load("res://battlefield/vfx/heal_buff/heal_buff.tscn") as PackedScene
	if scene == null:
		return null
	var inst = scene.instantiate() as HealBuff
	parent.add_child(inst)
	inst.global_position = global_pos
	inst.play(tint)
	return inst
