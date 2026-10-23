shader_type canvas_item;
render_mode unshaded, blend_mix;
uniform float age=0.0;
uniform float strength=1.0;
uniform float seed_value=17.0;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
float seg(vec2 p,vec2 a,vec2 b,float w){vec2 v=b-a;float d=length(p-a-v*clamp(dot(p-a,v)/max(dot(v,v),.001),0.,1.));return exp(-d*d/(w*w));}
void fragment(){
 vec2 p=(UV-.5)*vec2(900.,580.);p.y+=8.;
 float t=age-.26;float u=max(t,0.);float after=step(0.,t);
 float eye=smoothstep(.005,.09,age)*(1.-smoothstep(.27,.355,age));
 float close=1.-smoothstep(.18,.32,age);
 vec2 lens=p/vec2(260.+(1.-close)*125.,max(3.,72.*close));
 float almond=abs(lens.y)+pow(abs(lens.x),1.7);
 float opening=(1.-smoothstep(.8,1.05,almond))*eye;
 float rim=exp(-pow(abs((almond-1.)/.085),2.))*eye;
 float haze=exp(-dot(p/vec2(280.,90.),p/vec2(280.,90.)))*eye;
 float pulse=exp(-u*15.)*after;
 float linger=(1.-smoothstep(.06,.6,u))*after;
 // The cut has one readable axis. Its dark interior opens, then contracts.
 float ang=-.13;vec2 q=mat2(vec2(cos(ang),-sin(ang)),vec2(sin(ang),cos(ang)))*p;
 float extent=1.-smoothstep(350.,440.,abs(q.x));
 float width=3.+sin(clamp(u/.37,0.,1.)*3.14159)*17.;
 float ns=noise(vec2(q.x*.022,u*3.));
 float torn=q.y-(ns-.5)*26.*smoothstep(.04,.16,u);
 float body=exp(-pow(abs(torn/width),4.))*linger*extent;
 float edge_break=smoothstep(.28,.53,noise(vec2(q.x*.045-u*4.,floor(u*18.)*.34)));
 float border=exp(-pow(abs((abs(torn)-width)/3.5),2.))*linger*extent*mix(1.,edge_break,smoothstep(.025,.12,u));
 float core=exp(-pow(abs(q.y/2.1),2.))*pulse*extent;
 float glow=exp(-abs(q.y)/27.)*extent*(pulse*.75+linger*.15);
 float cyan=exp(-pow(abs((q.y-width-4.)/4.),2.))*exp(-u*11.)*after*extent;
 float bolts=0.;float bolt_glow=0.;
 for(int i=0;i<9;i++){
  float f=float(i);float side=mod(f,2.)*2.-1.;float origin=-335.+f*79.;
  float start=.023+hash(vec2(f,seed_value))*.07;
  float live=smoothstep(start,start+.014,u)*(1.-smoothstep(start+.08,start+.35,u))*after;
  float travel=clamp((u-start)*12.,0.,1.);
  vec2 a=vec2(origin,side*6.);
  for(int j=0;j<5;j++){
   float g=float(j);vec2 b=vec2(origin+(g+1.)*(13.+hash(vec2(f,7.))*8.)+(hash(vec2(f+g,seed_value))-.5)*26.,side*((g+1.)*19.+hash(vec2(f,g))*27.));
   float gate=1.-smoothstep(travel*5.,travel*5.+.3,g);
   bolts+=seg(q,a,b,1.1)*live*gate;
   bolt_glow+=seg(q,a,b,5.)*live*gate;
   a=b;
  }
 }
 float mist=noise(p*.014+vec2(u*2.,-u))*noise(p*.032-vec2(u,0));
 float aura=exp(-dot(p/vec2(340.,125.),p/vec2(340.,125.)))*(eye*.10+pulse*.23+linger*.05)*(.45+mist);
 vec3 light=vec3(.39,.075,1.)*(glow*.9+rim*.5+haze*.10+bolt_glow*.32+aura*2.);
 light+=vec3(.68,.36,1.)*(border*.65+bolts*.75);
 light+=vec3(.35,.87,1.)*cyan*.65;
 light+=vec3(.99,.96,1.)*core*1.2;
 // Premultiplied-looking color reconstructed for blend_mix; dark space is part of the material.
 float dark=max(opening*.80,body*.9);
 float light_alpha=clamp(max(max(light.r,light.g),light.b),0.,1.);
 float alpha=max(dark,light_alpha);
 vec3 rgb=(vec3(.012,.004,.037)*dark+light*strength)/max(alpha,.001);
 float boundary=(1.-smoothstep(365.,445.,abs(p.x)))*(1.-smoothstep(215.,280.,abs(p.y)));
 COLOR=vec4(rgb,alpha*boundary);
}
