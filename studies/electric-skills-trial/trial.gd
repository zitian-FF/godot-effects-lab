extends "res://motion_guide.gd"
const Effect=preload("res://effect.gd")
var fx:Node2D
var guide_mode=false
var pass_choice:OptionButton
var detail:RichTextLabel
func _ready():
	super._ready()
	debug_on=false
	fx=Effect.new();fx.guide=self;add_child(fx)
	for node in get_children():
		if node is Label:
			if node.text=="02   Motion & silhouette blockout":node.text="03   Electric / skills trial";node.add_theme_font_size_override("font_size",28)
			elif node.text.begins_with("WORK IN PROGRESS"):node.text="Brush texture + shader ribbon + contact sprite + GPU particles"
			elif node.text=="PASS GATE":node.text="REVIEW THE EFFECT"
			elif node.text=="Visual review pending.\nNo final materials or particles.":node.text="Authored trial, not a game replica.\nNo character-animation changes."
			elif node.text=="Contact / path overlays":node.text="FIXED ATTACK GUIDE / 0.30 s CONTACT"
			elif node.text=="Cinematic framing replaced with a weapon-driven attack":node.text="Same motion for Guide / Skills trial. Inspect each contribution in the menu."
		if node is CheckButton:
			if node.text=="Path / contact":node.set_pressed_no_signal(false)
			elif node.text=="Slash mass":node.text="VFX enabled"
		if node is RichTextLabel:detail=node
		if node is Button and node.text=="Contact":
			node.text="VFX peak";node.pressed.connect(func():seek(.315))
	button("Guide",Vector2(651,55),90,func():seek(age);guide_mode=true;update_notes())
	button("Skills trial",Vector2(750,55),120,func():seek(age);guide_mode=false;update_notes())
	pass_choice=OptionButton.new();pass_choice.position=Vector2(650,96);pass_choice.size=Vector2(220,29)
	for item in ["01 Brush mask","02 Shader material","03 Add electricity / impact","04 Full composition","Particles solo","Contact / electricity solo"]:pass_choice.add_item(item)
	pass_choice.select(3);pass_choice.item_selected.connect(func(i):seek(age);fx.pass_index=i;fx.last_age=-1;update_notes());add_child(pass_choice)
	update_notes()
	if "--trial-capture" in OS.get_cmdline_user_args():trial_capture.call_deferred()
	if "--trial-check" in OS.get_cmdline_user_args():trial_check.call_deferred()
func update_notes():
	if not detail:return
	detail.text="[b]%s[/b]\n%s\n\n[b]01 Brush silhouette[/b]\nOne generated grayscale dry-brush alpha mask maps onto the blade's curved path. The broad mass carries the attack.\n\n[b]02 Shader material[/b]\nViolet body, a restrained pale edge and directional erosion. Time is an explicit uniform so scrubbing remains stable.\n\n[b]03 Contact / electricity[/b]\nA short sprite flash at contact, one uneven arc on the blade path, and three unequal branches near the target.\n\n[b]04 Detached motion[/b]\n18 fast streaks and 12 slower flecks use seeded GPUParticles2D with drag, alpha and scale curves.\n\n[b]Skill contributions[/b]\nScenario: layered systems / capture checks. Godot particles: restart, coordinate space, one-shot lifecycle. Godot shaders: UV sampling, uniforms and dissolve.\n\n[b]Scope[/b]\nOriginal 2D Web adaptation. Scenario's stock 3D recipes are not used unchanged. The fixed motion guide is preserved. This is not an exact Raiden recreation."%["Guide / previous blockout" if guide_mode else pass_choice.get_item_text(pass_choice.selected),"The grayscale crescent is retained for comparison." if guide_mode else "Compare at the same time with the Guide button. Choose a layer pass above the stage."]
func slash_mass():
	if guide_mode:super.slash_mass()
func _process(delta):
	super._process(delta)
	if fx:fx.sample(age,trail_on and not guide_mode)
func trial_check():
	capture_active=true;seek(.32)
	assert(fx.emitters.size()==2 and fx.flash is Sprite2D)
	var held=age
	for mode in range(6):
		fx.pass_index=mode;fx.sample(age,true);assert(age==held and not playing)
	for e in fx.emitters:
		assert(e.one_shot and e.use_fixed_seed and not e.local_coords and e.texture!=null)
		assert(e.visibility_rect.encloses(Rect2(-250,-180,500,360)))
	assert(tip(CONTACT).distance_to(TARGET)<2)
	print("PASS: 6 VFX passes preserve time; sprite/shader/2 seeded GPU particle layers; contact and motion guide preserved")
	get_tree().quit()
func trial_capture():
	capture_active=true;playing=false
	var args=OS.get_cmdline_user_args();var out=args[args.find("--trial-capture")+1];DirAccess.make_dir_recursive_absolute(out)
	for i in range(70):
		age=float(i)/60.;fx.sample(age,true);await shot(out.path_join("frame-%03d.png"%i))
	for i in range(6):
		age=[.24,.28,.315,.36,.43,.55][i];fx.last_age=-1;fx.sample(age,true);await shot(out.path_join("phase-%d.png"%i))
	age=.315
	for mode in range(6):
		fx.pass_index=mode;pass_choice.select(mode);update_notes();fx.last_age=-1;fx.sample(age,true);await shot(out.path_join("pass-%d.png"%mode))
	fx.pass_index=3;pass_choice.select(3);guide_mode=true;update_notes();await shot(out.path_join("guide-contact.png"))
	guide_mode=false;update_notes();await shot(out.path_join("full-contact.png"))
	# Backward particle seek is checked on a particle-only stage crop.
	fx.pass_index=4;pass_choice.select(4)
	for t in [.33,.42,.60]:
		age=t;fx.last_age=-1;await shot(out.path_join("seek-%.2f-a.png"%t))
		age=t+.2;await get_tree().process_frame
		age=t;await shot(out.path_join("seek-%.2f-b.png"%t))
	print("CAPTURED: 70 motion frames, 6 phases, 6 passes, comparison and 3 seek pairs")
	get_tree().quit()
