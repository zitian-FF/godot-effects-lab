shader_type canvas_item;
render_mode unshaded, blend_add;
uniform float age=0.0;
uniform float reveal=1.0;
uniform float dissolve=0.0;
uniform float strength=1.0;
uniform float role=0.0;
uniform vec4 tint:source_color=vec4(.6,.3,1.,1.);
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void fragment(){
 vec2 uv=UV;vec4 tx=texture(TEXTURE,uv);
 float n=noise(uv*vec2(48.,9.)+vec2(age*9.,age*3.));
 float gate=1.-smoothstep(reveal,reveal+.015,uv.x);
 float erosion=smoothstep(dissolve-.13,dissolve+.17,n);
 vec3 col=mix(tint.rgb,vec3(.98,.94,1.),pow(tx.r,5.)*.86);
 if(role==2.){col=mix(vec3(.33,.07,1.),vec3(1.,.94,1.),pow(tx.r,4.));erosion*=.7+.3*n;}
 float halo=texture(TEXTURE,uv+vec2(.006,0)).a+texture(TEXTURE,uv-vec2(.006,0)).a+texture(TEXTURE,uv+vec2(0,.012)).a+texture(TEXTURE,uv-vec2(0,.012)).a;
 COLOR=vec4(col*strength,(tx.a+halo*.10)*gate*erosion)*COLOR;
}
