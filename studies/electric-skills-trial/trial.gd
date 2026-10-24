extends "res://motion_guide.gd"
const Effect=preload("res://effect.gd")
var fx:Node2D
var guide_mode=false
var pass_choice:OptionButton
var detail:RichTextLabel
var asset_board:Control
var board_picture:TextureRect
const ASSET_BOARD=preload("res://art/designed/asset-board.png")
const UV_BOARD=preload("res://art/designed/topology-uv.png")
const PASS_NAMES=["00 Asset design board","01 Crescent mask","02 Distorted material","03 Needle sparks","04 Chip sparks","05 Composition","06 Mesh / UV diagram"]

func _ready():
	super._ready()
	debug_on=false
	fx=Effect.new();fx.guide=self;add_child(fx)
	for node in get_children():
		if node is Label:
			if node.text=="02   Motion & silhouette blockout":node.text="04   Slash assets / production";node.add_theme_font_size_override("font_size",28)
			elif node.text.begins_with("WORK IN PROGRESS"):node.text="Crescent mesh / mask / distortion / two designed spark shapes"
			elif node.text=="PASS GATE":node.text="ASSET FIRST / THEN COMPOSE"
			elif node.text=="Visual review pending.\nNo final materials or particles.":node.text="One slash, two spark silhouettes.\nFixed character motion."
			elif node.text=="Contact / path overlays":node.text="FIXED ATTACK GUIDE / 0.30 s CONTACT"
			elif node.text=="Cinematic framing replaced with a weapon-driven attack":node.text="Asset board shows the source shapes. Production shows their actual use."
		if node is CheckButton:
			if node.text=="Path / contact":node.set_pressed_no_signal(false)
			elif node.text=="Slash mass":node.text="VFX enabled"
		if node is RichTextLabel:detail=node
		if node is Button and node.text=="Contact":
			node.text="VFX peak";node.pressed.connect(func():seek(.315);set_pass(5))
	button("Assets",Vector2(550,55),92,func():set_pass(0))
	button("Guide",Vector2(651,55),90,func():seek(age);guide_mode=true;update_notes())
	button("Production",Vector2(750,55),120,func():guide_mode=false;set_pass(5))
	pass_choice=OptionButton.new();pass_choice.position=Vector2(650,96);pass_choice.size=Vector2(220,29)
	for item in PASS_NAMES:pass_choice.add_item(item)
	pass_choice.select(5);pass_choice.item_selected.connect(set_pass);add_child(pass_choice)
	var distort=CheckButton.new();distort.text="Distortion";distort.position=Vector2(720,145);distort.button_pressed=true
	distort.toggled.connect(func(v):seek(age);fx.distortion_enabled=v);add_child(distort)
	asset_board=ColorRect.new();asset_board.position=Vector2(24,132);asset_board.size=Vector2(886,468);asset_board.color=Color("11151c");asset_board.mouse_filter=Control.MOUSE_FILTER_IGNORE;asset_board.z_index=10;add_child(asset_board)
	board_picture=TextureRect.new();board_picture.texture=ASSET_BOARD;board_picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;board_picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;board_picture.size=asset_board.size;board_picture.mouse_filter=Control.MOUSE_FILTER_IGNORE;asset_board.add_child(board_picture)
	asset_board.visible=false
	update_notes()
	if "--trial-capture" in OS.get_cmdline_user_args():trial_capture.call_deferred()
	if "--trial-check" in OS.get_cmdline_user_args():trial_check.call_deferred()

func set_pass(index:int):
	seek(age);guide_mode=false;fx.pass_index=index;pass_choice.select(index);fx.last_age=-1;update_notes()
	if board_picture:board_picture.texture=UV_BOARD if index==6 else ASSET_BOARD

func person(root:Vector2,value:float,lean:float,armed:bool):
	# Neutralize the old proxy hit flash without altering its pose or motion.
	super.person(root,value if armed else minf(value,.52),lean,armed)

func update_notes():
	if not detail:return
	detail.text="[b]%s[/b]\n%s\n\n[b]01 Crescent asset[/b]\nA designed crescent mask and separate thin edge map onto an annular support mesh. UVs use the texture's XY space. This is a crescent texture, not a bent straight brush.\n\n[b]02 Mesh and anchor[/b]\n48 angular segments / 2 radial rows. The designed head at -26 degrees, radius 520 px, is aligned to the fixed blade tip.\n\n[b]03 Distortion[/b]\nSmall UV displacement adds movement inside the mask. It fades to zero at both tips so the head anchor remains stable. Reveal and late erosion are separate controls.\n\n[b]04 Needle spark[/b]\nA long tapered sliver reads as a quick directional spark. Seven velocity-aligned sprites leave contact and fade quickly.\n\n[b]05 Chip spark[/b]\nA broader irregular fragment reads as detached material. Four slower sprites rotate and fall slightly. Their emitter behavior was chosen after their shape.\n\n[b]Composition[/b]\nThe crescent is primary; its pale edge guides the eye. Needles provide the short contact accent; chips finish the exit. No extra star flash or repeated bolt lines.\n\n[b]Scope[/b]\nOriginal authored assets and proposed production choices, not extracted game assets or facts about Genshin's pipeline. The character animation is unchanged."%["Guide / previous blockout" if guide_mode else PASS_NAMES[fx.pass_index],"Compare the underlying attack motion at the same time." if guide_mode else "Assets -> mask -> distorted material -> individual sparks -> composition. Switching views holds time."]

func slash_mass():
	if guide_mode:super.slash_mass()

func _process(delta):
	super._process(delta)
	if fx:fx.sample(age,trail_on and not guide_mode)
	if asset_board:asset_board.visible=not guide_mode and fx.pass_index in [0,6]

func trial_check():
	capture_active=true;seek(.32)
	assert(fx.emitters.size()==2 and fx.surface.mesh!=null)
	var held=age
	for mode in range(7):
		fx.pass_index=mode;fx.sample(age,true);assert(age==held and not playing)
	assert(fx.emitters[0].texture!=fx.emitters[1].texture)
	for e in fx.emitters:
		assert(e.one_shot and e.use_fixed_seed and not e.local_coords and e.texture!=null)
	assert(tip(CONTACT).distance_to(TARGET)<2)
	var local_head=Vector2(cos(deg_to_rad(-26.)),sin(deg_to_rad(-26.)))*520.
	var rotated=local_head.rotated(angle(CONTACT)-deg_to_rad(-26.))*REACH/520.
	var placed=hand(CONTACT)+Vector2(rotated.x,rotated.y*.58)
	assert(placed.distance_to(tip(CONTACT))<.01)
	print("PASS: designed mask head aligns to fixed blade; two distinct spark textures; seven views preserve time")
	get_tree().quit()

func trial_capture():
	capture_active=true;playing=false
	var args=OS.get_cmdline_user_args();var out=args[args.find("--trial-capture")+1];DirAccess.make_dir_recursive_absolute(out)
	for i in range(70):
		age=float(i)/60.;fx.sample(age,true);await shot(out.path_join("frame-%03d.png"%i))
	for i in range(6):
		age=[.24,.28,.315,.36,.40,.48][i];fx.last_age=-1;fx.sample(age,true);await shot(out.path_join("phase-%d.png"%i))
	age=.315
	for mode in range(6):
		fx.pass_index=mode;pass_choice.select(mode);update_notes();fx.last_age=-1;fx.sample(age,true);await shot(out.path_join("pass-%d.png"%mode))
	fx.pass_index=5;pass_choice.select(5);guide_mode=true;update_notes();await shot(out.path_join("guide-contact.png"))
	guide_mode=false;update_notes();await shot(out.path_join("full-contact.png"))
	for t in [.33,.39,.48]:
		age=t;fx.last_age=-1;await shot(out.path_join("seek-%.2f-a.png"%t))
		age=t+.2;await get_tree().process_frame
		age=t;await shot(out.path_join("seek-%.2f-b.png"%t))
	print("CAPTURED: 70 motion frames, 6 phases, asset/layer passes, comparison and 3 full-composition seek pairs")
	get_tree().quit()
