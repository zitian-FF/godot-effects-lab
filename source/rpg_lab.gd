extends Node2D
const Catalog=preload("res://rpg_catalog.gd")
const Renderer=preload("res://rpg_renderer.gd")
const AstraRenderer=preload("res://rpg_astra.gd")
const WHITE=Color("e5edf8")
const MUTED=Color("8c9eb4")
var selected=0
var playhead=0.0
var playing=true
var speed=1.0
var size_multiplier=.9
var intensity=1.0
var seed_value=17
var light_stage=false
var context_on=true
var capture_active=false
var renderer:Node2D
var astra:Node2D
var comparison_mode=2
var comparison_buttons:Array[Button]=[]
var comparison_labels:Array[Label]=[]
var effect_buttons:Array[Button]=[]
var toggles:Array[CheckButton]=[]
var title_label:Label
var source_label:Label
var phase_label:Label
var time_label:Label
var seed_label:Label
var inspector:RichTextLabel
var timeline:HSlider
var pause_button:Button
func label_at(text:String,p:Vector2,font:int=16,col:Color=WHITE,width:float=700)->Label:
	var l=Label.new();l.text=text;l.position=p;l.size=Vector2(width,40)
	l.add_theme_font_size_override("font_size",font);l.add_theme_color_override("font_color",col)
	add_child(l);return l
func style(bg:Color,border:Color)->StyleBoxFlat:
	var s=StyleBoxFlat.new();s.bg_color=bg;s.border_color=border;s.set_border_width_all(1);s.set_corner_radius_all(8);s.content_margin_left=12;s.content_margin_right=12;return s
func button_at(text:String,p:Vector2,size_:Vector2,fn:Callable)->Button:
	var b=Button.new();b.text=text;b.position=p;b.size=size_;b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	b.add_theme_font_size_override("font_size",15);b.add_theme_color_override("font_color",WHITE)
	b.add_theme_stylebox_override("normal",style(Color("152033"),Color("2a3b52")))
	b.add_theme_stylebox_override("hover",style(Color("2b4058"),Color("8aaac5")))
	b.add_theme_stylebox_override("pressed",style(Color("3a5068"),Color("c2deed")))
	b.pressed.connect(fn);add_child(b);return b
func slider_at(p:Vector2,w:float,lo:float,hi:float,value:float,fn:Callable)->HSlider:
	var s=HSlider.new();s.position=p;s.size=Vector2(w,30);s.min_value=lo;s.max_value=hi;s.step=.001;s.value=value;s.value_changed.connect(fn);add_child(s);return s
func _ready():
	label_at("FX /",Vector2(25,25),30,Color("a9dfef"))
	label_at("ELEMENTAL ATELIER",Vector2(108,30),24)
	label_at("08 HYBRID EFFECTS  /  RPG RECONSTRUCTION",Vector2(685,37),12,MUTED)
	label_at("ROUND 03 · GODOT",Vector2(1400,37),12,MUTED,190)
	label_at("SPELL / COMBAT LIBRARY",Vector2(20,115),11,MUTED,210)
	for k in range(8):
		var i=k
		var b=button_at("%02d  %s"%[k+1,Catalog.SHORT[k]],Vector2(20,156+k*65),Vector2(185,53),func():select_effect(i))
		b.alignment=HORIZONTAL_ALIGNMENT_LEFT;effect_buttons.append(b)
	button_at("Show peak",Vector2(20,714),Vector2(185,40),func():seek(Catalog.PEAKS[selected]))
	button_at("Source reference ↗",Vector2(20,767),Vector2(185,40),func():OS.shell_open(Catalog.URLS[selected]))
	label_at("1–8   Select\nSpace   Replay\nP   Pause / resume",Vector2(23,842),13,MUTED,195)
	title_label=label_at("",Vector2(252,125),28)
	for i in range(3):
		var mode=i
		comparison_buttons.append(button_at(["Baseline","Astra attempt","A/B"][i],Vector2([766,875,1032][i],130),Vector2([100,148,80][i],35),func():set_comparison(mode)))
	source_label=label_at("",Vector2(253,170),14,MUTED,880)
	phase_label=label_at("",Vector2(257,738),12,MUTED,840)
	label_at("LAYER BREAKDOWN",Vector2(245,803),11,MUTED,185)
	for i in range(3):
		var n=i
		var c=CheckButton.new();c.text=["Sprite","Shader","Particles"][i];c.position=Vector2(422+i*225,795);c.button_pressed=true
		c.toggled.connect(func(_v):update_layers());add_child(c);toggles.append(c)
		button_at("Solo",Vector2(560+i*225,800),Vector2(60,30),func():solo(n))
	button_at("All",Vector2(1090,800),Vector2(38,30),all_layers)
	label_at("PLAYHEAD",Vector2(245,853),11,MUTED)
	time_label=label_at("",Vector2(1030,846),15,WHITE,90)
	timeline=slider_at(Vector2(246,883),868,0,2,0,func(v):seek(v))
	pause_button=button_at("Pause",Vector2(245,925),Vector2(95,40),func():playing=not playing;update_play_button())
	button_at("Replay",Vector2(352,925),Vector2(95,40),replay)
	button_at("New seed",Vector2(460,925),Vector2(110,40),func():seed_value+=1;renderer.configure(selected,seed_value);astra.configure(1,seed_value))
	var rate=OptionButton.new();rate.position=Vector2(587,925);rate.size=Vector2(100,40)
	for s in ["0.25×","0.5×","1×"]:rate.add_item(s)
	rate.select(2);rate.item_selected.connect(func(i):speed=[.25,.5,1.0][i]);add_child(rate)
	seed_label=label_at("",Vector2(708,935),12,MUTED,200)
	label_at("COMPOSITION INSPECTOR",Vector2(1160,119),12,MUTED,410)
	inspector=RichTextLabel.new();inspector.position=Vector2(1160,159);inspector.size=Vector2(406,598);inspector.bbcode_enabled=true
	inspector.add_theme_font_size_override("normal_font_size",16);inspector.add_theme_font_size_override("bold_font_size",16)
	inspector.add_theme_color_override("default_color",Color("c2d0df"));inspector.add_theme_constant_override("line_separation",5)
	inspector.meta_clicked.connect(func(url):OS.shell_open(str(url)));add_child(inspector)
	label_at("SCALE",Vector2(1160,788),11,MUTED,120)
	slider_at(Vector2(1160,818),395,.65,1.1,.9,func(v):size_multiplier=v)
	label_at("ENERGY",Vector2(1160,857),11,MUTED,120)
	slider_at(Vector2(1160,885),395,.4,1.25,1,func(v):intensity=v)
	var bg=CheckButton.new();bg.text="Light stage";bg.position=Vector2(1155,932);bg.toggled.connect(func(v):light_stage=v);add_child(bg)
	var context=CheckButton.new();context.text="Context";context.position=Vector2(1415,932);context.button_pressed=true;context.toggled.connect(func(v):context_on=v);add_child(context)
	var clip=Control.new();clip.position=Vector2(235,210);clip.size=Vector2(895,570);clip.clip_contents=true;clip.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(clip)
	renderer=Renderer.new();renderer.position=Vector2(447,280);clip.add_child(renderer)
	astra=AstraRenderer.new();astra.position=Vector2(447,280);clip.add_child(astra);astra.configure(1,seed_value)
	comparison_labels.append(label_at("BASELINE",Vector2(253,220),11,MUTED,700))
	comparison_labels.append(label_at("ASTRA ATTEMPT",Vector2(253,490),11,Color("c1a1ff"),700))
	for l in comparison_labels:l.z_index=5
	select_effect(0)
	if "--self-test" in OS.get_cmdline_user_args():self_test.call_deferred()
	if "--capture" in OS.get_cmdline_user_args():capture.call_deferred()
	if "--seek-test" in OS.get_cmdline_user_args():seek_test.call_deferred()
	if "--motion-capture" in OS.get_cmdline_user_args():motion_capture.call_deferred()
	if "--astra-capture" in OS.get_cmdline_user_args():astra_capture.call_deferred()
	if "--astra-motion" in OS.get_cmdline_user_args():astra_motion.call_deferred()
	if "--astra-test" in OS.get_cmdline_user_args():astra_test.call_deferred()
	if "--astra-seek-test" in OS.get_cmdline_user_args():astra_seek_test.call_deferred()
func set_comparison(mode:int):
	comparison_mode=mode
	update_comparison()
func update_comparison():
	var electric=selected==1
	for b in comparison_buttons:b.visible=electric
	for i in range(3):
		comparison_buttons[i].add_theme_stylebox_override("normal",style(Color("392953") if i==comparison_mode else Color("152033"),Color("b89aea") if i==comparison_mode else Color("2a3b52")))
	renderer.visible=not electric or comparison_mode!=1
	astra.visible=electric and comparison_mode!=0
	var dual=electric and comparison_mode==2
	renderer.position=Vector2(447,145 if dual else 280)
	astra.position=Vector2(447,410 if dual else 280)
	for l in comparison_labels:l.visible=dual
	if electric:
		source_label.text="Genshin · Raiden Shogun  /  same 1.20 s clock, strike 0.26 s, seed and layer controls"
		inspector.text=astra_inspector() if comparison_mode!=0 else Catalog.inspector(1)
		inspector.scroll_to_line(0)
func astra_inspector()->String:
	return "[color=#bda3ed]ELECTRIC / A–B STUDY[/color]\n\n[b]Baseline / Astra attempt[/b]\nBoth run on the same clock, seed, scale and energy. Switching views keeps the current playhead. A/B fits both into equal stage space.\n\n[b]Reference[/b]\nGenshin · Raiden Shogun official demo. Violet-white release and cyan fringe in the burst / sword sequence.\n[url=https://www.youtube.com/watch?v=mvrW4aKwAXw&t=99s]Open source reference ↗[/url]\n\n[b]01 · Authored sprites[/b]\nSeparate calligraphic lids, rotating three-part iris, a torn blade plane and its displaced echo.\n\n[b]02 · Shader energy[/b]\nDark aperture, contracting eye, a white incision, violet torn edges and delayed branching discharge.\n\n[b]03 · GPU particle motion[/b]\nTwo opposing sprays leave the entire seam. Slower, rotating shards carry the residual motion after the blade is gone.\n\n[b]Timing[/b]\nEye opens 0.00–0.18 s; shears through the strike until 0.35 s. Cut traverses in 0.033 s; particles begin at 0.285 s. Recovery ends at 1.20 s.\n\n[b]Layer controls[/b]\nMute and Solo affect both versions together. Shader mute removes the energy field and restores flat sprite shading.\n\n[b]Similarity & limits[/b]\nOriginal isolated 2.5D motif study. Timing is compressed to the existing lab cycle. This does not reproduce the character, full-screen cinematic, camera cuts or exact game animation. No reference footage or extracted assets are included."
func select_effect(k:int):
	selected=k;playhead=0;playing=true
	title_label.text=Catalog.NAMES[k];title_label.add_theme_color_override("font_color",Catalog.COLORS[k])
	source_label.text=Catalog.SOURCES[k]+"  ·  sprite silhouette + shader material + particle motion"
	inspector.text=Catalog.inspector(k);inspector.scroll_to_line(0)
	timeline.max_value=Catalog.DURATIONS[k]
	renderer.configure(k,seed_value)
	if k==1:astra.configure(1,seed_value)
	update_comparison()
	all_layers()
	for i in range(8):effect_buttons[i].add_theme_stylebox_override("normal",style(Color("263448") if i==k else Color("111b2c"),Catalog.COLORS[i] if i==k else Color("293b50")))
	update_play_button()
func update_layers():
	renderer.sprites_on=toggles[0].button_pressed;renderer.shaders_on=toggles[1].button_pressed;renderer.particles_on=toggles[2].button_pressed
	renderer.last_time=-1
	astra.sprites_on=toggles[0].button_pressed;astra.shaders_on=toggles[1].button_pressed;astra.particles_on=toggles[2].button_pressed
	astra.last_time=-1
func solo(n:int):
	for i in range(3):toggles[i].set_pressed_no_signal(i==n)
	update_layers()
func all_layers():
	for c in toggles:c.set_pressed_no_signal(true)
	update_layers()
func seek(t:float):playhead=t;playing=false;update_play_button()
func replay():playhead=0;playing=true;renderer.last_time=-1;astra.last_time=-1;update_play_button()
func update_play_button():pause_button.text="Pause" if playing else "Play"
func _process(delta):
	if not renderer:return
	if playing and not capture_active:
		playhead+=delta*speed
		if playhead>Catalog.DURATIONS[selected]+.65:playhead=0
	var view_scale=size_multiplier*(.72 if selected==1 and comparison_mode==2 else 1.)
	renderer.sample(playhead,view_scale,intensity)
	if selected==1:astra.sample(playhead,view_scale,intensity)
	timeline.set_value_no_signal(minf(playhead,Catalog.DURATIONS[selected]))
	time_label.text="%.2f s"%playhead;seed_label.text="SEED  %d"%seed_value
	phase_label.text="ANTICIPATION" if playhead<Catalog.STRIKES[selected] else ("STRIKE / CONTACT" if playhead<Catalog.STRIKES[selected]+.18 else "RECOVERY / DISSIPATION")
	queue_redraw()
func _unhandled_input(e):
	if e is InputEventKey and e.pressed and not e.echo:
		if e.keycode>=KEY_1 and e.keycode<=KEY_8:select_effect(e.keycode-KEY_1)
		elif e.keycode==KEY_SPACE:replay()
		elif e.keycode==KEY_P:playing=not playing;update_play_button()
func _draw():
	draw_rect(Rect2(0,0,1600,1000),Color("080d16"));draw_rect(Rect2(0,88,222,912),Color("0d1521"));draw_rect(Rect2(1142,88,458,912),Color("0d1521"))
	draw_line(Vector2(0,88),Vector2(1600,88),Color("29394c"))
	var bg=Color("8795a4") if light_stage else Color("111c2b")
	draw_style_box(style(bg,Color("293e52")),Rect2(235,210,895,570))
	if selected==1 and comparison_mode==2:
		draw_line(Vector2(250,480),Vector2(1115,480),Color("354053"),1)
		for cy in [355.,620.]:
			for x in range(270,1130,105):draw_line(Vector2(682,cy+15),Vector2(x,cy+110),Color(.35,.5,.65,.12))
			for y in [cy+35,cy+65,cy+105]:draw_line(Vector2(250,y),Vector2(1115,y),Color(.35,.5,.65,.12))
			if context_on:comparison_target(Vector2(820,cy+52),.65,Color("536a7d") if not light_stage else Color("465563"))
		return
	var linecol=Color(.35,.5,.65,.14)
	for y in [570,610,664,735]:draw_line(Vector2(250,y),Vector2(1115,y),linecol)
	for x in range(270,1130,85):draw_line(Vector2(682,460),Vector2(x,770),linecol)
	if context_on and not (selected==1 and comparison_mode==2):
		var target=Vector2(872,565)
		if selected in [2,3,7]:target=Vector2(682,600)
		var c=Color("536a7d") if not light_stage else Color("465563")
		draw_set_transform(target)
		stage_ellipse(Vector2(0,15),Vector2(25,8),Color(0,0,0,.2))
		draw_circle(Vector2(0,-98),12,c)
		draw_colored_polygon(PackedVector2Array([Vector2(-17,-80),Vector2(18,-80),Vector2(13,-33),Vector2(-12,-33)]),Color(c,.45))
		for pair in [[Vector2(-16,-76),Vector2(-30,-40)],[Vector2(17,-76),Vector2(32,-40)],[Vector2(-8,-33),Vector2(-15,6)],[Vector2(9,-33),Vector2(17,6)]]:draw_line(pair[0],pair[1],c,5,true)
		draw_set_transform(Vector2.ZERO)
		if selected in [0,1,4,5,6]:
			draw_circle(Vector2(485,490),5,Color("a1b3bf"));draw_line(Vector2(465,490),Vector2(500,490),Color("8096ab"),2)
			if selected==6:draw_line(Vector2(450,490),Vector2(615,490),Color("526778"),9)
func stage_ellipse(p:Vector2,s:Vector2,c:Color):
	var points=PackedVector2Array()
	for i in range(48):points.append(p+Vector2(cos(i*TAU/48),sin(i*TAU/48))*s)
	draw_colored_polygon(points,c)
func comparison_target(p:Vector2,zoom:float,c:Color):
	draw_set_transform(p,0,Vector2.ONE*zoom)
	stage_ellipse(Vector2(0,15),Vector2(25,8),Color(0,0,0,.2))
	draw_circle(Vector2(0,-98),12,c)
	draw_colored_polygon(PackedVector2Array([Vector2(-17,-80),Vector2(18,-80),Vector2(13,-33),Vector2(-12,-33)]),Color(c,.45))
	for pair in [[Vector2(-16,-76),Vector2(-30,-40)],[Vector2(17,-76),Vector2(32,-40)],[Vector2(-8,-33),Vector2(-15,6)],[Vector2(9,-33),Vector2(17,6)]]:draw_line(pair[0],pair[1],c,5,true)
	draw_set_transform(Vector2.ZERO)
func self_test():
	capture_active=true
	for k in range(8):
		select_effect(k);seek(Catalog.PEAKS[k]);renderer.sample(playhead,.9,1)
		assert(renderer.cards.size()>=2 and renderer.emitters.size()>=1 and renderer.field_material.shader!=null)
		for s in renderer.cards:assert(s.texture!=null and s.material is ShaderMaterial)
		for e in renderer.emitters:assert(e.texture!=null and e.process_material is ParticleProcessMaterial and e.use_fixed_seed)
		var held=playhead
		for i in range(3):solo(i);assert(playhead==held and not playing)
		all_layers()
		for t in [.01,.1,.3,.65,.1]:renderer.sample(t,.9,1)
		assert(inspector.text.contains("Similarity"))
	print("PASS: 8 composed effects, actual sprite/shader/particle layers, textures, isolation holds time, seek/replay, inspector")
	get_tree().quit()
func shot(path:String):
	await get_tree().process_frame;await RenderingServer.frame_post_draw
	await get_tree().process_frame;await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
func capture():
	capture_active=true
	var args=OS.get_cmdline_user_args();var out=args[args.find("--capture")+1];DirAccess.make_dir_recursive_absolute(out)
	for k in range(8):
		select_effect(k);seek(Catalog.PEAKS[k])
		await shot(out.path_join("%d-full.png"%k))
		for i in range(3):
			solo(i);await shot(out.path_join("%d-solo%d.png"%[k,i]))
			all_layers();toggles[i].set_pressed_no_signal(false);update_layers();await shot(out.path_join("%d-mute%d.png"%[k,i]));all_layers()
		for j in range(5):
			seek([Catalog.STRIKES[k]*.65,Catalog.STRIKES[k]+.03,Catalog.PEAKS[k],Catalog.PEAKS[k]+.3,Catalog.DURATIONS[k]*.82][j]);renderer.last_time=-1
			await shot(out.path_join("%d-phase%d.png"%[k,j]))
		light_stage=true;seek(Catalog.PEAKS[k]);renderer.last_time=-1;await shot(out.path_join("%d-light.png"%k));light_stage=false
	print("CAPTURED: 8 full, 24 solos,24 mutes,40 phases,8 light views")
	get_tree().quit()
func settled()->Image:
	await get_tree().process_frame;await RenderingServer.frame_post_draw
	await get_tree().process_frame;await RenderingServer.frame_post_draw
	return get_viewport().get_texture().get_image().get_region(Rect2i(235,210,895,570))
func motion_capture():
	capture_active=true
	var args=OS.get_cmdline_user_args();var out=args[args.find("--motion-capture")+1];DirAccess.make_dir_recursive_absolute(out)
	for k in range(8):
		select_effect(k);playing=false
		for frame in range(48):
			playhead=float(frame)/47.0*Catalog.DURATIONS[k]
			await shot(out.path_join("%d-%02d.png"%[k,frame]))
	print("CAPTURED: 8 complete animated sequences,48 frames each")
	get_tree().quit()
func seek_test():
	capture_active=true;var failed=0
	for k in range(8):
		select_effect(k);solo(2);seek(Catalog.PEAKS[k]);var first=await settled()
		seek(Catalog.PEAKS[k]+.3);await settled();seek(Catalog.PEAKS[k]);var second=await settled()
		if first.get_data()!=second.get_data():failed+=1;print("DIFFERENCE: ",k)
	print("HYBRID PARTICLE SEEK: ",8-failed,"/8 pixel-identical")
	get_tree().quit(0 if failed==0 else 1)
func astra_capture():
	capture_active=true
	var args=OS.get_cmdline_user_args();var out=args[args.find("--astra-capture")+1];DirAccess.make_dir_recursive_absolute(out)
	select_effect(1);playing=false
	for mode in range(3):
		set_comparison(mode)
		for j in range(6):
			seek([.13,.235,.29,.36,.55,.82][j]);renderer.last_time=-1;astra.last_time=-1
			await shot(out.path_join("mode%d-phase%d.png"%[mode,j]))
	set_comparison(1);seek(.36)
	for i in range(3):
		solo(i);await shot(out.path_join("astra-solo%d.png"%i));all_layers()
		toggles[i].set_pressed_no_signal(false);update_layers();await shot(out.path_join("astra-mute%d.png"%i));all_layers()
	light_stage=true;seek(.13);await shot(out.path_join("astra-light-eye.png"));seek(.36);await shot(out.path_join("astra-light-cut.png"))
	print("CAPTURED: Electric baseline / Astra / A-B phases, 3 solos, 3 mutes and 2 light views")
	get_tree().quit()
func astra_motion():
	capture_active=true
	var args=OS.get_cmdline_user_args();var out=args[args.find("--astra-motion")+1];DirAccess.make_dir_recursive_absolute(out)
	select_effect(1);set_comparison(2);playing=false
	for frame in range(73):
		playhead=float(frame)/60.
		await shot(out.path_join("ab-%03d.png"%frame))
	print("CAPTURED: 73 Electric A-B frames at 60 fps, same clock and seed")
	get_tree().quit()
func astra_test():
	capture_active=true;select_effect(1);seek(.36)
	assert(astra.cards.size()==4 and astra.emitters.size()==3)
	for mode in range(3):
		set_comparison(mode);assert(playhead==.36 and not playing)
		assert(renderer.visible==(mode!=1) and astra.visible==(mode!=0))
	for i in range(3):
		solo(i);assert(playhead==.36 and not playing)
		assert(renderer.sprites_on==astra.sprites_on and renderer.shaders_on==astra.shaders_on and renderer.particles_on==astra.particles_on)
	all_layers()
	for e in astra.emitters:assert(e.use_fixed_seed and e.texture!=null and e.process_material is ParticleProcessMaterial)
	for k in [0,2,3,4,5,6,7]:
		select_effect(k);assert(renderer.visible and not astra.visible)
		for b in comparison_buttons:assert(not b.visible)
	print("PASS: Electric A-B preserves clock and layer parity; 4 authored sprites / 2 shaders / 3 seeded GPU sprays; other seven use baseline renderer")
	get_tree().quit()
func astra_seek_test():
	capture_active=true;select_effect(1);set_comparison(1);solo(2)
	var failed=0
	for t in [.31,.45,.7]:
		seek(t);var first=await settled()
		seek(t+.27);await settled();seek(t);var second=await settled()
		if first.get_data()!=second.get_data():failed+=1;print("ASTRA DIFFERENCE: ",t)
	print("ASTRA PARTICLE SEEK: ",3-failed,"/3 pixel-identical")
	get_tree().quit(0 if failed==0 else 1)
