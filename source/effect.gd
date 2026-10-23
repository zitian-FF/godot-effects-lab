extends Node2D

const COLORS = [Color("ff863d"), Color("8db7ff"), Color("83edff"), Color("6bf1bd"), Color("c4adff"), Color("ffc98a"), Color("ffe1a1"), Color("ff6847")]
var kind = 0
var seconds = 0.0
var effect_scale = 1.0
var strength = 1.0
var variation = 1
var show_core = true
var show_particles = true
var show_rings = true
var glow: Texture2D

func _ready():
	var image = Image.create(128, 128, false, Image.FORMAT_RGBA8)
	for y in range(128):
		for x in range(128):
			var r = Vector2(x - 63.5, y - 63.5).length() / 63.5
			image.set_pixel(x, y, Color(1, 1, 1, pow(maxf(0, 1 - r), 3)))
	glow = ImageTexture.create_from_image(image)
	var additive = CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = additive

func random_unit(n: int) -> float:
	return fposmod(sin(float(n * 127 + variation * 311)) * 43758.5453, 1.0)

func halo(p: Vector2, radius: float, color: Color, alpha: float):
	if radius > 0 and alpha > 0:
		draw_texture_rect(glow, Rect2(p - Vector2.ONE * radius, Vector2.ONE * radius * 2), false, Color(color, alpha * strength))

func ring(radius: float, color: Color, alpha: float, width: float = 2.0):
	if radius > 0 and alpha > 0:
		draw_arc(Vector2.ZERO, radius, 0, TAU, 100, Color(color, alpha), width, true)

func _draw():
	if not glow or seconds < 0 or seconds > 2.0:
		return
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE * effect_scale)
	var t = seconds
	var c = COLORS[kind]
	var fade = clampf(1.0 - t / 1.6, 0, 1)
	if show_core:
		halo(Vector2.ZERO, 150, c, pow(fade, 3) * 0.9)
	match kind:
		0: _fire(t, c)
		1: _electric(t, c)
		2: _ice(t, c)
		3: _healing(t, c)
		4: _slash(t, c)
		5: _stab(t, c)
		6: _muzzle(t, c)
		7: _explosion(t, c)
	if show_particles:
		var count = 28 if kind != 7 else 54
		for i in range(count):
			var age = t - random_unit(i + 500) * 0.16
			var life = 0.32 + random_unit(i + 600) * 0.8
			if age < 0 or age > life:
				continue
			var angle = random_unit(i) * TAU
			var direction = Vector2.from_angle(angle)
			var velocity = direction * (85 + random_unit(i + 100) * 220)
			if kind == 3:
				velocity = Vector2((random_unit(i) - 0.5) * 100, -85 - random_unit(i + 1) * 90)
			var p = velocity * age * (1 - age * 0.25)
			if kind in [0, 7]:
				p.y += age * age * 95
			var a = pow(1 - age / life, 1.5)
			halo(p, 8 + random_unit(i + 200) * 8, c, a)
			draw_line(p, p - velocity.normalized() * (4 + a * 13), Color(c, a), 1.5, true)
	if show_rings and kind in [0, 1, 2, 3, 7]:
		var duration = 0.7 if kind != 3 else 1.6
		var u = clampf(t / duration, 0, 1)
		ring(22 + (1 - pow(1 - u, 3)) * 160, c, pow(1 - u, 2) * 0.75, 2)

func _fire(t: float, c: Color):
	if not show_core:
		return
	for i in range(13):
		var age = t - random_unit(i + 50) * 0.12
		var u = clampf(age / (0.65 + random_unit(i) * 0.45), 0, 1)
		if age < 0 or u >= 1:
			continue
		var a = random_unit(i + 10) * TAU
		var p = Vector2.from_angle(a) * sin(u * PI * 0.7) * 70
		p.y -= u * 85
		halo(p, (22 + sin(u * PI) * 65) * (1 - u * 0.5), c, (1 - u) * 1.7)
		var flame = PackedVector2Array([p + Vector2(-14, 12), p + Vector2(-21, -7), p + Vector2(-7, -23 - u * 40), p + Vector2(1, -11), p + Vector2(14, -30 - u * 30), p + Vector2(20, 8)])
		draw_colored_polygon(flame, Color(c.lerp(Color("ffe8ac"), 1 - u), pow(1 - u, 2) * 0.85))

func _electric(t: float, c: Color):
	if not show_core or t > 0.85:
		return
	var flicker = int(t * 24)
	for branch in range(7):
		var points = PackedVector2Array([Vector2.ZERO])
		var direction = Vector2.from_angle(branch * TAU / 7 + random_unit(flicker + 80) * 0.3)
		for j in range(1, 7):
			var p = direction * j * 26 + direction.orthogonal() * (random_unit(branch * 21 + j + flicker * 77) - 0.5) * 45
			points.append(p)
		var alpha = pow(1 - t / 0.85, 0.6)
		draw_polyline(points, Color(c, alpha * 0.16), 13, true)
		draw_polyline(points, Color(c, alpha * 0.6), 5, true)
		draw_polyline(points, Color("eef7ff", alpha), 1.6, true)
		var last = points[4]
		draw_line(last, last + direction.rotated(0.65) * 46, Color(c, alpha * 0.6), 1.5, true)

func _ice(t: float, c: Color):
	if not show_core:
		return
	for i in range(9):
		var age = t - i * 0.025
		if age < 0:
			continue
		var grow = clampf(age / 0.19, 0, 1)
		var alpha = 1 - smoothstep(0.65, 1.6, age)
		var a = TAU * i / 9 + 0.1
		var d = Vector2.from_angle(a)
		var p = d * (16 + grow * 27)
		var side = d.orthogonal() * (12 + random_unit(i) * 9) * grow
		var tip = p + d * (53 + random_unit(i + 5) * 58) * grow
		var points = PackedVector2Array([p - side, tip, p + side, p - d * 14])
		draw_colored_polygon(points, Color(c, alpha * 0.5))
		draw_polyline(PackedVector2Array([p - side, tip, p + side]), Color("d8fcff", alpha), 2, true)
		draw_line(p, tip, Color("f0ffff", alpha * 0.8), 1.2, true)
		halo(tip, 24, c, alpha * 0.5)

func _healing(t: float, c: Color):
	if not show_core:
		return
	var alpha = sin(clampf(t / 1.8, 0, 1) * PI)
	for i in range(3):
		ring(45 + i * 28 + sin(t * 4 + i) * 5, c, alpha * 0.5, 1.5)
	for i in range(12):
		var a = i * TAU / 12 + t * 0.7
		var p = Vector2(cos(a) * 100, sin(a) * 35 - fposmod(t * 60 + i * 13, 140) + 50)
		var size = 3 + random_unit(i) * 4
		halo(p, 26, c, alpha * 0.8)
		draw_line(p - Vector2(size, 0), p + Vector2(size, 0), Color("cffff0", alpha), 2.5, true)
		draw_line(p - Vector2(0, size), p + Vector2(0, size), Color("cffff0", alpha), 2.5, true)

func _slash(t: float, c: Color):
	if not show_core or t > 0.7:
		return
	var u = clampf(t / 0.23, 0, 1)
	var alpha = 1 - smoothstep(0.18, 0.7, t)
	for layer in range(3):
		var points = PackedVector2Array()
		var start = -2.7
		var sweep = 3.5 * u
		for i in range(49):
			var f = i / 48.0
			var a = start + sweep * f
			var radius = 133 + sin(f * PI) * (15 - layer * 4)
			points.append(Vector2(cos(a) * radius, sin(a) * radius * 0.58).rotated(-0.45))
		for i in range(48, -1, -1):
			var f = i / 48.0
			var a = start + sweep * f
			var radius = 133 - sin(f * PI) * (30 - layer * 10)
			points.append(Vector2(cos(a) * radius, sin(a) * radius * 0.58).rotated(-0.45))
		draw_colored_polygon(points, Color(c.lerp(Color.WHITE, layer / 2.0), alpha * (0.4 + layer * 0.25)))

func _stab(t: float, c: Color):
	if not show_core or t > 0.55:
		return
	var alpha = 1 - smoothstep(0.09, 0.55, t)
	var reach = (1 - pow(1 - clampf(t / 0.12, 0, 1), 3)) * 170
	var points = PackedVector2Array([Vector2(-180, 0), Vector2(reach - 50, -14 * alpha), Vector2(reach, 0), Vector2(reach - 50, 14 * alpha)])
	draw_colored_polygon(points, Color(c, alpha * 0.75))
	draw_line(Vector2(-155, 0), Vector2(reach, 0), Color("fff5dd", alpha), 3, true)
	halo(Vector2(reach, 0), 35, c, alpha)
	for j in [-1, 1]:
		draw_line(Vector2(-80, j * 26), Vector2(95, j * 8), Color(c, alpha * 0.45), 1.5, true)

func _muzzle(t: float, c: Color):
	if not show_core or t > 0.24:
		return
	var alpha = 1 - t / 0.24
	var points = PackedVector2Array()
	for i in range(16):
		var angle = TAU * i / 16
		var radius = (85 + random_unit(i) * 40) if i % 2 == 0 else 18.0
		points.append(Vector2(cos(angle) * radius * 1.6, sin(angle) * radius * 0.6) * (0.6 + alpha * 0.4))
	draw_colored_polygon(points, Color(c, alpha))
	halo(Vector2(20, 0), 140, c, alpha * 2)
	draw_circle(Vector2.ZERO, 13 * alpha, Color("fffbee", alpha))

func _explosion(t: float, c: Color):
	if not show_core:
		return
	for i in range(18):
		var age = t - random_unit(i) * 0.07
		if age < 0:
			continue
		var u = clampf(age / 1.2, 0, 1)
		var d = Vector2.from_angle(random_unit(i + 90) * TAU)
		var p = d * (1 - pow(1 - u, 3)) * (45 + random_unit(i + 100) * 70)
		p.y -= u * u * 50
		var radius = (18 + sin(u * PI) * 38) * (1 - u * 0.5)
		halo(p, radius * 2, c, pow(1 - u, 2) * 1.5)
		draw_circle(p, radius * 0.5, Color(c.lerp(Color("fff1bd"), pow(1 - u, 4)), pow(1 - u, 2) * 0.7))
	if t < 0.16:
		halo(Vector2.ZERO, 210 * (1 - t / 0.16), Color("fff6df"), 3)
