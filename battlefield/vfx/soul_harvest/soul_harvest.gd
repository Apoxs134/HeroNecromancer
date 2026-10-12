extends Node2D
class_name SoulHarvest

const MOTE_TEX = preload("res://battlefield/vfx/soul_harvest/soul_mote.svg")

func harvest(start_pos: Vector2, target_pos: Vector2, count: int = 4) -> void:
	global_position = Vector2.ZERO
	var active_motes: int = count
	
	for i in range(count):
		var delay = i * 0.08
		get_tree().create_timer(delay).timeout.connect(func():
			_launch_mote(start_pos, target_pos, func():
				active_motes -= 1
				if active_motes <= 0:
					queue_free()
			)
		)

func _launch_mote(from_pos: Vector2, to_pos: Vector2, on_complete: Callable) -> void:
	var mote = TextureRect.new()
	mote.texture = MOTE_TEX
	mote.custom_minimum_size = Vector2(36, 36)
	mote.pivot_offset = Vector2(18, 18)
	mote.scale = Vector2(0.4, 0.4)
	mote.modulate = Color(1.5, 2.0, 1.8)
	
	var mat = CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	mote.material = mat
	
	add_child(mote)
	mote.global_position = from_pos - Vector2(18, 18)
	
	# Trailing particles
	var trail = CPUParticles2D.new()
	trail.material = mat
	trail.texture = MOTE_TEX
	trail.amount = 8
	trail.lifetime = 0.25
	trail.scale_amount_min = 0.2
	trail.scale_amount_max = 0.4
	trail.color = Color(0.2, 0.9, 0.6, 0.7)
	trail.gravity = Vector2.ZERO
	trail.emitting = true
	mote.add_child(trail)
	trail.position = Vector2(18, 18)
	
	# Arching Bezier curve control point
	var mid = (from_pos + to_pos) * 0.5
	var perp = Vector2(-(to_pos.y - from_pos.y), to_pos.x - from_pos.x).normalized()
	var control_pt = mid + perp * randf_range(-60.0, 60.0) + Vector2(0, randf_range(-70.0, -30.0))
	
	# Pop scale up
	var pop_tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop_tw.tween_property(mote, "scale", Vector2(1.0, 1.0), 0.15)
	
	# Fly along curve
	var fly_tw = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fly_tw.tween_method(func(t: float):
		var p0 = from_pos
		var p1 = control_pt
		var p2 = to_pos
		var pos = (1.0 - t) * (1.0 - t) * p0 + 2.0 * (1.0 - t) * t * p1 + t * t * p2
		mote.global_position = pos - Vector2(18, 18)
	, 0.0, 1.0, 0.48)
	
	fly_tw.tween_callback(func():
		trail.emitting = false
		var end_tw = create_tween().set_parallel(true)
		end_tw.tween_property(mote, "scale", Vector2(1.6, 1.6), 0.1)
		end_tw.tween_property(mote, "modulate:a", 0.0, 0.1)
		end_tw.chain().tween_callback(func():
			mote.queue_free()
			on_complete.call()
		)
	)

static func create(parent: Node, start_pos: Vector2, target_pos: Vector2, count: int = 4) -> SoulHarvest:
	var harvest_node = SoulHarvest.new()
	parent.add_child(harvest_node)
	harvest_node.harvest(start_pos, target_pos, count)
	return harvest_node
