extends Node2D
# Motion and silhouette only. These gray polygons are production placeholders.
const CONTACT = .30
const DURATION = 1.15
const TARGET = Vector2(646, 438)
const REACH = 235.0
var age = 0.0
var playing = true
var rate = 1.0
var debug_on = true
var trail_on = true
var capture_active = false
var play: Button
var scrub: HSlider
var time_text: Label
var beat_text: Label

func text(value: String, pos: Vector2, size_: int = 16, color: Color = Color("d5d7dc"), width: float = 800) -> Label:
	var l = Label.new()
	l.text = value; l.position = pos; l.size.x = width
	l.add_theme_font_size_override("font_size", size_)
	l.add_theme_color_override("font_color", color)
	add_child(l)
	return l

func button(value: String, pos: Vector2, width: float, action: Callable) -> Button:
	var b = Button.new(); b.text = value; b.position = pos; b.size = Vector2(width, 36)
	b.pressed.connect(action); add_child(b)
	return b

func _ready():
	text("ELECTRIC / GAMEPLAY STUDY", Vector2(30, 22), 15, Color("a8adb7"))
	text("02   Motion & silhouette blockout", Vector2(30, 51), 30)
	text("WORK IN PROGRESS · grayscale · original authored motion", Vector2(30, 94), 14, Color("9fa4af"))
	text("PRODUCTION INSPECTOR", Vector2(942, 146), 13, Color("a7adb8"), 310)
	beat_text = text("", Vector2(942, 180), 22, Color("e8e9ed"), 300)
	var info = RichTextLabel.new(); info.position = Vector2(942, 225); info.size = Vector2(302, 383)
	info.bbcode_enabled = true
	info.text = "[b]Intent[/b]\nA long-reaching, character-anchored sword attack. A small eye motif can follow later; it must support the attack.\n\n[b]Motion construction[/b]\nThe hand drives the sword. A planted rear foot and short forward step support the sweep. The broad crescent follows the blade's recent path.\n\n[b]Authored beat sheet[/b]\n0.00–0.18  Wind-up\n0.18–0.30  Forward sweep\n0.30  Contact marker\n0.30–0.46  Follow-through\n0.46–0.90  Recover\n\n[b]This review[/b]\nRead direction, reach, contact and recovery at 1×. Toggle the mass off to inspect the weapon path. The loop returns to the same ready pose.\n\n[b]Next passes[/b]\nBrush masks → material reveal / erosion → art-directed arcs and particles → gameplay integration."
	info.add_theme_font_size_override("normal_font_size", 15)
	info.add_theme_font_size_override("bold_font_size", 15)
	info.add_theme_color_override("default_color", Color("bfc3cc")); add_child(info)
	text("Contact / path overlays", Vector2(42, 148), 13, Color("a7adb8"))
	text("wind-up", Vector2(124, 218), 11, Color("818995"), 70)
	text("contact", Vector2(237, 218), 11, Color("b7bdc7"), 70)
	text("exit", Vector2(360, 218), 11, Color("818995"), 70)
	text("settled", Vector2(667, 218), 11, Color("818995"), 70)
	text("Cinematic framing replaced with a weapon-driven attack", Vector2(42, 567), 14, Color("a7adb8"))
	var overlay = CheckButton.new(); overlay.text = "Path / contact"; overlay.position = Vector2(40, 612); overlay.button_pressed = true
	overlay.toggled.connect(func(v): debug_on = v); add_child(overlay)
	var mass = CheckButton.new(); mass.text = "Slash mass"; mass.position = Vector2(225, 612); mass.button_pressed = true
	mass.toggled.connect(func(v): trail_on = v); add_child(mass)
	button("Wind-up", Vector2(420, 613), 100, func(): seek(.14))
	button("Contact", Vector2(530, 613), 100, func(): seek(CONTACT))
	button("Recovery", Vector2(640, 613), 100, func(): seek(.48))
	button("Clean view", Vector2(750, 613), 120, func(): debug_on = false; overlay.set_pressed_no_signal(false))
	scrub = HSlider.new(); scrub.position = Vector2(42, 676); scrub.size = Vector2(825, 30)
	scrub.min_value = 0; scrub.max_value = DURATION; scrub.step = .001; scrub.value_changed.connect(seek); add_child(scrub)
	time_text = text("", Vector2(770, 652), 14, Color("c1c4cc"), 120)
	play = button("Pause", Vector2(42, 726), 100, func(): playing = not playing)
	button("Replay", Vector2(153, 726), 100, func(): age = 0.; playing = true)
	var speed = OptionButton.new(); speed.position = Vector2(269, 726); speed.size = Vector2(115, 36)
	for value in ["0.25×", "0.5×", "1×"]: speed.add_item(value)
	speed.select(2); speed.item_selected.connect(func(i): rate = [.25, .5, 1.][i]); add_child(speed)
	text("Space replay / P pause / Left-Right step", Vector2(410, 732), 13, Color("969da9"))
	text("PASS GATE", Vector2(942, 648), 12, Color("969da9"), 290)
	text("Direction / contact / clear exit", Vector2(942, 674), 17, Color("d5d7dc"), 290)
	text("Visual review pending.\nNo final materials or particles.", Vector2(942, 713), 14, Color("9fa4af"), 290)
	if "--capture-study" in OS.get_cmdline_user_args(): capture.call_deferred()
	if "--check-study" in OS.get_cmdline_user_args(): check_study.call_deferred()

func seek(value: float): age = value; playing = false
func body_root(t: float) -> Vector2:
	var forward = smoothstep(.14, CONTACT, t) * (1. - smoothstep(.48, .94, t))
	return Vector2(360 + 28 * forward, 490)
func hand(t: float) -> Vector2: return body_root(t) + Vector2(23, -52)
func angle(t: float) -> float:
	var windup = lerpf(-.75, -2.45, smoothstep(.02, .16, t))
	var a = lerpf(windup, .45, smoothstep(.18, .34, t))
	return lerpf(a, -.75, smoothstep(.49, .90, t))
func orbit(theta: float, radius: float) -> Vector2: return Vector2(cos(theta) * radius, sin(theta) * radius * .58)
func tip(t: float) -> Vector2: return hand(t) + orbit(angle(t), REACH)
func lead_foot(t: float) -> Vector2:
	var step_out = smoothstep(.09, .26, t)
	var step_in = smoothstep(.60, .90, t)
	var lift = sin(step_out * PI) * (1. - step_in) + sin(step_in * PI)
	return Vector2(383 + 43 * step_out * (1. - step_in), 490 - 9 * lift)
func beat() -> String:
	if age < .18: return "01 / Wind-up"
	if age < CONTACT: return "02 / Forward sweep"
	if age < .355: return "03 / Contact"
	if age < .46: return "04 / Follow-through"
	return "05 / Recovery"
func _process(delta):
	if playing and not capture_active:
		age += delta * rate
		if age > DURATION + .35: age = 0
	scrub.set_value_no_signal(minf(age, DURATION))
	time_text.text = "%.3f s" % age
	beat_text.text = beat(); play.text = "Pause" if playing else "Play"
	queue_redraw()
func _unhandled_key_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE: age = 0.; playing = true
		elif event.keycode == KEY_P: playing = not playing
		elif event.keycode == KEY_LEFT: seek(clampf(age - 1. / 60., 0, DURATION))
		elif event.keycode == KEY_RIGHT: seek(clampf(age + 1. / 60., 0, DURATION))

func poly(points: Array, color: Color): draw_colored_polygon(PackedVector2Array(points), color)
func person(root: Vector2, value: float, lean: float, armed: bool):
	# Neutral anatomical proxies; no character asset or animation quality claim.
	draw_set_transform(root)
	stage_ellipse(Vector2(5, 0), Vector2(34, 8), Color(0, 0, 0, .38))
	var hip = Vector2(lean * .28, -35)
	var shoulder = Vector2(lean, -78)
	var c = Color(value, value, value)
	poly([shoulder + Vector2(-17, 0), shoulder + Vector2(17, 0), hip + Vector2(13, 0), hip + Vector2(-13, 0)], c * .72)
	draw_circle(shoulder + Vector2(0, -20), 13, c)
	var rear = Vector2(338, 490) - root if armed else Vector2(-22, 0)
	var lead = lead_foot(age) - root if armed else Vector2(23, 0)
	for pair in [[hip + Vector2(-8, 0), rear], [hip + Vector2(8, 0), lead]]:
		var knee = (pair[0] + pair[1]) * .5 + Vector2(7, -4)
		draw_polyline(PackedVector2Array([pair[0], knee, pair[1]]), c, 9, true)
		draw_line(pair[1] + Vector2(-5, 0), pair[1] + Vector2(9, 0), c * .8, 5, true)
	if armed:
		draw_polyline(PackedVector2Array([shoulder + Vector2(12, 5), Vector2(31, -67), Vector2(23, -52)]), c, 8, true)
		draw_line(shoulder + Vector2(-12, 3), Vector2(-20, -49), c, 7, true)
	else:
		draw_line(shoulder + Vector2(-16, 4), Vector2(-28, -40), c, 8, true)
		draw_line(shoulder + Vector2(16, 4), Vector2(28 + lean, -40), c, 8, true)
	draw_set_transform(Vector2.ZERO)
func stage_ellipse(center: Vector2, radius: Vector2, color: Color):
	var points = PackedVector2Array()
	for i in range(48): points.append(center + Vector2(cos(i * TAU / 48), sin(i * TAU / 48)) * radius)
	draw_colored_polygon(points, color)

func slash_mass():
	if not trail_on or age < .19 or age > .48: return
	var head = angle(minf(age, .34))
	var tail = angle(maxf(.18, minf(age, .34) - .065))
	var fade = 1. - smoothstep(.35, .48, age)
	var collapse = smoothstep(.34, .46, age)
	tail = lerpf(tail, head - .06, collapse)
	if head - tail < .005: return
	var outer: Array = []; var inner: Array = []
	var center = hand(minf(age, .34))
	for i in range(33):
		var u = float(i) / 32
		var a = lerpf(tail, head, u)
		# Broad body, tapered at both ends. Breakup is deferred to texture pass.
		var width = pow(sin(PI * u), .7) * 61 * (1. - collapse * .7)
		var r = REACH + 3 + width * .30
		outer.append(center + orbit(a, r)); inner.push_front(center + orbit(a, r - width))
	poly(outer + inner, Color(.64, .64, .64, fade * .86))
	var edge = PackedVector2Array()
	for i in range(33):
		var u = float(i) / 32
		edge.append(center + orbit(lerpf(tail, head, u), REACH + 3 + pow(sin(PI * u), .7) * 18.3))
	draw_polyline(edge, Color(.92, .92, .92, fade), 2.5, true)

func _draw():
	draw_rect(Rect2(24, 132, 886, 468), Color("191d24"))
	draw_rect(Rect2(926, 132, 330, 640), Color("15181f"))
	for y in [360, 415, 490, 560]: draw_line(Vector2(40, y), Vector2(890, y), Color(.6, .6, .6, .055))
	for x in range(60, 900, 90): draw_line(Vector2(x, 570), Vector2(460 + (x - 460) * .5, 335), Color(.6, .6, .6, .055))
	var contact_live = smoothstep(CONTACT, CONTACT + .008, age) * (1. - smoothstep(.335, .37, age))
	var reaction = sin(clampf((age - CONTACT) / .3, 0, 1) * PI) * 12
	person(Vector2(TARGET.x, 490), .48 + contact_live * .4, reaction, false)
	person(body_root(age), .72, -10. + smoothstep(.16, .30, age) * 26 * (1 - smoothstep(.45, .85, age)), true)
	slash_mass()
	var h = hand(age); var blade = tip(age)
	var normal = Vector2(-(blade - h).y, (blade - h).x).normalized()
	var base = h + (blade - h).normalized() * 37
	poly([base + normal * 5, blade, base - normal * 5], Color("e0e0e0"))
	draw_line(h - (blade - h).normalized() * 10, base, Color("737373"), 7, true)
	draw_line(base - normal * 12, base + normal * 12, Color("bebebe"), 4, true)
	if debug_on:
		var path = PackedVector2Array()
		for i in range(65): path.append(tip(lerpf(.18, .34, float(i) / 64)))
		draw_polyline(path, Color(.75, .75, .75, .20), 1.3, true)
		draw_arc(TARGET, 24, 0, TAU, 48, Color(.7, .7, .7, .35), 1.5, true)
		draw_circle(blade, 4.5, Color("f0f0f0"))
		draw_line(Vector2(646, 490), Vector2(646, 535), Color(.6, .6, .6, .4), 1)
		if contact_live > 0:
			draw_arc(TARGET, 27 + contact_live * 5, 0, TAU, 48, Color(1, 1, 1, contact_live), 3, true)
			draw_line(TARGET + Vector2(-11, -11), TARGET + Vector2(11, 11), Color(1, 1, 1, contact_live), 2)
			draw_line(TARGET + Vector2(11, -11), TARGET + Vector2(-11, 11), Color(1, 1, 1, contact_live), 2)
	# Event ruler: an authored contact marker, not an implemented combat system.
	var ruler = Rect2(43, 205, 824, 3)
	draw_rect(ruler, Color("363b45"))
	for t in [.18, CONTACT, .46, .90]:
		var x = ruler.position.x + t / DURATION * ruler.size.x
		draw_line(Vector2(x, 197), Vector2(x, 214), Color("a2a6af"), 1)
	draw_circle(Vector2(ruler.position.x + minf(age, DURATION) / DURATION * ruler.size.x, 206), 4, Color("e0e0e0"))

func shot(path: String):
	await get_tree().process_frame; await RenderingServer.frame_post_draw
	await get_tree().process_frame; await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
func capture():
	capture_active = true; playing = false
	var args = OS.get_cmdline_user_args(); var out = args[args.find("--capture-study") + 1]
	DirAccess.make_dir_recursive_absolute(out)
	for i in range(70):
		age = float(i) / 60
		await shot(out.path_join("frame-%03d.png" % i))
	for i in range(4):
		age = [.14, .26, CONTACT, .48][i]
		await shot(out.path_join("beat-%d.png" % i))
	debug_on = false; age = CONTACT; await shot(out.path_join("clean-contact.png"))
	print("CAPTURED: 70 native frames at 60 fps; four beats; clean contact")
	get_tree().quit()
func check_study():
	# Functional invariants, not a visual approval claim.
	assert(tip(CONTACT).distance_to(TARGET) < 2)
	assert(tip(.18).distance_to(TARGET) > 250)
	assert(body_root(.3).x > body_root(0).x + 25)
	assert(body_root(1.).distance_to(body_root(0)) < 1)
	assert(absf(angle(DURATION) - angle(0)) < .001)
	assert(lead_foot(DURATION).distance_to(lead_foot(0)) < .001)
	seek(.26); var held = age; trail_on = false; debug_on = false
	assert(age == held and not playing)
	print("PASS: blade tip within 2px of contact marker; anticipation outside target; forward reach, root/weapon/foot recovery; review toggles hold time")
	get_tree().quit()
