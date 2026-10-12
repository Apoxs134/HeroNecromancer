extends Node2D
class_name SummonBurst

@onready var seal_sprite: TextureRect = $SealSprite
@onready var wisps_particles: CPUParticles2D = $WispsParticles

func play(tint: Color = Color(0.4, 0.85, 1.0)) -> void:
	seal_sprite.modulate = tint
	seal_sprite.scale = Vector2(0.1, 0.04)
	seal_sprite.pivot_offset = seal_sprite.size * 0.5
	
	wisps_particles.color = tint
	wisps_particles.restart()
	wisps_particles.emitting = true
	
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(seal_sprite, "scale", Vector2(1.15, 0.45), 0.28)
	tw.tween_property(seal_sprite, "rotation_degrees", 45.0, 0.4)
	
	tw.chain().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(seal_sprite, "modulate:a", 0.0, 0.22)
	tw.tween_property(seal_sprite, "scale", Vector2(1.35, 0.52), 0.22)
	
	tw.chain().tween_interval(0.15)
	tw.chain().tween_callback(queue_free)

static func create_at(parent: Node, global_pos: Vector2, tint: Color = Color(0.4, 0.85, 1.0)) -> SummonBurst:
	var scene = load("res://battlefield/vfx/summon_burst/summon_burst.tscn") as PackedScene
	if scene == null:
		return null
	var inst = scene.instantiate() as SummonBurst
	parent.add_child(inst)
	inst.global_position = global_pos
	inst.play(tint)
	return inst
