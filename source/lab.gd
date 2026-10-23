extends Node2D

const Effect = preload("res://effect.gd")
const NAMES = ["Fire", "Electric", "Ice", "Healing", "Slash", "Stab", "Muzzle flash", "Explosion"]
const NOTES = ["Rolling flame tongues, rising embers and a fast heat pulse.", "Branching arcs with a bright core and a flickering discharge.", "Radial crystal growth, sharp facets and drifting frost.", "Orbiting motes, rising crosses and a gentle restoration pulse.", "A swept crescent with a sharp leading edge and lingering trail.", "A fast directional thrust, tapered streak and concentrated tip.", "A brief directional starburst with hot sparks and quick decay.", "An expanding fire bloom, debris, smoke and a pressure ring."]
const DURATIONS = [1.6, 0.9, 1.8, 2.0, 0.8, 0.65, 0.45, 1.8]
const MUTED = Color("8796ae")
const WHITE = Color("e5edfb")
var selected = 0
var playhead = 0.0
var playing = true
var loop = true
var speed = 1.0
var intensity = 1.0
var size_multiplier = 1.0
var light_stage = false
var fx: Node2D
var ai_sprite: Sprite2D
var use_ai = false
var buttons: Array[Button] = []
var title_label: Label
var note_label: Label
var time_label: Label
var phase_label: Label
var source_label: Label
var timeline: HSlider
var pause_button: Button
var layer_toggles: Array[CheckButton] = []
var shot_count = 1

func label_at(text: String, p: Vector2, font_size: int, color: Color = WHITE, width: float = 700) -> Label:
	var label = Label.new()
	label.text = text
	label.position = p
	label.size = Vector2(width, 38)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	add_child(label)
	return label

func box_style(bg: Color, border: Color, radius: int = 9) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 14
	style.content_margin_right = 14
	return style

func button_at(text: String, p: Vector2, dimensions: Vector2, action: Callable) -> Button:
	var button = Button.new()
	button.text = text
	button.position = p
	button.size = dimensions
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", WHITE)
	button.add_theme_stylebox_override("normal", box_style(Color("131e30"), Color("26344b")))
	button.add_theme_stylebox_override("hover", box_style(Color("21344e"), Color("647b9e")))
	button.add_theme_stylebox_override("pressed", box_style(Color("30455e"), Color("9bb7dc")))
	button.pressed.connect(action)
	add_child(button)
	return button

func slider_at(p: Vector2, width: float, minimum: float, maximum: float, step_value: float, value: float, action: Callable) -> HSlider:
	var slider = HSlider.new()
	slider.position = p
	slider.size = Vector2(width, 32)
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = step_value
	slider.value = value
	slider.value_changed.connect(action)
	add_child(slider)
	return slider

func toggle_at(text: String, y: float, enabled: bool, action: Callable) -> CheckButton:
	var toggle = CheckButton.new()
	toggle.text = text
	toggle.position = Vector2(1172, y)
	toggle.size = Vector2(238, 38)
	toggle.button_pressed = enabled
	toggle.add_theme_font_size_override("font_size", 15)
	toggle.toggled.connect(action)
	add_child(toggle)
	return toggle

func _ready():
	label_at("FX /", Vector2(28, 23), 28, Color("a4d9ff"))
	label_at("EFFECTS LAB", Vector2(106, 27), 24)
	label_at("GODOT  /  REAL-TIME STUDIES", Vector2(880, 32), 13, MUTED)
	label_at("01 — EFFECT LIBRARY", Vector2(28, 114), 13, MUTED)
	for i in range(NAMES.size()):
		var index = i
		var button = button_at("%02d     %s" % [i + 1, NAMES[i]], Vector2(24, 158 + i * 62), Vector2(206, 50), func(): select_effect(index))
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		buttons.append(button)
	label_at("1–8    Select effect\nSPACE    Replay\nP    Pause / resume", Vector2(28, 715), 14, MUTED, 210)
	label_at("VIEWPORT  /  CLICK TO REPLAY", Vector2(284, 115), 12, MUTED)
	label_at("LIVE", Vector2(1063, 115), 12, Color("7ce3b9"))
	title_label = label_at("", Vector2(286, 156), 32)
	phase_label = label_at("", Vector2(286, 204), 13, MUTED)
	label_at("02 — TUNE & INSPECT", Vector2(1172, 114), 13, MUTED, 250)
	note_label = label_at("", Vector2(1172, 159), 16, WHITE, 235)
	note_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note_label.size.y = 112
	label_at("INTENSITY", Vector2(1172, 293), 12, MUTED, 240)
	var intensity_label = label_at("1.00×", Vector2(1348, 289), 14, WHITE, 75)
	slider_at(Vector2(1172, 326), 232, 0.3, 2.0, 0.05, 1.0, func(v): intensity = v; intensity_label.text = "%.2f×" % v)
	label_at("SIZE", Vector2(1172, 382), 12, MUTED, 240)
	var size_label = label_at("1.00×", Vector2(1348, 378), 14, WHITE, 75)
	slider_at(Vector2(1172, 415), 232, 0.5, 1.5, 0.05, 1.0, func(v): size_multiplier = v; size_label.text = "%.2f×" % v)
	label_at("LAYERS", Vector2(1172, 474), 12, MUTED, 240)
	layer_toggles.append(toggle_at("Core shape", 505, true, func(v): fx.show_core = v))
	layer_toggles.append(toggle_at("Sparks / motes", 548, true, func(v): fx.show_particles = v))
	layer_toggles.append(toggle_at("Shockwave / rings", 591, true, func(v): fx.show_rings = v))
	toggle_at("AI flipbook · explosion", 645, false, func(v): use_ai = v)
	toggle_at("Light background", 693, false, func(v): light_stage = v; queue_redraw())
	label_at("PLAYBACK", Vector2(284, 741), 12, MUTED)
	pause_button = button_at("Pause", Vector2(284, 780), Vector2(110, 42), toggle_playing)
	button_at("Replay", Vector2(404, 780), Vector2(110, 42), replay)
	button_at("New seed", Vector2(524, 780), Vector2(126, 42), func(): fx.variation += 1; replay())
	var loop_toggle = CheckButton.new()
	loop_toggle.text = "Loop"
	loop_toggle.position = Vector2(676, 782)
	loop_toggle.button_pressed = true
	loop_toggle.toggled.connect(func(v): loop = v)
	add_child(loop_toggle)
	var rate = OptionButton.new()
	rate.position = Vector2(800, 783)
	rate.size = Vector2(100, 36)
	for text in ["0.25×", "0.5×", "1×", "2×"]:
		rate.add_item(text)
	rate.select(2)
	rate.item_selected.connect(func(i): speed = [0.25, 0.5, 1.0, 2.0][i])
	add_child(rate)
	timeline = slider_at(Vector2(284, 695), 738, 0, 2, 0.001, 0, func(v): playhead = v; playing = false; update_play_button())
	time_label = label_at("", Vector2(1032, 695), 14, WHITE, 100)
	source_label = label_at("", Vector2(28, 855), 12, MUTED, 1300)
	fx = Effect.new()
	fx.position = Vector2(698, 455)
	add_child(fx)
	ai_sprite = Sprite2D.new()
	ai_sprite.texture = load("res://art/wan-impact-atlas.png")
	ai_sprite.hframes = 7
	ai_sprite.vframes = 7
	ai_sprite.position = fx.position
	ai_sprite.material = fx.material
	ai_sprite.visible = false
	add_child(ai_sprite)
	select_effect(0)
	if "--self-test" in OS.get_cmdline_user_args():
		self_test.call_deferred()
	if "--capture" in OS.get_cmdline_user_args():
		capture.call_deferred()

func select_effect(index: int):
	selected = clampi(index, 0, 7)
	fx.kind = selected
	title_label.text = NAMES[selected]
	title_label.add_theme_color_override("font_color", Effect.COLORS[selected])
	note_label.text = NOTES[selected]
	timeline.max_value = DURATIONS[selected]
	for i in range(buttons.size()):
		buttons[i].add_theme_stylebox_override("normal", box_style(Color("21304a") if i == selected else Color("111a2a"), Effect.COLORS[i] if i == selected else Color("26344b")))
	replay()

func replay():
	playhead = 0
	playing = true
	shot_count += 1
	update_play_button()

func toggle_playing():
	playing = not playing
	update_play_button()

func update_play_button():
	pause_button.text = "Pause" if playing else "Play"

func _process(delta):
	if playing:
		playhead += delta * speed
		if playhead > DURATIONS[selected] + 0.55:
			if loop:
				playhead = 0
			else:
				playhead = DURATIONS[selected]
				playing = false
				update_play_button()
	fx.seconds = playhead
	fx.effect_scale = size_multiplier
	fx.strength = 1.0
	fx.modulate = Color(intensity, intensity, intensity, 1)
	fx.queue_redraw()
	timeline.set_value_no_signal(minf(playhead, DURATIONS[selected]))
	time_label.text = "%.2f s" % minf(playhead, DURATIONS[selected])
	phase_label.text = "ATTACK / BURST" if playhead < 0.16 else ("EXPANSION / FOLLOW-THROUGH" if playhead < DURATIONS[selected] * 0.5 else "DECAY / RECOVERY")
	if playhead > DURATIONS[selected]:
		phase_label.text = "READY FOR NEXT BURST"
	ai_sprite.visible = use_ai and selected == 7 and fx.show_core and playhead < 1.5
	if ai_sprite.visible:
		ai_sprite.frame = clampi(int(playhead / 1.5 * 49), 0, 48)
		ai_sprite.scale = Vector2.ONE * size_multiplier * 1.2
		ai_sprite.modulate = Color(1, 1, 1, (1 - smoothstep(0.5, 1.5, playhead)) * intensity)
	source_label.text = "NATIVE GODOT  /  Procedural geometry + additive light + deterministic particles  /  Seed %d" % fx.variation
	if use_ai and selected == 7:
		source_label.text = "HYBRID  /  Native layers + local Wan 2.2 5B flipbook  /  Black-backed source with additive blending and engine-controlled fade"
	queue_redraw()

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= KEY_8:
			select_effect(event.keycode - KEY_1)
		elif event.keycode == KEY_SPACE:
			replay()
		elif event.keycode == KEY_P:
			toggle_playing()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Rect2(260, 252, 875, 420).has_point(get_global_mouse_position()):
			replay()

func _draw():
	draw_rect(Rect2(0, 0, 1440, 900), Color("080d17"))
	draw_rect(Rect2(0, 86, 250, 750), Color("0c1320"))
	draw_rect(Rect2(1150, 86, 290, 750), Color("0c1320"))
	draw_line(Vector2(0, 86), Vector2(1440, 86), Color("26344b"))
	draw_line(Vector2(0, 836), Vector2(1440, 836), Color("26344b"))
	var stage_bg = Color("7b8798") if light_stage else Color("0c1422")
	draw_style_box(box_style(stage_bg, Color("26344b"), 12), Rect2(266, 100, 868, 630))
	var grid_color = Color(0.7, 0.8, 1, 0.09) if not light_stage else Color(0.1, 0.15, 0.25, 0.15)
	for x in range(290, 1120, 40):
		draw_line(Vector2(x, 270), Vector2(x, 668), grid_color, 1)
	for y in range(270, 670, 40):
		draw_line(Vector2(282, y), Vector2(1118, y), grid_color, 1)
	var center = Vector2(698, 455)
	draw_arc(center, 175, 0, TAU, 100, Color("263b55"), 1, true)
	draw_arc(center, 90, 0, TAU, 80, Color("263b55"), 1, true)
	for d in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		draw_line(center + d * 182, center + d * 194, Color("61738d"), 2, true)
	var target_color = Color("344961") if not light_stage else Color("52647a")
	var recoil = sin(minf(playhead * 20, PI)) * 6 if selected in [4, 5, 6, 7] and playhead < 0.16 else 0.0
	var target = center + Vector2(recoil, 0)
	draw_circle(target, 24, Color("101d2e"))
	draw_arc(target, 24, 0, TAU, 40, target_color, 2, true)
	draw_line(target - Vector2(9, 0), target + Vector2(9, 0), target_color, 1)
	draw_line(target - Vector2(0, 9), target + Vector2(0, 9), target_color, 1)
	if selected in [0, 7] and playhead > 0.3 and playhead < 1.9:
		var age = (playhead - 0.3) / 1.6
		for i in range(8):
			var angle = i * TAU / 8
			var p = center + Vector2.from_angle(angle) * age * 85 - Vector2(0, age * 70)
			draw_circle(p, 15 + age * 25, Color(0.12, 0.15, 0.19, sin(age * PI) * 0.35))

func self_test():
	playing = false
	for i in range(8):
		select_effect(i)
		assert(selected == i and title_label.text == NAMES[i])
		assert(timeline.max_value == DURATIONS[i])
		for t in [0.0, 0.08, 0.25, 0.5, 1.0, 1.8]:
			fx.seconds = t
			assert(is_finite(fx.random_unit(i + int(t * 10))))
		fx.variation = 5
		var first = fx.random_unit(12)
		assert(first == fx.random_unit(12))
		fx.variation = 6
		assert(first != fx.random_unit(12))
	playing = false
	timeline.value = 0.21
	assert(is_equal_approx(playhead, 0.21) and not playing)
	fx.show_core = false
	assert(not fx.show_core)
	fx.show_core = true
	replay()
	assert(playing and playhead == 0)
	assert(ai_sprite.texture.get_size() == Vector2(1792, 1792))
	print("PASS: eight selectors, per-effect durations, deterministic seeds, scrub/pause, replay, layer toggle, flipbook dimensions")
	get_tree().quit()

func capture():
	var args = OS.get_cmdline_user_args()
	var output = args[args.find("--capture") + 1]
	DirAccess.make_dir_recursive_absolute(output)
	for i in range(8):
		select_effect(i)
		playing = false
		playhead = [0.24, 0.19, 0.37, 0.75, 0.19, 0.09, 0.065, 0.25][i]
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(output.path_join("%02d.png" % i))
	print("CAPTURED: all eight effects")
	get_tree().quit()
