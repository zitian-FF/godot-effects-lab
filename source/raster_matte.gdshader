shader_type canvas_item;
render_mode unshaded, blend_add;
uniform float black_floor = 0.01;
uniform float exposure = 0.9;
uniform float opacity = 1.0;
void fragment(){
 vec4 raster = texture(TEXTURE, UV);
 COLOR = vec4(max(raster.rgb-vec3(black_floor), vec3(0.0))*exposure, opacity);
}
