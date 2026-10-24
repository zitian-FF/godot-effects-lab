extends Node2D
const BRUSH=preload("res://art/brush.png")
const SHARD=preload("res://art/shard.svg")
const FLASH=preload("res://art/contact.svg")
const SURFACE=preload("res://slash.gdshader")
const FLASH_MATERIAL=preload("res://contact.gdshader")
var guide:Node2D
var pass_index=3
var strip:MeshInstance2D
var mat:ShaderMaterial
var flash:Sprite2D
var flash_mat:ShaderMaterial
var emitters:Array[GPUParticles2D]=[]
var delays=[.30,.325]
var last_age=-1.0
var live_age=0.0
var enabled=true
func _ready():
	strip=MeshInstance2D.new();strip.texture=BRUSH
	mat=ShaderMaterial.new();mat.shader=SURFACE;strip.material=mat;add_child(strip)
	flash=Sprite2D.new();flash.texture=FLASH
	flash_mat=ShaderMaterial.new();flash_mat.shader=FLASH_MATERIAL;flash.material=flash_mat;flash.z_index=2;add_child(flash)
	burst(18,.29,240,410,.08,.22,Color("d9b9ff"),55,630)
	burst(12,.50,70,140,.04,.10,Color("8e71ff"),160,180)
func burst(count:int,lifetime_:float,vmin:float,vmax:float,smin:float,smax:float,color:Color,spread_:float,drag:float):
	var e=GPUParticles2D.new();e.emitting=false;e.amount=count;e.lifetime=lifetime_;e.one_shot=true
	e.explosiveness=1;e.local_coords=false;e.speed_scale=0;e.fixed_fps=60;e.fract_delta=true
	e.use_fixed_seed=true;e.seed=1701+emitters.size();e.texture=SHARD
	e.visibility_rect=Rect2(-400,-250,800,500)
	var blend=CanvasItemMaterial.new();blend.blend_mode=CanvasItemMaterial.BLEND_MODE_ADD;e.material=blend
	var p=ParticleProcessMaterial.new();p.direction=Vector3(.65,-.35,0);p.spread=spread_;p.gravity=Vector3(0,55,0)
	p.initial_velocity_min=vmin;p.initial_velocity_max=vmax;p.damping_min=drag*.7;p.damping_max=drag
	p.scale_min=smin;p.scale_max=smax;p.particle_flag_align_y=true
	var gradient=Gradient.new();gradient.set_color(0,Color("fcf4ff"));gradient.set_color(1,Color(color,0));gradient.add_point(.20,color);gradient.add_point(.65,Color(color,.38))
	var ramp=GradientTexture1D.new();ramp.gradient=gradient;p.color_ramp=ramp
	var curve=Curve.new();curve.add_point(Vector2(0,.30));curve.add_point(Vector2(.08,1));curve.add_point(Vector2(.6,.5));curve.add_point(Vector2(1,0))
	var scale_curve=CurveTexture.new();scale_curve.curve=curve;p.scale_curve=scale_curve
	e.process_material=p;add_child(e);emitters.append(e)
func sample(t:float,on:bool):
	live_age=t;enabled=on
	var body_on=on and pass_index!=4 and pass_index!=5
	strip.visible=body_on and t>=.19 and t<.49
	mat.set_shader_parameter("age",t)
	mat.set_shader_parameter("erosion",smoothstep(.30,.49,t)*1.2)
	mat.set_shader_parameter("raw_mask",pass_index==0)
	if strip.visible:build_strip(t)
	var impact_age=t-.30
	flash.visible=on and (pass_index>=2 and pass_index!=4) and impact_age>=0 and impact_age<.10
	flash.position=Vector2(646,438)
	flash.rotation=-.27+impact_age*.6
	flash.scale=Vector2(.16+maxf(impact_age,0)*1.1,.42+maxf(impact_age,0)*1.8)
	flash_mat.set_shader_parameter("life",maxf(impact_age,0))
	for i in range(emitters.size()):
		var e=emitters[i];var local_age=t-delays[i]
		e.visible=on and (pass_index==3 or pass_index==4) and local_age>=0
		e.position=Vector2(646,438)
		if local_age<0:continue
		if last_age<delays[i] or t<last_age or absf(t-last_age)>.055:
			e.restart(true);e.request_particles_process(maxf(local_age,.001))
		elif t>last_age:e.request_particles_process(t-last_age)
	last_age=t;queue_redraw()
func build_strip(t:float):
	var time=minf(t,.34)
	var head=guide.angle(time)
	var tail=guide.angle(maxf(.18,time-.075))
	var collapse=smoothstep(.34,.48,t)
	tail=lerpf(tail,head-.035,collapse)
	var center=guide.hand(time)
	var vertices=PackedVector3Array();var uvs=PackedVector2Array();var indices=PackedInt32Array()
	for i in range(49):
		var u=float(i)/48.;var a=lerpf(tail,head,u)
		# Mask alpha supplies taper. The two radii map the bitmap onto the moving blade arc.
		var width=(145.+sin(u*PI)*42.)*(1.-collapse*.65)
		for j in range(2):
			var pos=center+guide.orbit(a,238.+(float(j)-.5)*width)
			vertices.append(Vector3(pos.x,pos.y,0));uvs.append(Vector2(u,float(j)))
		if i<48:
			var k=i*2
			indices.append_array(PackedInt32Array([k,k+1,k+2,k+1,k+3,k+2]))
	var arrays=[];arrays.resize(Mesh.ARRAY_MAX);arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_TEX_UV]=uvs;arrays[Mesh.ARRAY_INDEX]=indices
	var mesh=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays);strip.mesh=mesh
	strip.modulate=Color(1,1,1,1.-smoothstep(.34,.49,t))
func bolt(points:PackedVector2Array,alpha:float,width:float=1.4):
	draw_polyline(points,Color(.30,.08,1.,alpha*.10),width+10,true)
	draw_polyline(points,Color(.59,.20,1.,alpha*.32),width+4,true)
	draw_polyline(points,Color(.86,.72,1.,alpha),width,true)
func _draw():
	if not enabled or pass_index<2 or pass_index==4:return
	var t=live_age
	if t<.245 or t>.58:return
	# A few art-directed, unequal paths; no repeated zigzag row along a beam.
	var arc_alpha=smoothstep(.245,.275,t)*(1.-smoothstep(.33,.46,t))
	var h=guide.hand(minf(t,.34));var a=guide.angle(minf(t,.34))
	var arc=PackedVector2Array()
	for i in range(17):
		var u=float(i)/16.;var jag=sin(float(i)*5.1)*sin(u*PI)*8.
		arc.append(h+guide.orbit(a-.93+u*.93,247.+jag))
	bolt(arc,arc_alpha*.9)
	var contact=t-.30
	if contact<0:return
	var paths=[PackedVector2Array([Vector2(646,438),Vector2(679,414),Vector2(675,400),Vector2(711,388),Vector2(705,365)]),PackedVector2Array([Vector2(646,438),Vector2(675,457),Vector2(665,470),Vector2(689,493)]),PackedVector2Array([Vector2(646,438),Vector2(613,421),Vector2(619,411),Vector2(585,397)])]
	for i in range(paths.size()):
		var start=float(i)*.016
		var alpha=smoothstep(start,start+.012,contact)*(1.-smoothstep(start+.055,start+.14,contact))
		bolt(paths[i],alpha,1.6 if i==0 else 1.)
		if i==0 and alpha>.01:bolt(PackedVector2Array([Vector2(675,400),Vector2(660,386),Vector2(672,374)]),alpha*.55,.8)
