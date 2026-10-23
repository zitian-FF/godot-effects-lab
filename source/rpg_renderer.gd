extends Node2D
const Catalog=preload("res://rpg_catalog.gd")
const SURFACE=preload("res://rpg_sprite.gdshader")
const FIELD=preload("res://rpg_field.gdshader")
var kind=0
var seed_value=17
var last_time=-1.0
var sprites_on=true
var shaders_on=true
var particles_on=true
var cards:Array[Sprite2D]=[]
var emitters:Array[GPUParticles2D]=[]
var delays:Array[float]=[]
var field:ColorRect
var field_material:ShaderMaterial
var surfaces:Array[ShaderMaterial]=[]
func _ready():
	field=ColorRect.new()
	field.position=Vector2(-450,-290)
	field.size=Vector2(900,580)
	field.mouse_filter=Control.MOUSE_FILTER_IGNORE
	field_material=ShaderMaterial.new()
	field_material.shader=FIELD
	field.material=field_material
	add_child(field)
	field.z_index=0
func card(texture:String,col:Color)->Sprite2D:
	var s=Sprite2D.new()
	s.texture=load("res://art/rpg/"+texture)
	var mat=ShaderMaterial.new()
	mat.shader=SURFACE
	mat.set_shader_parameter("tint",col)
	mat.set_shader_parameter("role",float(kind))
	s.material=mat
	add_child(s)
	cards.append(s)
	surfaces.append(mat)
	return s
func emitter(texture:String,count:int,life:float,velocity:float,spread:float,sz:float,col:Color,delay:float,pos:Vector2,direction:Vector3,gravity:float=40.0)->GPUParticles2D:
	var e=GPUParticles2D.new()
	e.texture=load("res://art/rpg/"+texture+".svg")
	e.amount=count
	e.lifetime=life
	e.one_shot=true
	e.explosiveness=.92
	e.fixed_fps=60
	e.use_fixed_seed=true
	e.seed=seed_value+emitters.size()*71
	e.local_coords=true
	e.speed_scale=0
	e.position=pos
	e.visibility_rect=Rect2(-500,-350,1000,700)
	var p=ParticleProcessMaterial.new()
	p.particle_flag_disable_z=true
	p.direction=direction
	p.spread=spread
	p.emission_shape=ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius=18
	p.initial_velocity_min=velocity*.5
	p.initial_velocity_max=velocity
	p.gravity=Vector3(0,gravity,0)
	p.scale_min=sz*.6
	p.scale_max=sz
	p.angle_min=-90
	p.angle_max=90
	p.angular_velocity_min=-100
	p.angular_velocity_max=100
	var grad=Gradient.new()
	grad.offsets=PackedFloat32Array([0,.08,.55,1])
	grad.colors=PackedColorArray([Color(col,0),Color(col,.85),Color(col.darkened(.1),.6),Color(col.darkened(.55),0)])
	var ramp=GradientTexture1D.new()
	ramp.gradient=grad
	p.color_ramp=ramp
	e.process_material=p
	add_child(e)
	emitters.append(e)
	delays.append(delay)
	return e
func configure(k:int,new_seed:int):
	kind=k
	seed_value=new_seed
	last_time=-1
	for s in cards:s.free()
	for e in emitters:e.free()
	cards.clear();surfaces.clear();emitters.clear();delays.clear()
	var c=Catalog.COLORS[k]
	field_material.set_shader_parameter("kind",k)
	field_material.set_shader_parameter("strike",Catalog.STRIKES[k])
	field_material.set_shader_parameter("tint",c)
	match k:
		0:
			card("fire.svg",Color("ff5c22"));card("fire.svg",Color("ffc34e"))
			for i in range(5):card("butterfly.svg",Color("ffbd50"))
			emitter("butterfly",7,1.1,140,35,.065,c,.34,Vector2(100,-30),Vector3(1,-.7,0),-18)
			emitter("spark",22,.85,200,80,.018,Color("ffb755"),.24,Vector2(80,0),Vector3(1,-.4,0),80)
		1:
			card("eye.svg",c);card("lance.svg",Color("dcbbff"))
			for x in [-245,245]:emitter("lance",9,.52,270,35,.08,c,.28,Vector2(x,-8),Vector3(signf(x),-.4,0),0)
		2:
			card("seal.svg",c)
			for i in range(7):card("petal.svg",c.lerp(Color.WHITE,float(i%3)*.15))
			emitter("petal",18,1.2,110,160,.045,c,.4,Vector2(0,65),Vector3(0,-1,0),70)
			emitter("spark",24,1.6,55,120,.012,Color("dbf6ff"),.6,Vector2(0,-25),Vector3(0,-1,0),35)
		3:
			card("canopy.svg",c);card("seal.svg",Color("9bafff"))
			var drops=emitter("drop",16,1.7,65,40,.045,c,.4,Vector2(0,10),Vector3(0,-1,0),-10)
			(drops.process_material as ParticleProcessMaterial).emission_sphere_radius=95
			emitter("spark",12,1.7,45,100,.018,Color("f8acd9"),.65,Vector2(0,45),Vector3(0,-1,0),-15)
		4:
			for i in range(3):card("wind.svg",c.lerp(Color("d9ffef"),float(i)*.3))
			var e=emitter("petal",18,.65,225,32,.036,c,.24,Vector2(85,-20),Vector3(1,.05,0),-20)
			(e.process_material as ParticleProcessMaterial).emission_sphere_radius=90
		5:
			card("lance.svg",c);card("spark.svg",Color("fff1c2"))
			emitter("lance",13,.55,380,12,.07,c,.19,Vector2(215,-8),Vector3(1,0,0),0)
			emitter("petal",6,.65,100,30,.03,Color("9bdfff"),.22,Vector2(215,-8),Vector3(-1,-.4,0),45)
		6:
			card("gas.svg",c);card("smoke.svg",Color("8e8991"))
			emitter("lance",6,.25,430,18,.055,Color("ffe3aa"),.04,Vector2(-65,0),Vector3(1,0,0),20)
			var e=emitter("smoke",4,.7,45,25,.11,Color("9293a0"),.09,Vector2(-60,0),Vector3(.3,-1,0),-30)
			e.explosiveness=.6
		7:
			var feather="phoenix-feather.png" if ResourceLoader.exists("res://art/rpg/phoenix-feather.png") else "feather.svg"
			for i in range(14):card(feather,Color("ff622b").lerp(Color("ffd66a"),float(i%7)/8))
			var feathers=emitter("feather",19,1.25,210,140,.11,c,.43,Vector2(0,0),Vector3(0,-1,0),75)
			(feathers.process_material as ParticleProcessMaterial).emission_shape=ParticleProcessMaterial.EMISSION_SHAPE_BOX
			(feathers.process_material as ParticleProcessMaterial).emission_box_extents=Vector3(190,45,0)
			emitter("spark",28,1.65,120,165,.016,Color("bc6546"),.6,Vector2(0,30),Vector3(0,-1,0),100)
func shape(i:int,p:Vector2,s:Vector2,angle:float,opacity:float,reveal_value:float,erosion:float,t:float,power:float):
	var c=cards[i]
	c.visible=sprites_on and opacity>.001
	c.position=p;c.scale=s;c.rotation=angle
	c.modulate=Color(1,1,1,clampf(opacity,0,1))
	c.material=surfaces[i] if shaders_on else null
	if not shaders_on:c.modulate=Color(Catalog.COLORS[kind],clampf(opacity,0,1))
	var m=surfaces[i]
	m.set_shader_parameter("age",t)
	m.set_shader_parameter("reveal",reveal_value)
	m.set_shader_parameter("dissolve",erosion)
	m.set_shader_parameter("strength",power)
func sample(age:float,size_value:float,power:float):
	scale=Vector2.ONE*size_value
	var t=age-Catalog.STRIKES[kind]
	var u=maxf(t,0)
	var hit=smoothstep(0,.07,t)
	var fade=1.0-smoothstep(.18,.75,u)
	field.visible=shaders_on
	field_material.set_shader_parameter("age",age)
	field_material.set_shader_parameter("strength",power)
	match kind:
		0:
			for i in range(2):
				var delay=float(i)*.035
				shape(i,Vector2(-40,20),Vector2(1.15,.67-float(i)*.1),-.25+smoothstep(0,.25,t-delay)*.65,hit*fade*(1-float(i)*.25),smoothstep(-.05,.2,t-delay),smoothstep(.15,.8,u)*.8,age,power)
			for i in range(5):
				var b=float(i);var bt=t-.08-b*.028;var bf=smoothstep(0,.13,bt)*(1-smoothstep(.6,1.3,bt))
				shape(i+2,Vector2(-130+b*66+bt*95,-35-sin(b*1.7)*45-bt*50),Vector2(.095*(.65+absf(sin(age*15+b))*.5),.095),sin(b)*.4,bf,1,.05,age,power)
		1:
			var eye=smoothstep(0,.09,age)*(1-smoothstep(.26,.39,age))
			shape(0,Vector2(0,-8),Vector2(.68,lerpf(.28,.015,smoothstep(.18,.29,age))),0,eye,1,0,age,power)
			shape(1,Vector2(0,-8),Vector2(1.35,.16),-.025,hit*(1-smoothstep(.10,.5,u)),smoothstep(-.02,.045,t),smoothstep(.08,.5,u)*.8,age,power)
		2:
			shape(0,Vector2(0,105),Vector2(.8,.23),age*.12,smoothstep(0,.18,age)*(1-smoothstep(1.1,1.9,age)),1,.0,age,power*.65)
			for i in range(7):
				var f=float(i);var g=smoothstep(-.03+f*.015,.27+f*.015,t);var angle=(f-3)*.32
				shape(i+1,Vector2(sin(angle)*72,90-cos(angle)*82*g),Vector2(.17+float(i%2)*.035,(.30+float(i%3)*.09)*g),angle,.9*g*(1-smoothstep(.65,1.7,u)),1,smoothstep(.65,1.7,u)*.85,age,power)
		3:
			var breath=smoothstep(.05,.55,age)*(1-smoothstep(1.6,2.7,age))
			shape(0,Vector2(0,-10-sin(age*3)*6),Vector2(.58,.66)*(1+sin(age*4)*.025),0,breath,1,.02,age,power)
			shape(1,Vector2(0,118),Vector2(.83,.23),-age*.13,breath*.6,1,.02,age,power)
		4:
			for i in range(3):
				var d=float(i)*.035;var sf=smoothstep(-.04,.05,t-d)*(1-smoothstep(.13,.65,t-d))
				shape(i,Vector2(-30+float(i)*10,15+float(i)*13),Vector2(1.25-float(i)*.06,.62-float(i)*.045),-.7+smoothstep(-.04,.22,t-d)*.95,sf*(1-float(i)*.2),smoothstep(-.06,.18,t-d),smoothstep(.12,.65,t-d)*.85,age,power)
		5:
			var extension=smoothstep(-.015,.055,t)
			shape(0,Vector2(-40, -8),Vector2(1.1*extension,.22),0,hit*(1-smoothstep(.06,.42,u)),extension,smoothstep(.04,.48,u)*.8,age,power)
			shape(1,Vector2(215,-8),Vector2(.14,.23)*(1+u*2),.4,hit*(1-smoothstep(.03,.3,u)),1,.0,age,power)
		6:
			shape(0,Vector2(0,0),Vector2(.52,.33)*(1+u*3),0,smoothstep(-.03,.01,t)*(1-smoothstep(.03,.18,u)),1,smoothstep(.02,.22,u)*.7,age,power)
			shape(1,Vector2(-25+u*45,-u*55),Vector2(.14+u*.23,.16+u*.3),u*.4,smoothstep(.04,.1,u)*(1-smoothstep(.3,.8,u))*.3,1,.02,age,power*.5)
		7:
			var opening=smoothstep(-.04,.28,t)
			for i in range(14):
				var side=-1.0 if i<7 else 1.0
				var j=float(i%7);var wingfade=hit*(1-smoothstep(.45,1.6,u))
				var peel=smoothstep(.25+j*.025,1.2+j*.04,u)
				var flap=sin(u*6.0+j*.27)*.08
				var pos=Vector2(side*(30+j*26)*opening+side*peel*(35+j*13),25-j*14*opening-peel*(45+j*9))
				var angle=side*(-.25+j*.16+flap-peel*.55)*opening
				var sx=(.34+j*.018)*side
				shape(i,pos,Vector2(sx,.4-j*.025)*( .4+opening*.6),angle,wingfade,smoothstep(-.08+j*.012,.16+j*.012,t),smoothstep(.25+j*.045,1.6,u)*.9,age,power)
	for i in range(emitters.size()):
		var e=emitters[i];var local_age=age-delays[i]
		e.visible=particles_on and local_age>=0
		if local_age<0:continue
		e.modulate=Color(power,power,power,1)
		if age<last_time or absf(age-last_time)>.09 or last_time<delays[i]:
			e.restart(true);e.request_particles_process(maxf(local_age,.001))
		elif age>last_time:e.request_particles_process(age-last_time)
	last_time=age
