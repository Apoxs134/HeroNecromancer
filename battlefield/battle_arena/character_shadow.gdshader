shader_type canvas_item;

uniform vec4 shadow_color : source_color = vec4(0.03, 0.02, 0.05, 0.50);
uniform float skew_x : hint_range(-1.5, 1.5) = -0.22;
uniform float fade_falloff : hint_range(0.0, 1.0) = 0.35;

void vertex() {
	// Cast shadow slightly sideways/backwards on isometric ground
	float height_from_feet = clamp(1.0 - UV.y, 0.0, 1.0);
	VERTEX.x += height_from_feet * skew_x * 90.0;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	// Soften and fade shadow as it extends away from the feet
	float dist = clamp(1.0 - UV.y, 0.0, 1.0);
	float alpha = tex.a * shadow_color.a * mix(1.0, 1.0 - fade_falloff, dist);
	COLOR = vec4(shadow_color.rgb, alpha);
}
