extends Node2D
class_name DamageImpact

enum ImpactType {
	SLASH,
	HEAVY_SLASH,
	NECROTIC,
	CRITICAL,
	BLUNT
}

@onready var slash_sprite: TextureRect = $SlashSprite
@onready var shockwave_ring: TextureRect = $ShockwaveRing
@onready var spark_particles: CPUParticles2D = $SparkParticles

const SLASH_NORMAL_TEX = preload("res://battlefield/assets/vfx_slash.svg")
const SLASH_HEAVY_TEX = preload("res://battlefield/vfx/damage_impact/slash_heavy.svg")

func play(impact_type: ImpactType = ImpactType.SLASH, damage: int = 0) -> void:
	var base_scale: float = 1.0
	var tint: Color = Color(1.0, 1.0, 1.0)
	var texture_to_use: Texture2D = SLASH_NORMAL_TEX
	var spark_color: Color = Color(0.4, 0.85, 1.0)
	
	if damage >= 20 or impact_type == ImpactType.HEAVY_SLASH:
		base_scale = 1.35
		texture_to_use = SLASH_HEAVY_TEX
		tint = Color(1.3, 1.1, 0.7)
		spark_color = Color(1.0, 0.7, 0.2)
	elif impact_type == ImpactType.CRITICAL:
		base_scale = 1.45
		texture_to_use = SLASH_HEAVY_TEX
		tint = Color(2.0, 0.4, 0.4)
		spark_color = Color(1.0, 0.3, 0.3)
	elif impact_type == ImpactType.NECROTIC:
		base_scale = 1.15
		tint = Color(0.3, 1.6, 0.9)
		spark_color = Color(0.2, 1.0, 0.7)
	elif impact_type == ImpactType.BLUNT:
		base_scale = 1.1
		tint = Color(1.5, 1.3, 0.9)
		spark_color = Color(1.0, 0.9, 0.5)
	else:
		if damage >= 10:
			base_scale = 1.15
			texture_to_use = SLASH_HEAVY_TEX
		tint = Color(0.6, 1.2, 2.0)
		spark_color = Color(0.4, 0.9, 1.0)
		
	# 1. Setup Slash Texture & Orientation
	slash_sprite.texture = texture_to_use
	slash_sprite.modulate = tint
	slash_sprite.pivot_offset = slash_sprite.size * 0.5
	slash_sprite.scale = Vector2(0.3, 0.3) * base_scale
	slash_sprite.rotation_degrees = randf_range(-25.0, 25.0)
	
	# 2. Setup Shockwave Ring
	shockwave_ring.modulate = Color(tint.r, tint.g, tint.b, 0.9)
	shockwave_ring.pivot_offset = shockwave_ring.size * 0.5
	shockwave_ring.scale = Vector2(0.2, 0.2)
	
	# 3. Setup Sparks
	spark_particles.color = spark_color
	spark_particles.amount = 14 if damage >= 15 else 8
	spark_particles.initial_velocity_min = 140.0 * base_scale
	spark_particles.initial_velocity_max = 260.0 * base_scale
	spark_particles.restart()
	spark_particles.emitting = true
	
	# 4. Tween Animation
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Slash expansion and fade
	tw.tween_property(slash_sprite, "scale", Vector2(1.25, 1.25) * base_scale, 0.2)
	tw.tween_property(slash_sprite, "modulate:a", 0.0, 0.2).set_delay(0.04)
	
	# Shockwave expansion
	tw.tween_property(shockwave_ring, "scale", Vector2(1.5, 1.5) * base_scale, 0.24)
	tw.tween_property(shockwave_ring, "modulate:a", 0.0, 0.24)
	
	# Self Cleanup after particles finish
	tw.chain().tween_interval(0.2)
	tw.chain().tween_callback(queue_free)

static func create_at(parent: Node, global_pos: Vector2, impact_type: ImpactType = ImpactType.SLASH, damage: int = 0) -> DamageImpact:
	var scene = load("res://battlefield/vfx/damage_impact/damage_impact.tscn") as PackedScene
	if scene == null:
		return null
	var inst = scene.instantiate() as DamageImpact
	parent.add_child(inst)
	inst.global_position = global_pos
	inst.play(impact_type, damage)
	return inst
