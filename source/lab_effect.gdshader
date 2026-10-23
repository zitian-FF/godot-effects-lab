shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform float clock = 0.0;
uniform int category = 0;
uniform int mutation = 0;
uniform float seed_value = 1.0;
uniform float strength = 1.0;
uniform vec4 tint : source_color = vec4(1.0);
uniform bool detail_enabled = true;

float hash(vec2 p) {return fract(sin(dot(p, vec2(127.1,311.7)) + seed_value*17.0)*43758.5453);}
float noise(vec2 p) {
 vec2 i=floor(p), f=fract(p); f=f*f*(3.0-2.0*f);
 return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1)),f.x),f.y);
}
float fbm(vec2 p) {float r=0.0;float a=0.5;for(int i=0;i<4;i++){r+=a*noise(p);p=p*2.03+vec2(12.3,4.7);a*=0.5;}return r;}
mat2 rot(float a) {float c=cos(a),s=sin(a);return mat2(vec2(c,s),vec2(-s,c));}
float ring(vec2 p,float r,float w){return 1.0-smoothstep(w,w+0.012,abs(length(p)-r));}
float segment(vec2 p,vec2 a,vec2 b,float w){vec2 pa=p-a,ba=b-a;float h=clamp(dot(pa,ba)/dot(ba,ba),0.0,1.0);return 1.0-smoothstep(w,w+0.008,length(pa-ba*h));}
float diamond(vec2 p,float height,float width){return max(abs(p.x)/width+abs(p.y)/height-1.0,0.0);}

void fragment(){
 vec2 p=(UV-0.5)*2.0;
 float t=clock;
 float attack=smoothstep(0.0,0.065,t);
 float fade=1.0-smoothstep(0.5,1.8,t);
 float a=0.0; float hot=0.0; vec3 rgb=tint.rgb;
 float n=fbm(p*7.0+vec2(0,t*-3.5));
 if(category==0){
  vec2 q=p;
  if(mutation==1) q=rot(1.57)*q;
  if(mutation==2){float theta=atan(q.y,q.x);q=vec2(length(q)-0.32,sin(theta*3.0+t*5.0)*0.12+q.y*0.5);}
  float rise=q.y+0.18;
  float width=mix(0.25,0.05,clamp(-rise,0.0,1.0));
  float field=1.0-abs(q.x+(n-0.5)*0.22)/width;
  field*=1.0-smoothstep(0.0,0.8,abs(q.y+0.05));
  float f=field-(1.0-fbm(q*9.0+vec2(0,t*5.0)))*0.7;
  a=smoothstep(0.0,0.35,f)*fade*attack;
  hot=smoothstep(0.42,0.9,f)*0.58;
  rgb=mix(vec3(0.78,0.12,0.015),vec3(1.0,0.58,0.08),clamp(f*1.5,0.0,1.0));
  if(mutation==2)rgb*=vec3(0.4,0.9,1.4);
 }else if(category==1){
  float discharge=1.0-smoothstep(0.25,0.82,t);
  float tick=floor(t*24.0);
  if(mutation==0 || mutation==2){
   vec2 q=mutation==2 ? rot(1.57)*p : p;
   float x=(noise(vec2(q.y*14.0,tick))*2.0-1.0)*0.20;
   float d=abs(q.x-x);
   a=(1.0-smoothstep(0.005,0.022,d))*(1.0-smoothstep(0.68,0.8,abs(q.y)));
   a+=0.15*exp(-d*30.0);
   for(int i=0;i<3;i++){
    float y=-0.45+float(i)*0.36;
    vec2 start=vec2((noise(vec2(y*14.0,tick))*2.0-1.0)*0.20,y);
    vec2 end=start+vec2((i%2==0 ? 0.35:-0.40),-0.22);
    a+=segment(q,start,end,0.004)*0.55;
   }
  }else{
   for(int i=0;i<6;i++){
    vec2 q=rot(float(i)*1.047)*p;
    float d=abs(q.y-(noise(vec2(q.x*17.0,tick))*2.0-1.0)*0.1);
    a+=exp(-d*160.0)*step(0.06,q.x)*(1.0-smoothstep(0.55,0.75,q.x));
   }
  }
  a*=attack*discharge;hot=clamp(a-0.5,0.0,0.45);
 }else if(category==2){
  float grow=smoothstep(0.0,0.32,t);
  float opacity=1.0-smoothstep(0.7,1.8,t);
  for(int i=0;i<9;i++){
   float fi=float(i);float angle=fi*2.399+0.3;
   vec2 center=vec2(cos(angle),sin(angle))*0.10;
   vec2 q=rot(angle-1.57)* (p-center);
   if(mutation==1){center=vec2(cos(angle),sin(angle))*0.37;q=rot(angle)*(p-center);}
   if(mutation==2){q=rot(-0.75)*(p-vec2((fi-4.0)*0.06,0.0));}
   float h=(0.23+hash(vec2(fi,2))*0.28)*grow;
   float w=(0.025+hash(vec2(fi,8))*0.06)*grow;
   float d=diamond(q+vec2(0,h*0.35),max(h,0.001),max(w,0.001));
   float body=1.0-smoothstep(0.0,0.06,d);
   float facet=mix(0.22,0.8,step(0.0,q.x));
   a=max(a,body*facet);hot=max(hot,body*(1.0-smoothstep(0.0,0.008,abs(q.x)))*0.65);
  }
  a*=opacity;rgb=mix(tint.rgb,vec3(0.82,0.98,1.0),hot);
 }else if(category==3){
  float pulse=sin(clamp(t/1.9,0.0,1.0)*3.14159);
  if(mutation==0){
   a=ring(p,0.36+sin(t*3.0)*0.025,0.006)*0.8+ring(p,0.47,0.003)*0.5;
   for(int i=0;i<12;i++){float f=float(i);float angle=f*0.524+t*1.5;vec2 q=p-vec2(cos(angle),sin(angle))*0.40;a+=exp(-dot(q,q)*2200.0)*0.85;}
  }else if(mutation==1){
   vec2 q=p*vec2(1,1.8);a=ring(q,0.45,0.035)*0.6;
   a+=exp(-dot(q,q)*8.0)*(0.15+noise(p*22.0+t)*0.18);
   a+=segment(p,vec2(-0.13,0),vec2(0.13,0),0.025)+segment(p,vec2(0,-0.13),vec2(0,0.13),0.025);
  }else{
   float ribbons=abs(sin(p.y*9.0+t*4.0)-p.x*4.0);
   a=exp(-ribbons*15.0)*(1.0-smoothstep(0.35,0.7,abs(p.y)));
   a+=exp(-abs(p.x+sin(p.y*8.0-t*3.0)*0.22)*60.0)*0.6;
  }
  a*=pulse;hot=a*0.2;
 }else if(category==4){
  vec2 q=rot(-0.45)*p;q.y*=1.4;
  float theta=atan(q.y,q.x);float radius=length(q);
  float head=-2.8+clamp(t/0.24,0.0,1.0)*4.1;
  float window=step(-2.8,theta)*(1.0-smoothstep(head-0.1,head,theta));
  float taper=sin(clamp((theta+2.8)/4.1,0.0,1.0)*3.14159);
  float arc=exp(-pow((radius-0.48)/(0.012+0.045*taper),2.0));
  a=arc*window;
  if(mutation==1)a+=exp(-pow((radius-0.35)/(0.008+0.022*taper),2.0))*window*0.65;
  if(mutation==2){a=0.0;for(int i=0;i<3;i++){vec2 v=p-vec2(0.0,float(i-1)*0.16);a+=segment(v,vec2(-0.5,-0.17),vec2(0.45,0.12),0.012)*0.8;}}
  if(detail_enabled)a*=smoothstep(0.18,0.5,fbm(p*30.0+vec2(t*2.0,0)));
  a*=1.0-smoothstep(0.24,0.9,t);hot=a*0.5;
 }else if(category==5){
  float reach=mix(-0.6,0.65,smoothstep(0.0,0.13,t));
  vec2 q=p;
  if(mutation==1)q=rot(-0.6)*q;
  int count=mutation==2 ? 3:1;
  for(int i=0;i<3;i++){
   if(i>=count)break;
   float y= count==3 ? float(i-1)*0.16:0.0;
   float width=0.028*clamp((reach-q.x)*3.0,0.0,1.0);
   float body=exp(-abs(q.y-y)/max(width*0.45,0.002));
   float tail=smoothstep(-0.66,-0.32,q.x);
   a+=body*tail*step(q.x,reach);
   a+=exp(-length(vec2((q.x-reach)*0.7,(q.y-y)*2.0))*65.0)*0.8;
  }
  a*=1.0-smoothstep(0.12,0.6,t);hot=a*0.4;
 }else if(category==6){
  vec2 q=p+vec2(0.32,0);
  float cone=abs(q.y)/(max(q.x,0.001)*0.35+0.02);
  float gas=(1.0-smoothstep(0.25,0.8,q.x))*step(0.0,q.x)*(1.0-smoothstep(0.45,1.0,cone));
  gas*=smoothstep(0.2,0.6,fbm(q*15.0+vec2(t*10.0,0)));
  a=gas;
  if(mutation==1){
   float ports=exp(-abs(q.y-q.x*0.65)*90.0)+exp(-abs(q.y+q.x*0.65)*90.0);
   a+=ports*step(0.03,q.x)*(1.0-smoothstep(0.14,0.30,q.x))*(0.3+0.7*noise(q*45.0))*0.6;
  }
  if(mutation==2)a=exp(-abs(q.y)*80.0)*step(0.0,q.x)*(1.0-smoothstep(0.4,0.9,q.x));
  a*=1.0-smoothstep(0.05,0.30,t);hot=a*0.5;rgb=vec3(1.0,0.58,0.12);
 }else{
  float u=clamp(t/1.55,0.0,1.0);
  float radius=0.09+(1.0-pow(1.0-u,3.0))*0.56;
  float turbulence=fbm(p*9.0+vec2(t*-1.0,t*0.7));
  float d=length(p)-(radius+(turbulence-0.5)*0.22);
  float shell=1.0-smoothstep(-0.09,0.04,d);
  float erosion=smoothstep(u*0.8,u*0.8+0.18,turbulence);
  a=shell*erosion*(1.0-smoothstep(0.7,1.7,t))*attack;
  rgb=mix(vec3(0.44,0.05,0.01),vec3(1.0,0.56,0.10),turbulence);
  hot=pow(turbulence,4.0)*0.45;
  if(mutation==1){rgb=mix(vec3(0.14,0.10,0.07),vec3(0.58,0.42,0.25),turbulence);hot=0.0;}
  if(mutation==2){a=ring(p,radius,0.035)*(0.4+turbulence*0.6)*(1.0-u);rgb=vec3(0.48,0.30,1.0);}
 }
 rgb=mix(rgb,vec3(1.0,0.92,0.69),clamp(hot,0.0,0.6));
 float border=1.0-smoothstep(0.83,0.98,max(abs(p.x),abs(p.y)));
 if(t<0.001 || t>2.1)a=0.0;
 COLOR=vec4(rgb*min(strength,1.3),clamp(a*strength,0.0,0.95)*border);
}
