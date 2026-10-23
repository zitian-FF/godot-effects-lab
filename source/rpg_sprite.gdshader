shader_type canvas_item;
render_mode unshaded, blend_mix;
uniform float age=0.0;
uniform float reveal=1.0;
uniform float dissolve=0.0;
uniform float strength=1.0;
uniform float role=0.0;
uniform vec4 tint:source_color=vec4(1.0);
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void fragment(){
 vec2 uv=UV;
 if(role==3.0)uv.x+=sin(uv.y*23.0-age*5.0)*0.009;
 if(role==0.0 || role==4.0)uv.y+=(noise(vec2(uv.x*28.0-age*5.0,uv.y*11.0))-.5)*.014;
 vec4 tx=texture(TEXTURE,uv);
 float n=noise(uv*18.0+vec2(age*1.7,-age*1.2));
 float erode=mix(1.0,smoothstep(dissolve-0.04,dissolve+0.12,n),smoothstep(0.0,.18,dissolve));
 float gate=1.0-smoothstep(reveal,reveal+0.07,uv.x);
 float lead=exp(-abs(uv.x-reveal)*34.0);
 float veins=pow(clamp(tx.r,0.0,1.0),5.0);
 vec3 dark=tint.rgb*vec3(0.65,0.55,0.6);
 vec3 col=mix(dark,tint.rgb,0.35+0.65*tx.r);
 col=mix(col,vec3(1.0,0.94,0.79),clamp(lead*0.8+veins*0.5,0.0,0.85));
 if(role==0.0 || role==4.0){float streak=pow(.5+.5*sin(uv.y*120.0+sin(uv.x*18.0-age*8.0)*5.0),5.0);col=mix(col,tint.rgb*1.3,streak*.35);erode*=.72+.28*noise(uv*vec2(42.0,8.0)-vec2(age*5.0,0));}
 if(role==3.0){float band=exp(-pow(abs((uv.y-fract(age*.65))/.055),2.0));col=mix(tint.rgb*.9,vec3(.85,1.0,1.0),veins*.5+band*.7);}
 if(role==6.0){float core=exp(-pow(abs((uv.y-.5)/.065),2.0));col=mix(tint.rgb,vec3(1.0,.97,.83),core*.95);}
 if(role==7.0){float heat=dot(tx.rgb,vec3(.15,.7,.15));col=mix(vec3(.7,.035,.012),vec3(1.0,.75,.2),smoothstep(.2,.7,heat));col=mix(col,vec3(1.0,.97,.78),smoothstep(.75,.95,heat)*.7+lead*.2);}
 float halo=0.0;
 halo+=texture(TEXTURE,uv+vec2(.012,0)).a;halo+=texture(TEXTURE,uv-vec2(.012,0)).a;
 halo+=texture(TEXTURE,uv+vec2(0,.012)).a;halo+=texture(TEXTURE,uv-vec2(0,.012)).a;
 float alpha=max(tx.a,halo*.045)*gate*erode;
 COLOR=vec4(col*strength,alpha)*COLOR;
}
