shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture;
uniform float shockwave_angle: hint_range(0.0, 6.28) = 0.;
uniform float shockwave_width: hint_range(0.0, 6.28) = 0.;
uniform float shockwave_thickness = 0.;
uniform float shockwave_depth = 0.;
uniform float shockwave_speed = 1.0;
uniform float shockwave_strength: hint_range(0.0, 1.0) = 0.5;
uniform float pixellize_size = 10.;

float pixel_distance_to_angle(vec2 uv_plus_minus_one, float angle_rad) {
  float pixel_angle = atan(uv_plus_minus_one.y, uv_plus_minus_one.x) + PI;
  if (pixel_angle > TAU) {
    pixel_angle -= TAU;
  } else if (pixel_angle < -TAU) {
    pixel_angle += TAU;
  }
  float angle_diff_rad = abs(angle_rad - pixel_angle);
  if (angle_diff_rad > PI) {
    angle_diff_rad = TAU - angle_diff_rad;
  }
  return angle_diff_rad;
}

void fragment() {
	vec2 pos = (UV - 0.5) * 2.;
	pos = round(pos * pixellize_size) / pixellize_size;
	float px_distance_from_angle = max(1. - (pixel_distance_to_angle(pos, shockwave_angle)) / shockwave_width, 0.);
	float shockwave_phase = sin(UV.x * shockwave_thickness + TIME * shockwave_speed);
	COLOR = texture(
		screen_texture,
		(
			SCREEN_UV
			+ ( // Nudge the screen reading just al ittle bit into the direction of the shockwave
				vec2(cos(shockwave_angle), sin(shockwave_angle))
				* shockwave_phase * px_distance_from_angle * shockwave_depth * shockwave_strength
				* (1. - smoothstep(0., 1.5, length(pos))) // do not distort the edges of the texture
			)
		)
	);
}