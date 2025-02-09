shader_type canvas_item;

uniform vec4 transition_color : source_color;
uniform sampler2D transition_texture : filter_nearest;
uniform float percent : hint_range(0.0, 1.0);

void fragment() {
	// get current pixel color (UV stretched to fit rect shape)
	vec4 transition_texture_color = texture(transition_texture, UV);
	// if transition color brightness is less that percent, make transparent
	if (transition_texture_color.r > percent) {
		COLOR.a = 0.0;
	}
	// else, set it to color rect texture
	else {
		COLOR = transition_color;
	}
}
