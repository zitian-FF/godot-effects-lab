shader_type canvas_item;
render_mode unshaded, blend_add;
uniform float life=0.0;
uniform vec4 edge_color:source_color=vec4(.48,.16,1.0,1.0);
void fragment(){
 vec4 mask=texture(TEXTURE,UV);
 float d=length(UV-.5);
 vec3 col=mix(vec3(.99,.97,1.0),edge_color.rgb,smoothstep(.025,.32,d));
 COLOR=vec4(col,mask.a*(1.-smoothstep(.015,.095,life)))*COLOR;
}
