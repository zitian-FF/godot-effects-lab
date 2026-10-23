extends RefCounted

const NAMES = ["Fire", "Electric", "Ice", "Healing", "Slash", "Stab", "Muzzle flash", "Explosion"]
const KEYS = ["fire", "electric", "ice", "healing", "slash", "stab", "muzzle", "explosion"]
const COLORS = [Color("ff9a45"), Color("8fbaff"), Color("8ce6ff"), Color("78e5b3"), Color("c4adff"), Color("ffe1aa"), Color("ffd08a"), Color("f89457")]
const DURATIONS = [1.8, 1.2, 2.0, 2.0, 1.1, 0.8, 0.6, 1.9]
const METHODS = ["Sprite", "Particles", "Shader"]
const ANIMATED = [false, true, true, false, true, false, false, true]
const BASE_TEXTURES = ["flame-imagegen-512.png", "", "", "magic_05.png", "", "trace_03.png", "muzzle_01.png", ""]
const PICKS = [[2,0], [0,2], [0,0], [2,0], [2,1], [0,2], [0,1], [2,0]]
const MUTATIONS = [
	[["Painted plume", "Graphic flame", "Torch stamp"], ["Flame billboards", "Ember fountain", "Blue torch"], ["Noise plume", "Sideways jet", "Ghost orb"]],
	[["Plasma discharge", "Electric sigil", "Arc stamp"], ["Charged motes", "Spark spray", "Ion stream"], ["Forked bolt", "Radial discharge", "Chain arc"]],
	[["Crystal eruption", "Shard fan", "Frost glints"], ["Crystal chips", "Snow drift", "Ice jet"], ["Shard cluster", "Frost crown", "Glacial spear"]],
	[["Radiant seal", "Magic seal", "Spiral stamp"], ["Rising stars", "Restoration cloud", "Golden fountain"], ["Orbiting halo", "Restoration pool", "Ribbon ascent"]],
	[["Painted crescent", "Blade stamp", "Double cut"], ["Blade fragments", "Cutting sparks", "Ribbon spray"], ["Dissolving crescent", "Twin arc", "Triple scratch"]],
	[["Thrust card", "Needle stamp", "Heavy lance"], ["Impact streaks", "Forward spray", "Piercing stream"], ["Needle thrust", "Diagonal lance", "Triple pierce"]],
	[["Short flash", "Rifle stamp", "Wide flash"], ["Hot gas burst", "Brass sparks", "Plasma jet"], ["Gas cone", "Compensator ports", "Plasma flash"]],
	[["Wan fire bloom", "Dust stamp", "Graphic blast"], ["Fire & smoke", "Dust detonation", "Fragment blast"], ["Turbulent fireball", "Dust cloud", "Void detonation"]]
]
const TEXTURES = [
	["fire_01.png", "flame_05.png"], ["magic_04.png", "spark_06.png"], ["ice-shard.png", "star_07.png"], ["magic_01.png", "twirl_03.png"],
	["slash_01.png", "slash_03.png"], ["trace_05.png", "trace_07.png"], ["muzzle_02.png", "muzzle_04.png"], ["smoke_07.png", "fire_02.png"]
]
const PARTICLE_TEXTURES = [
	["flame-imagegen-512.png", "spark_05.png", "flame_02.png"], ["spark_06.png", "spark_01.png", "trace_05.png"],
	["ice-shard.png", "star_02.png", "spark_03.png"], ["star_04.png", "light_02.png", "spark_02.png"],
	["slash_02.png", "spark_05.png", "trace_03.png"], ["trace_03.png", "trace_05.png", "trace_07.png"],
	["flame_03.png", "spark_05.png", "trace_05.png"], ["fire_01.png", "smoke_08.png", "dirt_02.png"]
]
const SHADER_STEPS = [
	"Warp an upward field with four octaves of noise.\nTaper its width and erode the edges.\nMap density to amber and restrained hot highlights.",
	"Displace a thin path with seeded noise.\nAdd thinner secondary branches.\nQuantize flicker and fade the discharge.",
	"Place asymmetric diamond distance fields.\nGrow their lengths at different rates.\nSplit facets into light and dark faces.",
	"Combine ring, point and ribbon distance fields.\nOrbit the fields using the shared playhead.\nFade with a slow restoration pulse.",
	"Mask an elliptical arc with a moving head.\nTaper its width toward both tips.\nBreak the trailing edge with procedural noise.",
	"Advance a tapered line along the thrust axis.\nConstrain the leading edge to a sharp tip.\nFade rapidly after maximum extension.",
	"Build a directional cone of hot gas.\nBreak it with advected noise and port lobes.\nCut exposure after a very short flash.",
	"Expand a noisy radial density field.\nErode the interior as the blast cools.\nSeparate orange fire, brown dust and a void ring."
]

static func mutation_name(kind: int, method: int, mutation: int) -> String:
	return MUTATIONS[kind][method][mutation]

static func inspector(kind: int, method: int, mutation: int) -> String:
	var text = "[color=#89a7cb]THIS MUTATION[/color]\n\n" + mutation_detail(kind, method, mutation) + "\n\n[color=#89a7cb]HOW IT IS BUILT[/color]\n\n"
	if method == 0:
		if mutation == 0 and ANIMATED[kind]:
			text += "[b]Sprite2D · animated raster atlas[/b]\n\n49 frames packed into a 7 × 7 sheet, generated locally with Wan 2.2 TI2V 5B. The engine chooses a frame from the shared playhead.\n\n1. Generate a locked-camera effect on black.\n2. Pack native frames into an atlas.\n3. Play, scale and fade the Sprite2D. A small supporting matte shader subtracts background haze before additive blending; the raster frames still supply the shape and motion.\n\n[b]Texture[/b]\n" + ("art/wan-impact-atlas.png" if kind == 7 else KEYS[kind] + "-wan-atlas.png") + "\n\n[b]Tradeoff[/b]\nRich authored detail, but baked motion and a larger texture. Black-backed clips use additive blending and lose contrast on bright scenes. AI clips may miss the intended action."
		else:
			var texture = BASE_TEXTURES[kind] if mutation == 0 else TEXTURES[kind][mutation - 1]
			text += "[b]Sprite2D · texture-card animation[/b]\n\n1. Select an alpha texture with a clear silhouette.\n2. Animate rotation, stretch and opacity.\n3. Layer a second card only where the mutation needs it.\n\n[b]Texture[/b]\n" + texture + "\n\n[b]Tradeoff[/b]\nCheap and easy to art-direct. The painted shape is fixed; transforms do not create new fluid motion."
			if texture == "flame-imagegen-512.png":
				text += "\n\n[b]Provenance[/b]\nOriginal flame plume generated with ImageGen; native alpha preserved."
			elif texture == "ice-shard.png":
				text += "\n\n[b]Provenance[/b]\nOriginal raster crystal with light/dark facets, authored for this lab."
			else:
				text += "\n\n[b]Provenance[/b]\nKenney Particle Pack, CC0. Actual texture reused with attribution here."
	elif method == 1:
		text += "[b]GPUParticles2D · ParticleProcessMaterial[/b]\n\n1. Emit real engine particles from a sphere or a directed cone.\n2. Assign velocity, gravity, lifetime and a size-over-life curve.\n3. Render textured billboards with a color ramp.\n\n[b]Texture[/b]\n" + PARTICLE_TEXTURES[kind][mutation] + (" + smoke_08.png + spark_05.png" if kind in [0, 7] else "") + "\n\n[b]Timeline[/b]\nFixed seed, 60 Hz simulation. Seeking restarts the emitter and requests simulation to the selected age; forward playback advances the simulation.\n\n[b]Tradeoff[/b]\nNatural variation and editable motion. Small GPU/browser differences are possible; many large transparent particles increase overdraw."
		if kind == 0 and mutation == 0:
			text += "\n\n[b]Provenance[/b]\nImageGen flame plume + Kenney CC0 sparks."
		else:
			text += "\n\n[b]Provenance[/b]\nKenney CC0 texture pack; original crystal raster for shard paths."
	else:
		text += "[b]ShaderMaterial · CanvasItem fragment shader[/b]\n\n" + SHADER_STEPS[kind] + "\n\n[b]Texture[/b]\nNone. Shape, noise and facets are evaluated per pixel.\n\n[b]Timeline[/b]\nAn explicit clock uniform, not wall-clock TIME, makes pause and seek exact.\n\n[b]Tradeoff[/b]\nResolution-independent shape and small asset size. Noise costs fragment work, and analytic shapes can look too mathematical.\n\n[b]Provenance[/b]\nOriginal shader written for this lab; GDQuest is a technique reference, not copied code."
	text += "\n\n[color=#89a7cb]REFERENCE / INSPIRATION[/color]\n\n[url=https://www.riotgames.com/en/artedu/visual-effects]Riot · shape, value, motion & restraint[/url]\n[url=https://kenney.nl/assets/particle-pack]Kenney · source texture pack (CC0)[/url]\n[url=https://github.com/gdquest-demos/godot-shaders]GDQuest · noise, dissolve & glow studies[/url]\n\nThese are technique studies, not exact reproductions of a commercial effect."
	return text

static func mutation_detail(kind: int, method: int, mutation: int) -> String:
	var name_ = mutation_name(kind, method, mutation)
	if method == 0:
		if mutation == 0 and ANIMATED[kind]:
			return name_ + ": frame playback is combined with engine-controlled fade. Local Wan source was selected for this category; failed generated backgrounds/shapes were rejected in other categories."
		if kind == 2: return name_ + ": repeat an original raster crystal as a staggered fan, or substitute a CC0 glint stamp for frost."
		if kind == 3: return name_ + ": counter-rotate layered seal or spiral cards; no particle simulation."
		if kind == 4: return name_ + ": rotate a tapered slash card through the swing; the double cut offsets a second painted arc."
		return name_ + ": use " + (BASE_TEXTURES[kind] if mutation == 0 else TEXTURES[kind][mutation - 1]) + " with category-specific stretch, drift and opacity."
	if method == 1:
		var changes = ["short concentrated emission", "wider emission radius with a slower release", "narrow spread, faster velocity and a sustained stream"]
		return name_ + ": " + changes[mutation] + ". The main billboard texture changes too." + (" Independent smoke and spark emitters add secondary detail." if kind in [0, 7] else "")
	var details = [
		["Upward noise-warped plume with density-based amber shading.", "Rotate the tapered field sideways to make a directed jet.", "Wrap the field around a rotating ring; use a cold spectral palette."],
		["A noisy vertical trunk with three thinner branches.", "Rotate six noisy paths around a central discharge.", "Turn the trunk horizontally into a chain arc."],
		["Grow irregular faceted distance-field shards around the impact.", "Move the shards to a ring, forming a crown.", "Align the shards diagonally into a glacial spear."],
		["Orbit twelve light points around two thin halos.", "Flatten a pool field and add a central restoration cross.", "Two oscillating analytic ribbons rise vertically."],
		["Sweep and erode a single tapered elliptical arc.", "Add a second concentric arc with narrower width.", "Replace the arcs with three parallel scratched segments."],
		["A horizontal thrust with a soft tail and concentrated tip.", "Rotate the tapered thrust diagonally.", "Offset three thrusts vertically for a multi-hit silhouette."],
		["A noisy gas cone begins on the left and emits to the right.", "Add two thin turbulent gas ports near the origin.", "Replace the gas cone with a narrow plasma flash."],
		["Expand and erode an orange turbulent density field.", "Keep the density field but shade it as opaque brown dust.", "Replace the fireball interior with an expanding violet shell."]]
	return details[kind][mutation]
