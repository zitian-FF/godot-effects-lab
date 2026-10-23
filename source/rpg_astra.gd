extends "res://rpg_renderer.gd"
const ASTRA_SURFACE=preload("res://astra_surface.gdshader")
const ASTRA_FIELD=preload("res://astra_field.gdshader")
func configure(_k:int,new_seed:int):
	kind=1;seed_value=new_seed;last_time=-1
	for s in cards:s.free()
	for e in emitters:e.free()
	cards.clear();surfaces.clear();emitters.clear();delays.clear()
	field_material.shader=ASTRA_FIELD
	field_material.set_shader_parameter("seed_value",float(seed_value))
	card("astra-eye.svg",Color("a477ff"))
	card("astra-iris.svg",Color("bca3ff"))
	card("astra-cut.svg",Color("b08bff"))
	card("astra-cut.svg",Color("7edaff"))
	for i in range(surfaces.size()):
		surfaces[i].shader=ASTRA_SURFACE
		surfaces[i].set_shader_parameter("tint",Color("9362ff") if i<2 else Color("bb8fff"))
		surfaces[i].set_shader_parameter("role",float(i))
	# Contact sprays live on the whole incision, not just its two endpoints.
	for side in [-1.0,1.0]:
		var e=emitter("astra-shard",21,.55,360,58,.22,Color("d5aaff"),.285,Vector2(0,-8),Vector3(.35,side,0),side*15.)
		e.rotation=-.13
		var p=e.process_material as ParticleProcessMaterial
		p.emission_shape=ParticleProcessMaterial.EMISSION_SHAPE_BOX
		p.emission_box_extents=Vector3(305,4,0)
		p.particle_flag_align_y=true
		p.angular_velocity_min=0;p.angular_velocity_max=0
		p.damping_min=110;p.damping_max=170
		p.scale_min=.09;p.scale_max=.26
		var glow_material=CanvasItemMaterial.new();glow_material.blend_mode=CanvasItemMaterial.BLEND_MODE_ADD;e.material=glow_material
	var embers=emitter("astra-shard",24,.78,90,150,.06,Color("a87aff"),.38,Vector2(25,-8),Vector3(.5,-1,0),18)
	var ep=embers.process_material as ParticleProcessMaterial
	ep.emission_shape=ParticleProcessMaterial.EMISSION_SHAPE_BOX
	ep.emission_box_extents=Vector3(285,28,0)
	ep.angular_velocity_min=-130;ep.angular_velocity_max=130
	ep.damping_min=25;ep.damping_max=55
	var curve=Curve.new();curve.add_point(Vector2(0,.2));curve.add_point(Vector2(.12,1));curve.add_point(Vector2(.7,.5));curve.add_point(Vector2(1,0))
	var tex=CurveTexture.new();tex.curve=curve
	for e in emitters:(e.process_material as ParticleProcessMaterial).scale_curve=tex
func sample(age:float,size_value:float,power:float):
	scale=Vector2.ONE*size_value
	var t=age-.26;var u=maxf(t,0.)
	var opening=smoothstep(.005,.105,age)
	var close=smoothstep(.18,.32,age)
	var eye=opening*(1-smoothstep(.27,.355,age))
	field.visible=shaders_on
	field_material.set_shader_parameter("age",age)
	field_material.set_shader_parameter("strength",power)
	shape(0,Vector2(0,-8),Vector2(.76+close*.52,.73*(1-close)+.16),-.13*close,eye,1,smoothstep(.265,.37,age)*.75,age,power)
	shape(1,Vector2(0,-8),Vector2(.76-close*.16,.76-close*.45),-.36+age*3.4,eye*(1-smoothstep(.285,.34,age)),1,smoothstep(.28,.35,age)*.65,age,power)
	var strike=smoothstep(-.005,.02,t)*(1-smoothstep(.055,.23,u))
	shape(2,Vector2(0,-8),Vector2(.88,.62+u*.4),-.13,strike,smoothstep(-.008,.025,t),smoothstep(.03,.25,u)*.8,age,power)
	var echo=smoothstep(.035,.06,t)*(1-smoothstep(.11,.32,u))
	shape(3,Vector2(8,5+u*27),Vector2(.77,.22),-.13-.035*u,echo*.20,1,smoothstep(.07,.35,u)*.9,age,power)
	for i in range(emitters.size()):
		var e=emitters[i];var local_age=age-delays[i]
		e.visible=particles_on and local_age>=0
		if local_age<0:continue
		e.modulate=Color(power,power,power,1)
		if age<last_time or absf(age-last_time)>.09 or last_time<delays[i]:
			e.restart(true);e.request_particles_process(maxf(local_age,.001))
		elif age>last_time:e.request_particles_process(age-last_time)
	last_time=age
