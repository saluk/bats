shader_type canvas_item;

varying vec2 world_position;
uniform vec2 scroll_direction = vec2(0,1);
uniform vec2 position;
uniform vec2 ratio = vec2(1.0);

void fragment() {
	vec2 uv = UV * ratio;
	COLOR = texture(TEXTURE, vec2(
		mod(uv.x - TIME * scroll_direction.x, 1.0),
		mod(uv.y - TIME * scroll_direction.y, 1.0)));
}