extends Node2D

const Catalog = preload("res://catalog.gd")
const Renderer = preload("res://renderer.gd")
const WHITE = Color("e5edfb")
const MUTED = Color("899bb4")
var selected = 0
var method = 0
var mutation = 0
var playhead = 0.0
var playing = true
var loop = true
var speed = 1.0
var intensity = 0.9
var size_multiplier = 1.0
var light_stage = false
var seed_value = 17
var renderer: Node2D
var effect_buttons: Array[Button] = []
var method_buttons: Array[Button] = []
var mutation_buttons: Array[Button] = []
var title_label: Label
var subtitle_label: Label
var time_label: Label
var phase_label: Label
var inspector_title: Label
var inspector_body: RichTextLabel
var timeline: HSlider
var pause_button: Button
var seed_label: Label
var capture_active = false

func label_at(text: String, p: Vector2, font_size: int, color: Color = WHITE, width: float = 700) -> Label:
	var label = Label.new()
	label.text = text
	label.position = p
	label.size = Vector2(width, 35)
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
	button.add_theme_font_size_override("font_size", 15)
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

func _ready():
	label_at("FX /", Vector2(26, 24), 30, Color("9ed8ff"))
	label_at("EFFECTS LAB", Vector2(105, 28), 24)
	label_at("24 IMPLEMENTATIONS  /  72 STUDIES", Vector2(770, 33), 13, MUTED)
	label_at("V02 · GODOT", Vector2(1420, 33), 13, MUTED, 170)
	label_at("EFFECT LIBRARY", Vector2(24, 120), 12, MUTED, 190)
	for k in range(8):
		var index = k
		var button = button_at("%02d   %s" % [k + 1, Catalog.NAMES[k]], Vector2(20, 165 + k * 66), Vector2(184, 52), func(): select_effect(index))
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		effect_buttons.append(button)
	label_at("1–8   Select effect\nSpace   Replay\nP   Pause / resume", Vector2(25, 755), 13, MUTED, 190)
	button_at("Best attempt", Vector2(20, 705), Vector2(184, 40), show_best)
	label_at("IMPLEMENTATION", Vector2(242, 113), 12, MUTED)
	for m in range(3):
		var index = m
		method_buttons.append(button_at(Catalog.METHODS[m], Vector2(242 + m * 287, 146), Vector2(273, 44), func(): select_method(index)))
	label_at("MUTATION · switch methods at the same time & seed", Vector2(242, 207), 12, MUTED)
	for v in range(3):
		var index = v
		mutation_buttons.append(button_at("", Vector2(242 + v * 287, 238), Vector2(273, 40), func(): select_mutation(index)))
	title_label = label_at("", Vector2(253, 312), 27)
	subtitle_label = label_at("", Vector2(253, 352), 13, MUTED, 850)
	phase_label = label_at("", Vector2(253, 758), 12, MUTED, 800)
	label_at("PLAYHEAD", Vector2(242, 785), 12, MUTED)
	time_label = label_at("", Vector2(1020, 785), 14, WHITE, 100)
	timeline = slider_at(Vector2(242, 822), 855, 0, 2, 0.001, 0, func(v): playhead = v; playing = false; update_play_button())
	pause_button = button_at("Pause", Vector2(242, 879), Vector2(100, 42), toggle_playing)
	button_at("Replay", Vector2(354, 879), Vector2(100, 42), replay)
	button_at("New seed", Vector2(466, 879), Vector2(110, 42), new_seed)
	var looping = CheckButton.new()
	looping.text = "Loop"
	looping.position = Vector2(594, 882)
	looping.button_pressed = true
	looping.toggled.connect(func(v): loop = v)
	add_child(looping)
	var rate = OptionButton.new()
	rate.position = Vector2(717, 880)
	rate.size = Vector2(100, 40)
	for text in ["0.25×", "0.5×", "1×", "2×"]:
		rate.add_item(text)
	rate.select(2)
	rate.item_selected.connect(func(i): speed = [0.25, 0.5, 1.0, 2.0][i])
	add_child(rate)
	seed_label = label_at("", Vector2(845, 886), 13, MUTED, 200)
	label_at("SIDE INSPECTOR", Vector2(1162, 113), 12, MUTED, 410)
	inspector_title = label_at("", Vector2(1162, 151), 23, WHITE, 410)
	inspector_body = RichTextLabel.new()
	inspector_body.position = Vector2(1162, 198)
	inspector_body.size = Vector2(404, 518)
	inspector_body.bbcode_enabled = true
	inspector_body.add_theme_font_size_override("normal_font_size", 16)
	inspector_body.add_theme_font_size_override("bold_font_size", 16)
	inspector_body.add_theme_color_override("default_color", Color("bccbdd"))
	inspector_body.add_theme_constant_override("line_separation", 5)
	inspector_body.meta_clicked.connect(func(url): OS.shell_open(str(url)))
	add_child(inspector_body)
	label_at("SIZE", Vector2(1162, 743), 12, MUTED, 90)
	var size_label = label_at("1.00×", Vector2(1480, 739), 14, WHITE, 90)
	slider_at(Vector2(1162, 775), 393, 0.5, 1.35, 0.05, 1.0, func(v): size_multiplier = v; size_label.text = "%.2f×" % v)
	label_at("INTENSITY", Vector2(1162, 821), 12, MUTED, 120)
	var intensity_label = label_at("0.90×", Vector2(1480, 817), 14, WHITE, 90)
	slider_at(Vector2(1162, 852), 393, 0.3, 1.35, 0.05, 0.9, func(v): intensity = v; intensity_label.text = "%.2f×" % v)
	var background = CheckButton.new()
	background.text = "Light background"
	background.position = Vector2(1162, 899)
	background.toggled.connect(func(v): light_stage = v; queue_redraw())
	add_child(background)
	label_at("SPRITE / PARTICLES / SHADER     ·     Method switches preserve time & seed     ·     Scroll the inspector for source links and tradeoffs", Vector2(26, 964), 12, MUTED, 1550)
	var clip = Control.new()
	clip.position = Vector2(234, 378)
	clip.size = Vector2(884, 374)
	clip.clip_contents = true
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(clip)
	renderer = Renderer.new()
	renderer.position = Vector2(442, 187)
	clip.add_child(renderer)
	select_effect(0)
	if "--self-test" in OS.get_cmdline_user_args(): self_test.call_deferred()
	if "--capture" in OS.get_cmdline_user_args(): capture.call_deferred()
	if "--seek-test" in OS.get_cmdline_user_args(): seek_test.call_deferred()

func refresh_selection():
	title_label.text = Catalog.NAMES[selected] + " / " + Catalog.mutation_name(selected, method, mutation)
	title_label.add_theme_color_override("font_color", Catalog.COLORS[selected])
	subtitle_label.text = ["Animated texture · authored detail", "Real engine emitters · textured billboards", "Procedural pixel field · no source image"][method]
	inspector_title.text = Catalog.METHODS[method] + " · " + Catalog.NAMES[selected]
	inspector_body.text = Catalog.inspector(selected, method, mutation)
	inspector_body.scroll_to_line(0)
	for k in range(8):
		effect_buttons[k].add_theme_stylebox_override("normal", box_style(Color("21304a") if selected == k else Color("101929"), Catalog.COLORS[k] if selected == k else Color("26344b")))
	for m in range(3):
		method_buttons[m].add_theme_stylebox_override("normal", box_style(Color("26394e") if method == m else Color("131e30"), Color("91b4d5") if method == m else Color("26344b")))
	for v in range(3):
		mutation_buttons[v].text = Catalog.mutation_name(selected, method, v)
		mutation_buttons[v].add_theme_stylebox_override("normal", box_style(Color("24354a") if mutation == v else Color("131e30"), Catalog.COLORS[selected] if mutation == v else Color("26344b")))
	renderer.configure(selected, method, mutation, seed_value)
	update_play_button()

func select_effect(index: int):
	selected = clampi(index, 0, 7)
	playhead = 0
	timeline.set_block_signals(true)
	timeline.max_value = Catalog.DURATIONS[selected]
	timeline.value = 0
	timeline.set_block_signals(false)
	refresh_selection()
	playing = true
	update_play_button()

func select_method(index: int):
	method = index
	refresh_selection()

func show_best():
	method = Catalog.PICKS[selected][0]
	mutation = Catalog.PICKS[selected][1]
	playhead = [0.32, 0.18, 0.58, 0.68, 0.20, 0.10, 0.08, 0.35][selected]
	playing = false
	refresh_selection()

func select_mutation(index: int):
	mutation = index
	refresh_selection()

func replay():
	playhead = 0
	renderer.last_time = -1
	playing = true
	update_play_button()

func new_seed():
	seed_value += 1
	refresh_selection()

func toggle_playing():
	playing = not playing
	update_play_button()

func update_play_button():
	pause_button.text = "Pause" if playing else "Play"

func _process(delta):
	if not renderer: return
	if playing and not capture_active:
		playhead += delta * speed
		if playhead > Catalog.DURATIONS[selected] + 0.45:
			if loop: playhead = 0
			else:
				playhead = Catalog.DURATIONS[selected]
				playing = false
				update_play_button()
	renderer.sample(playhead, size_multiplier, intensity)
	timeline.set_value_no_signal(minf(playhead, Catalog.DURATIONS[selected]))
	time_label.text = "%.2f s" % minf(playhead, Catalog.DURATIONS[selected])
	seed_label.text = "SEED  %d" % seed_value
	phase_label.text = "ATTACK" if playhead < 0.12 else ("PEAK / FOLLOW-THROUGH" if playhead < Catalog.DURATIONS[selected] * 0.5 else "DECAY")
	var viewport_text = Color("172639") if light_stage else MUTED
	subtitle_label.add_theme_color_override("font_color", viewport_text)
	phase_label.add_theme_color_override("font_color", viewport_text)
	title_label.add_theme_color_override("font_color", Catalog.COLORS[selected].darkened(0.65) if light_stage else Catalog.COLORS[selected])
	queue_redraw()

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= KEY_8: select_effect(event.keycode - KEY_1)
		elif event.keycode == KEY_SPACE: replay()
		elif event.keycode == KEY_P: toggle_playing()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Rect2(234, 390, 884, 310).has_point(get_global_mouse_position()): replay()

func _draw():
	draw_rect(Rect2(0, 0, 1600, 1000), Color("080d17"))
	draw_rect(Rect2(0, 88, 222, 860), Color("0c1320"))
	draw_rect(Rect2(1140, 88, 460, 860), Color("0c1320"))
	draw_line(Vector2(0, 88), Vector2(1600, 88), Color("26344b"))
	draw_line(Vector2(0, 948), Vector2(1600, 948), Color("26344b"))
	var stage = Color("8994a4") if light_stage else Color("0c1422")
	draw_style_box(box_style(stage, Color("26344b"), 12), Rect2(234, 300, 884, 480))
	var grid = Color(0.55, 0.7, 0.9, 0.08) if not light_stage else Color(0.12, 0.18, 0.25, 0.12)
	for x in range(252, 1110, 32): draw_line(Vector2(x, 378), Vector2(x, 750), grid)
	for y in range(378, 752, 32): draw_line(Vector2(250, y), Vector2(1102, y), grid)
	var center = Vector2(676, 565)
	draw_line(center - Vector2(10, 0), center + Vector2(10, 0), Color("44556d"))
	draw_line(center - Vector2(0, 10), center + Vector2(0, 10), Color("44556d"))

func self_test():
	capture_active = true
	var configurations = 0
	for k in range(8):
		select_effect(k)
		playing = false
		playhead = 0.27
		for m in range(3):
			select_method(m)
			assert(is_equal_approx(playhead, 0.27) and not playing)
			for v in range(3):
				select_mutation(v)
				assert(is_equal_approx(playhead, 0.27) and seed_value == 17)
				assert(inspector_body.text.contains("Tradeoff"))
				if m == 0: assert(renderer.cards.size() > 0 and renderer.cards[0].texture != null)
				elif m == 1:
					assert(renderer.emitters.size() > 0 and renderer.emitters[0] is GPUParticles2D)
					assert(renderer.emitters[0].use_fixed_seed and renderer.emitters[0].speed_scale == 0)
				else: assert(renderer.shader_material.shader != null)
				for age in [0.01, 0.15, 0.5, 1.0, 0.15]: renderer.sample(age, 1.0, 0.9)
				configurations += 1
	playing = false
	timeline.value = 0.2
	assert(is_equal_approx(playhead, 0.2) and not playing)
	replay()
	assert(playing and playhead == 0)
	print("PASS: %d configurations; genuine paths; textures; held time/seed; forward/backward seek; replay; inspector" % configurations)
	get_tree().quit()

func save_capture(output: String, filename: String):
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(output.path_join(filename))

func settled_image() -> Image:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	return get_viewport().get_texture().get_image().get_region(Rect2i(234,378,884,374))

func seek_test():
	capture_active = true
	var failed = 0
	for k in range(8):
		select_effect(k)
		playing = false
		select_method(1)
		playhead = 0.3
		var first = await settled_image()
		playhead = 0.65
		await settled_image()
		playhead = 0.3
		var second = await settled_image()
		if first.get_data() != second.get_data():
			failed += 1
			print("SEEK DIFFERENCE: ", Catalog.NAMES[k])
	print("PARTICLE SEEK: ",8-failed,"/8 pixel-identical backward seeks on this device")
	get_tree().quit(0 if failed == 0 else 1)

func capture():
	capture_active = true
	var args = OS.get_cmdline_user_args()
	var output = args[args.find("--capture") + 1]
	DirAccess.make_dir_recursive_absolute(output)
	for k in range(8):
		select_effect(k)
		playing = false
		for m in range(3):
			select_method(m)
			for v in range(3):
				select_mutation(v)
				playhead = [0.32, 0.18, 0.40, 0.68, 0.20, 0.10, 0.08, 0.35][k]
				await save_capture(output, "%d-%d-%d.png" % [k,m,v])
			select_mutation(0)
			for phase in [0.05, 0.3, 0.85]:
				playhead = phase * Catalog.DURATIONS[k]
				renderer.last_time = -1
				await save_capture(output, "phase-%d-%d-%d.png" % [k,m,int(phase*100)])
			light_stage = true
			playhead = Catalog.DURATIONS[k] * 0.3
			renderer.last_time = -1
			await save_capture(output, "light-%d-%d.png" % [k,m])
			light_stage = false
	print("CAPTURED: 72 configurations, 72 phases, 24 light backgrounds")
	get_tree().quit()
