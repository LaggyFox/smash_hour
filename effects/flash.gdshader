shader_type canvas_item;
render_mode unshaded;

uniform vec4 flash_color : source_color = vec4(1, 1, 1, 0);
uniform float flash_strength_factor = 1;
uniform float max_flash_strength : hint_range(0, 1) = 1;
uniform bool use_flash_color_as_final_color = false;

uniform vec4 outline_color : source_color = vec4(0);

varying flat vec4 modulate;
void vertex() {
	modulate = COLOR;
}

void fragment() {
	vec4 input_color = texture(TEXTURE, UV);
	if (use_flash_color_as_final_color) {
		COLOR = flash_color;
		COLOR.a *= input_color.a;
	}
	else {
		float flash_strength = flash_color.a * flash_strength_factor;
		flash_strength = min(max_flash_strength, flash_strength);
		COLOR.rgb = mix(input_color.rgb, flash_color.rgb, flash_strength);
		COLOR.a = input_color.a;
	}

	if (outline_color.a > 0.0) {
		vec2 pixel_size = TEXTURE_PIXEL_SIZE;
		bool within = texture(TEXTURE, UV + pixel_size * vec2(1.0, 0.0)).a > 0.0;
		within = within || texture(TEXTURE, UV + pixel_size * vec2(1.0, 1.0)).a > 0.0;
		within = within || texture(TEXTURE, UV + pixel_size * vec2(1.0, -1.0)).a > 0.0;
		within = within || texture(TEXTURE, UV + pixel_size * vec2(0.0, -1.0)).a > 0.0;
		within = within || texture(TEXTURE, UV + pixel_size * vec2(0.0, 1.0)).a > 0.0;
		within = within || texture(TEXTURE, UV + pixel_size * vec2(-1.0, 1.0)).a > 0.0;
		within = within || texture(TEXTURE, UV + pixel_size * vec2(-1.0, -1.0)).a > 0.0;
		within = within || texture(TEXTURE, UV + pixel_size * vec2(-1.0, 0.0)).a > 0.0;
		bool outline = within && texture(TEXTURE, UV).a == 0.0;
		COLOR = float(!outline) * COLOR + float(outline) * outline_color;
	}

	COLOR *= modulate; 
}