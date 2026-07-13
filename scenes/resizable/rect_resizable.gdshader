shader_type canvas_item;

uniform int mode : hint_enum("Horizontal", "Vertical", "Full") = 0;

const int HORIZONTAL = 0;
const int VERTICAL = 1;
const int FULL = 2;


uniform vec4 edge_color : source_color = vec4(1.0,1.0,1.0,1.0);

uniform vec4 center_color : source_color = vec4(0.6,0.8,1.0,1.0);


vec4 get_color_for_horizontal_mode(vec2 _UV){
	// UV.x -> 0, .2 , .5, .75, 1
	// x is between 0 and 1
	// Ex: x == 0.1 --> 0.1 - 0.5 = 0.4 (abs) x 2 = 0.8 --> almost white.
	float gradiant = abs(_UV.x - 0.5) * 2.0;
	//float gradiant = 1.0; // --> white
	//float gradiant = 0.0; // --> blue
	float t = smoothstep(0.0, 2, gradiant);
	return mix(vec4(1, 1, 1, 1), vec4(0, 1, 1, 1), t);
}

vec4 get_color_for_vertical_mode(vec2 _UV){
	float gradiant = abs(_UV.y - 0.5) * 2.0;
	float t = smoothstep(0.0, 2, gradiant);
	return mix(vec4(1, 1, 1, 1), vec4(0, 1, 1, 1), t);
}

vec4 get_color_for_full_mode(vec2 _UV){
	// I don't even know how to explain this.
	//float gradiant = 1.0; // --> white
	//float gradiant = 0.0; // --> blue
    float d = max(	
        abs(_UV.x - 0.5) * 2.0,
		abs(_UV.y - 0.5) * 2.0
    );
  	float t = smoothstep(0.0, 2, d);
	return mix(vec4(1, 1, 1, 1), vec4(0, 1, 1, 1), t);
}


void fragment()
{
	
    switch (mode) {
        case HORIZONTAL:
            COLOR = get_color_for_horizontal_mode(UV);
            break;
        case VERTICAL:
            COLOR = get_color_for_vertical_mode(UV);
            break;
		case FULL:
            COLOR = get_color_for_full_mode(UV);
            break;
    }
	
}


/*
mix(a, b, t) linearly interpolates between two values.

t = 0 → returns a
t = 1 → returns b
t = 0.5 → halfway between a and b


smoothstep() is a function that creates a smooth transition between two values.

Think of it as a softer version of clamp().

0.0  -> 0.0
0.25 -> ~0.16
0.5  -> 0.5
0.75 -> ~0.84
1.0  -> 1.0

*/

