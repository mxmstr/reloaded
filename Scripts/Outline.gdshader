shader_type spatial;
render_mode unshaded;

uniform bool enable = true; // on and off switsch to diesable/enable the outline
// outline costumization
uniform float outline_thickness = 0.05; // how thick is the outline?
uniform vec4 color : source_color = vec4(0.0); // which color does the outline have?


void vertex() {
	if (enable) {
	VERTEX += NORMAL*outline_thickness; // apply the outlines thickness	
	}
}

void fragment() {
	if (enable) {

		float fresnel_dot = (1.0 - dot(NORMAL, VIEW)) * 1.5;

		ALBEDO = smoothstep(0, 1, fresnel_dot) * color.rgb; // apply the outlines color
		ALPHA = smoothstep(0, 1, fresnel_dot);
	}
}
