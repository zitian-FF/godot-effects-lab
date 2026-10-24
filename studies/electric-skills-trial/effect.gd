extends Node2D
# Asset-space geometry and planar UVs follow the dedicated design handoff.
const MASK=preload("res://art/designed/textures/crescent_mask.png")
const EDGE=preload("res://art/designed/textures/crescent_edge.png")
const NEEDLE=preload("res://art/designed/textures/spark_needle.png")
const CHIP=preload("res://art/designed/textures/spark_chip.png")
const MATERIAL=preload("res://slash.gdshader")
const NEEDLE_MATERIAL=preload("res://needle.gdshader")
const SOURCE_PIVOT=Vector2(512,652)
const SOURCE_SIZE=Vector2(1024,640)
const HEAD_ANGLE=-26.0
const HEAD_RADIUS=520.0
var guide:Node2D
var pass_index=5
var distortion_enabled=true
var surface:MeshInstance2D
var mat:ShaderMaterial
var emitters:Array[GPUParticles2D]=[]
var delays=[.30,.315]
var last_age=-1.0
var live_age=0.0

func _ready():
	surface=MeshInstance2D.new();surface.texture=MASK
	surface.mesh=make_support();mat=ShaderMaterial.new();mat.shader=MATERIAL
	mat.set_shader_parameter("edge_tex",EDGE);surface.material=mat;add_child(surface)
	# Emitter roles follow the two designed silhouettes.
	burst(NEEDLE,7,.20,170,310,.10,.18,Color("ede1ff"),34,600,false)
	burst(CHIP,4,.33,85,150,.10,.16,Color("ad91ed"),72,250,true)

func make_support()->ArrayMesh:
	var vertices=PackedVector3Array();var uv=PackedVector2Array();var indices=PackedInt32Array()
	for i in range(49):
		var a=deg_to_rad(lerpf(-158.,-22.,float(i)/48.))
		for radius in [378.,544.]:
			var p=Vector2(cos(a),sin(a))*radius
			vertices.append(Vector3(p.x,p.y,0));uv.append((p+SOURCE_PIVOT)/SOURCE_SIZE)
		if i<48:
			var k=i*2;indices.append_array(PackedInt32Array([k,k+1,k+2,k+1,k+3,k+2]))
	var arrays=[];arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_TEX_UV]=uv;arrays[Mesh.ARRAY_INDEX]=indices
	var mesh=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	return mesh

func burst(texture:Texture2D,count:int,life:float,vmin:float,vmax:float,smin:float,smax:float,tint:Color,spread_:float,drag:float,tumble:bool):
	var e=GPUParticles2D.new();e.emitting=false;e.amount=count;e.lifetime=life;e.one_shot=true
	e.explosiveness=1.;e.local_coords=false;e.speed_scale=0;e.fixed_fps=60;e.fract_delta=true
	e.use_fixed_seed=true;e.seed=421+emitters.size();e.texture=texture
	e.visibility_rect=Rect2(-280,-200,560,400)
	if tumble:
		var blend=CanvasItemMaterial.new();blend.blend_mode=CanvasItemMaterial.BLEND_MODE_ADD;e.material=blend
	else:
		var shader_material=ShaderMaterial.new();shader_material.shader=NEEDLE_MATERIAL;e.material=shader_material
	var p=ParticleProcessMaterial.new();p.direction=Vector3(.85,-.35,0);p.spread=spread_
	p.initial_velocity_min=vmin;p.initial_velocity_max=vmax;p.damping_min=drag*.65;p.damping_max=drag
	p.gravity=Vector3(0,90 if tumble else 20,0)
	p.scale_min=smin;p.scale_max=smax;p.particle_flag_align_y=not tumble
	if tumble:p.angle_min=-80;p.angle_max=80;p.angular_velocity_min=-180;p.angular_velocity_max=180
	var gradient=Gradient.new();gradient.set_color(0,tint);gradient.set_color(1,Color(tint,0));gradient.add_point(.3,Color(tint,.85));gradient.add_point(.7,Color(tint,.25))
	var ramp=GradientTexture1D.new();ramp.gradient=gradient;p.color_ramp=ramp
	var curve=Curve.new();curve.add_point(Vector2(0,.8));curve.add_point(Vector2(.1,1));curve.add_point(Vector2(1,0))
	var curve_tex=CurveTexture.new();curve_tex.curve=curve;p.scale_curve=curve_tex
	e.process_material=p;add_child(e);emitters.append(e)

func sample(t:float,on:bool):
	live_age=t
	var slash_on=on and pass_index in [1,2,5]
	surface.visible=slash_on and t>=.19 and t<.46
	var hold=minf(t,.34)
	surface.position=guide.hand(hold)
	mat.set_shader_parameter("heading",guide.angle(hold)-deg_to_rad(HEAD_ANGLE))
	mat.set_shader_parameter("radial_scale",guide.REACH/HEAD_RADIUS)
	mat.set_shader_parameter("age",t)
	mat.set_shader_parameter("reveal",smoothstep(.185,.265,t))
	mat.set_shader_parameter("erosion",smoothstep(.335,.45,t)*1.12)
	mat.set_shader_parameter("raw_mask",pass_index==1)
	mat.set_shader_parameter("distortion",4.0 if distortion_enabled and pass_index in [2,5] else 0.)
	surface.modulate=Color(1,1,1,1.-smoothstep(.34,.46,t))
	for i in range(emitters.size()):
		var e=emitters[i];var local_age=t-delays[i]
		e.visible=on and local_age>=0 and (pass_index==5 or pass_index==i+3)
		e.position=Vector2(646,438)
		if local_age<0:continue
		if last_age<delays[i] or t<last_age or absf(t-last_age)>.055:
			e.restart(true);e.request_particles_process(maxf(local_age,.001))
		elif t>last_age:e.request_particles_process(t-last_age)
	last_age=t
