shader_type canvas_item;
render_mode unshaded, blend_add;
uniform float age = 0.0;
uniform float erosion = 0.0;
uniform bool raw_mask = false;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void fragment(){
 vec2 uv=UV;
 // Broad silhouette comes from the authored mask. Noise only breaks the recovery tail.
 uv.y += sin(uv.x*16.0-age*24.0)*.009;
 vec4 mask=texture(TEXTURE,uv);
 float grain=noise(vec2(uv.x*65.0-age*11.0,uv.y*24.0));
 float break_up=smoothstep(erosion-.13,erosion+.13,grain+uv.x*.30);
 float value=clamp(mask.r,0.,1.);
 vec3 body=mix(vec3(.22,.035,.70),vec3(.65,.25,1.0),smoothstep(.25,.75,value));
 vec3 hot=mix(body,vec3(.92,.88,1.0),smoothstep(.88,.99,value)*.82);
 if(raw_mask){hot=vec3(value);break_up=1.0;}
 COLOR=vec4(hot,mask.a*break_up)*COLOR;
}
