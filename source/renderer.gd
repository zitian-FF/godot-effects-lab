extends Node2D

const Catalog = preload("res://catalog.gd")
var kind = 0
var method = 0
var mutation = 0
var seed_value = 17
var last_time = -1.0
var sprite_root: Node2D
var shader_rect: ColorRect
var shader_material: ShaderMaterial
var emitters: Array[GPUParticles2D] = []
var cards: Array[Sprite2D] = []
var core_visible = true
var details_visible = true

func _ready():
	sprite_root = Node2D.new()
	add_child(sprite_root)
	shader_rect = ColorRect.new()
	shader_rect.position = Vector2(-320, -270)
	shader_rect.size = Vector2(640, 540)
	shader_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shader_material = ShaderMaterial.new()
	shader_material.shader = preload("res://lab_effect.gdshader")
	shader_rect.material = shader_material
	add_child(shader_rect)

func configure(k: int, m: int, v: int, new_seed: int):
	kind = k
	method = m
	mutation = v
	seed_value = new_seed
	last_time = -1.0
	for card in cards:
		card.free()
	cards.clear()
	for emitter in emitters:
		emitter.free()
	emitters.clear()
	sprite_root.visible = m == 0
	shader_rect.visible = m == 2
	if m == 0:
		_build_sprites()
	elif m == 1:
		_build_particles()
	else:
		shader_material.set_shader_parameter("category", k)
		shader_material.set_shader_parameter("mutation", v)
		shader_material.set_shader_parameter("seed_value", float(new_seed))
		shader_material.set_shader_parameter("tint", Catalog.COLORS[k])

func _build_sprites():
	var card = Sprite2D.new()
	if mutation == 0 and Catalog.ANIMATED[kind]:
		var filename = "res://art/v2/" + Catalog.KEYS[kind] + "-wan-atlas.png"
		if kind == 7:
			filename = "res://art/wan-impact-atlas.png"
		card.texture = load(filename)
		card.hframes = 7
		card.vframes = 7
		var matte = ShaderMaterial.new()
		matte.shader = preload("res://raster_matte.gdshader")
		matte.set_shader_parameter("black_floor", 0.13 if kind == 2 else 0.01)
		card.material = matte
	else:
		card.texture = load("res://art/v2/" + (Catalog.BASE_TEXTURES[kind] if mutation == 0 else Catalog.TEXTURES[kind][mutation - 1]))
	sprite_root.add_child(card)
	cards.append(card)
	if not (mutation == 0 and Catalog.ANIMATED[kind]) and kind in [2, 3, 4]:
		var count = 6 if kind == 2 else 2
		for i in range(count):
			var extra = Sprite2D.new()
			extra.texture = card.texture
			sprite_root.add_child(extra)
			cards.append(extra)

func _ramp(color: Color, smoke: bool = false) -> GradientTexture1D:
	var gradient = Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.12, 0.55, 1.0])
	gradient.colors = PackedColorArray([Color(color, 0), Color(color, 0.65 if smoke else 0.85), Color(color.darkened(0.25), 0.35), Color(color.darkened(0.45), 0)])
	var texture = GradientTexture1D.new()
	texture.gradient = gradient
	return texture

func _emitter(texture_name: String, amount: int, life: float, velocity: float, spread: float, particle_scale: float, color: Color, smoke: bool = false) -> GPUParticles2D:
	var emitter = GPUParticles2D.new()
	emitter.amount = amount
	emitter.lifetime = life
	emitter.one_shot = true
	emitter.explosiveness = 0.7
	emitter.fixed_fps = 60
	emitter.use_fixed_seed = true
	emitter.seed = seed_value + emitters.size() * 113
	emitter.local_coords = true
	emitter.speed_scale = 0
	emitter.visibility_rect = Rect2(-450, -350, 900, 700)
	emitter.texture = load("res://art/v2/" + texture_name)
	var process = ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 12
	process.particle_flag_disable_z = true
	process.direction = Vector3(0, -1, 0)
	process.spread = spread
	process.gravity = Vector3(0, -15 if smoke else 65, 0)
	process.initial_velocity_min = velocity * 0.45
	process.initial_velocity_max = velocity
	process.scale_min = particle_scale * 0.55
	process.scale_max = particle_scale
	process.angle_min = -30
	process.angle_max = 30
	process.angular_velocity_min = -45
	process.angular_velocity_max = 45
	process.color_ramp = _ramp(color, smoke)
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0.75))
	curve.add_point(Vector2(0.05, 1.0))
	curve.add_point(Vector2(1, 1.4 if smoke else 0.08))
	var scale_texture = CurveTexture.new()
	scale_texture.curve = curve
	process.scale_curve = scale_texture
	emitter.process_material = process
	if not smoke:
		var material = CanvasItemMaterial.new()
		material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		emitter.material = material
	add_child(emitter)
	emitters.append(emitter)
	return emitter

func _build_particles():
	var color = Catalog.COLORS[kind]
	var texture = Catalog.PARTICLE_TEXTURES[kind][mutation]
	var amount = 35
	var life = 1.3
	var velocity = 145.0
	var spread = 35.0
	var particle_scale = 0.28
	if kind in [1, 2, 4, 5, 6]:
		particle_scale = 0.65
		velocity = 330
		amount = 22
	if kind == 0:
		particle_scale = 0.65 if mutation == 0 else 0.45
		amount = 6 if mutation == 0 else 38
		color = Color.WHITE if mutation == 0 else (Color("7fc7ff") if mutation == 2 else color)
	if kind == 3:
		spread = 50
		velocity = 115
		particle_scale = 0.55
		life = 1.8
	if kind == 7:
		spread = 180
		velocity = 180
		particle_scale = 0.9
		amount = 18
	var main = _emitter(texture, amount, life, velocity, spread, particle_scale, color, kind == 7 and mutation == 1)
	var process = main.process_material as ParticleProcessMaterial
	if (kind == 0 and mutation == 0) or kind == 2:
		main.material = null
	if kind == 3:
		process.emission_sphere_radius = 70
	if mutation == 1:
		process.emission_sphere_radius = 55
		main.explosiveness = 0.2
	if mutation == 2:
		main.explosiveness = 0.05
		process.spread = 8
		process.initial_velocity_max *= 1.3
	if kind in [1, 2]:
		process.spread = 180 if mutation != 2 else 12
		process.gravity = Vector3.ZERO
	if kind in [4, 5, 6]:
		process.direction = Vector3(1, 0, 0)
		process.gravity = Vector3.ZERO
		process.spread = 12 if kind != 4 else 40
		main.lifetime = 0.5 if kind == 6 else 0.8
		main.explosiveness = 0.9 if mutation == 0 else 0.4
		process.angle_min = 90
		process.angle_max = 90
		if kind == 5:
			process.initial_velocity_min = 350
			process.initial_velocity_max = 650
			process.scale_min = 0.18
			process.scale_max = 0.35
	if kind == 2:
		process.angle_min = -180
		process.angle_max = 180
	if kind in [0, 7]:
		var smoke = _emitter("smoke_08.png", 12, 1.9, 60, 65, 0.25, Color("71645b"), true)
		smoke.position.y = -10
		var sparks = _emitter("spark_05.png", 35, 1.1, 220, 155, 0.045, Color("ffb25c"))
		sparks.explosiveness = 0.95

func sample(age: float, size_value: float, intensity: float):
	scale = Vector2.ONE * size_value * 0.65
	shader_rect.visible = method == 2 and core_visible
	shader_material.set_shader_parameter("clock", age)
	shader_material.set_shader_parameter("strength", intensity)
	shader_material.set_shader_parameter("detail_enabled", details_visible)
	if method == 0:
		_sample_sprites(age, intensity)
	elif method == 1:
		var seek = age < last_time or absf(age - last_time) > 0.09 or last_time < 0
		for i in range(emitters.size()):
			var emitter = emitters[i]
			emitter.visible = core_visible if i == 0 else details_visible
			emitter.modulate = Color(intensity, intensity, intensity, 1)
			if seek:
				emitter.restart(true)
				emitter.request_particles_process(maxf(age, 0.001))
			elif age > last_time:
				emitter.request_particles_process(age - last_time)
	last_time = age

func _sample_sprites(age: float, intensity: float):
	var duration = Catalog.DURATIONS[kind]
	var u = clampf(age / duration, 0, 1)
	var envelope = smoothstep(0.0, 0.065, age) * (1 - smoothstep(0.45, 1.0, u))
	for i in range(cards.size()):
		var card = cards[i]
		card.visible = core_visible and age < duration
		card.position = Vector2.ZERO
		card.rotation = 0
		var is_clip = mutation == 0 and Catalog.ANIMATED[kind]
		var base = 1.5 if is_clip else 1.6
		card.scale = Vector2.ONE * base
		card.modulate = Color(intensity, intensity, intensity, envelope)
		if is_clip:
			card.frame = clampi(int(u * 49), 0, 48)
			card.modulate = Color(intensity * 0.9, intensity * 0.9, intensity * 0.9, envelope)
			(card.material as ShaderMaterial).set_shader_parameter("exposure", intensity * 0.9)
			(card.material as ShaderMaterial).set_shader_parameter("opacity", envelope)
			if kind == 2:
				card.position.y = -55
			continue
		card.modulate = Color(Catalog.COLORS[kind] * intensity, envelope)
		var growth = 0.25 + (1 - pow(1 - clampf(u * 3, 0, 1), 3)) * 0.85
		card.scale = Vector2.ONE * growth * 1.6
		match kind:
			0:
				card.scale *= Vector2(0.8 + sin(age * 5) * 0.06, 1.2)
				card.position.y = -12 - age * 20
				if mutation == 0:
					card.scale *= 0.36
					card.modulate = Color(intensity, intensity, intensity, envelope * 0.9)
			1:
				card.scale *= 1.1
				card.rotation = floor(age * 20) * 0.35
			2:
				var angle = i * 2.4
				card.position = Vector2.from_angle(angle) * (25 + i * 9) * growth
				card.rotation = angle + 0.6
				card.scale *= Vector2(0.35, 0.6 + (i % 3) * 0.12)
			3:
				card.scale *= 0.85 - i * 0.17
				card.rotation = age * (0.5 + i * 0.4) * (-1 if i % 2 else 1)
			4:
				card.rotation = -0.7 + smoothstep(0, 0.3, age) * 0.9 + i * 0.25
				card.scale *= 1.1 - i * 0.25
				card.position.y = i * 24
			5:
				card.rotation = PI / 2
				card.scale *= Vector2(0.45, 1.5)
				card.position.x = -35 + smoothstep(0, 0.14, age) * 75
			6:
				card.rotation = PI / 2
				card.scale *= Vector2(0.65, 0.95)
				card.modulate.a = 1 - smoothstep(0.04, 0.28, age)
			7:
				card.scale *= 1.2
				card.rotation = 0.2 * age
				if mutation == 1:
					card.modulate = Color(0.5, 0.39, 0.28, envelope)
