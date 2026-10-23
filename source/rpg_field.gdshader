shader_type canvas_item;
render_mode unshaded, blend_add;
uniform float age=0.0;
uniform int kind=0;
uniform float strike=0.2;
uniform float strength=1.0;
uniform vec4 tint:source_color=vec4(1.0);
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
float ring(vec2 p,float r,float w){return exp(-pow(abs((length(p)-r)/w),2.0));}
float line(vec2 p,vec2 a,vec2 b,float w){vec2 q=p-a,v=b-a;float h=clamp(dot(q,v)/dot(v,v),0.0,1.0);return exp(-pow(abs(length(q-v*h)/w),2.0));}
void fragment(){
 vec2 p=(UV-.5)*vec2(900.0,580.0);
 float t=age-strike;float a=0.0;float hot=0.0;
 float after=step(0.0,t);float fade=exp(-max(t,0.0)*3.3)*after;
 float n=noise(p*.025-vec2(t*1.8,t));
 if(kind==0){vec2 q=(p-vec2(0,105))/vec2(240,52);a=ring(q,.5+max(t,0.0)*.5,.025)*fade*(.3+n*.7);hot=exp(-abs(p.y-50.0)*.09-abs(p.x-170.0)*.012)*fade*.2;}
 if(kind==1){float cut=exp(-pow(abs((p.y+8.0+sin(p.x*.018)*2.0)/3.0),2.0))*exp(-pow(abs(p.x/320.0),8.0));float fringe=exp(-pow(abs((p.y+8.0)/15.0),2.0))*exp(-pow(abs(p.x/330.0),8.0));a=(cut+fringe*.38)*fade;hot=cut*exp(-max(t,0.0)*13.0)*after;
 for(int i=0;i<6;i++){float f=float(i);float x=-255.0+f*100.0;float dy=(noise(vec2(f,floor(age*24.0)))-.5)*145.0;vec2 q=p-vec2(x,0);a+=line(q,vec2(0),vec2(35,dy),1.25)*exp(-max(t-.035,0.0)*6.0)*step(.035,t);a+=line(q,vec2(35,dy),vec2(68,dy*.7),.75)*fade;}}
 if(kind==2){vec2 q=(p-vec2(0,110))/vec2(210,65);float theta=atan(q.y,q.x);float pulse=.55+max(t,0.0)*.45;a=(ring(q,pulse,.018)+ring(q,pulse*.73,.01))*(.35+.65*pow(abs(sin(theta*6.0+age)),2.0))*exp(-max(t,0.0)*1.5)*after;hot=exp(-length((p-vec2(0,90))/vec2(100,40)))*fade*.13;}
 if(kind==3){vec2 q=(p-vec2(0,120))/vec2(220,60);for(int i=0;i<3;i++){float u=fract(age*.45+float(i)*.33);a+=ring(q,u*1.3,.015)*(1.0-u)*.7;}a*=smoothstep(0.0,.3,age)*(1.0-smoothstep(1.8,2.7,age));float h=exp(-pow(abs(p.x/115.0),4.0))*exp(-pow(abs((p.y+10.0)/115.0),2.0));a+=h*pow(abs(.5+.5*sin(p.y*.06+age*6.0)),12.0)*.13;}
 if(kind==4){for(int i=0;i<3;i++){vec2 q=(p-vec2(-20.0+float(i)*20.0,25))/vec2(260,115);float angle=atan(q.y,q.x);a+=ring(q,.8-max(t,0.0)*.1,.006+float(i)*.003)*smoothstep(-2.8,-1.6,angle)*(1.0-smoothstep(.1,.65,angle))*fade*.6;}hot=line(p,vec2(140,-95),vec2(225,-20),1.5)*fade;}
 if(kind==5){vec2 q=p-vec2(215,-8);a=ring(q/vec2(55,90),max(t,0.0)*4.0,.025)*fade;hot=line(p,vec2(-230,-8),vec2(215,-8),1.1)*exp(-max(t,0.0)*15.0)*after;for(int i=0;i<4;i++){float x=-180.0+float(i)*85.0;a+=line(p,vec2(x,-14),vec2(x+55.0,-14),.8)*fade*.5;}}
 if(kind==6){vec2 q=(p-vec2(-60,0))/vec2(1,.85);float theta=atan(q.y,q.x);a=ring(q,30.0+max(t,0.0)*650.0,2.0)*(1.0-smoothstep(.65,1.35,abs(theta)))*fade*.55;hot=exp(-length((p-vec2(-60,0))/vec2(25,12)))*exp(-max(t,0.0)*30.0)*after;}
 if(kind==7){vec2 q=(p-vec2(0,115))/vec2(270,75);float th=atan(q.y,q.x);a=ring(q,.15+max(t,0.0)*1.35,.024)*(0.25+pow(abs(sin(th*5.0+n*3.0)),2.0)*.75)*fade;a+=ring(p/vec2(235,190),.25+max(t,0.0)*1.1,.014)*fade*(.45+n*.45);hot=exp(-length((p-vec2(0,15))/vec2(40,70)))*exp(-max(t,0.0)*7.0)*after*.9;}
 vec3 col=mix(tint.rgb,vec3(1.0,.97,.9),clamp(hot,0.0,1.0));COLOR=vec4(col*strength*1.25,clamp(a+hot,0.0,1.0));
}
