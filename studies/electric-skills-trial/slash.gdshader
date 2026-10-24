shader_type canvas_item;
render_mode unshaded, blend_add;
uniform sampler2D edge_tex;
uniform float heading=0.;
uniform float radial_scale=.451923;
uniform float age=0.;
uniform float reveal=1.;
uniform float erosion=0.;
uniform float distortion=4.;
uniform bool raw_mask=false;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void vertex(){
 // Rotate first, then apply the fixed gameplay-plane projection.
 float c=cos(heading),s=sin(heading);
 vec2 p=vec2(c*VERTEX.x-s*VERTEX.y,s*VERTEX.x+c*VERTEX.y);
 VERTEX=p*vec2(radial_scale,radial_scale*.58);
}
void fragment(){
 vec2 local=UV*vec2(1024.,640.)-vec2(512.,652.);
 float along=clamp((atan(local.y,local.x)-radians(-154.))/radians(128.),0.,1.);
 // Warp vanishes at the two tips; the designed head remains anchored.
 float envelope=pow(sin(along*3.14159265),2.);
 vec2 warp=vec2(noise(UV*8.+vec2(age*2.,0.)),noise(UV*8.+vec2(7.,age*3.)))-.5;
 vec2 uv=UV+warp*(2.*distortion)/vec2(1024.,640.)*envelope*(raw_mask?0.:1.);
 vec4 body=texture(TEXTURE,uv),edge=texture(edge_tex,uv);
 float reveal_gate=smoothstep(1.-reveal-.025,1.-reveal+.025,along);
 float grain=noise(vec2(along*38.-age*4.,length(local)*.032));
 float dissolve=smoothstep(erosion-.12,erosion+.14,grain+along*.24);
 float edge_strength=edge.r*edge.a;
 vec3 col=mix(vec3(.34,.10,.73),vec3(.70,.37,1.),body.r);
 col=mix(col,vec3(.96,.91,1.),edge_strength*.88);
 float alpha=body.a*dissolve*reveal_gate;
 if(raw_mask){col=vec3(body.r);alpha=body.a*reveal_gate;}
 COLOR=vec4(col,alpha)*COLOR;
}
