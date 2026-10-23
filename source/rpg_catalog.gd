extends RefCounted
const NAMES = ["Butterfly blaze", "Eye of thunder", "Frost blossom", "Tidal benediction", "Verdant sever", "Astral pierce", "Resonant gunshot", "Phoenix release"]
const SHORT = ["Fire", "Electric", "Ice", "Healing", "Slash", "Stab", "Muzzle", "Explosion"]
const COLORS = [Color("ff8641"),Color("bd93ff"),Color("8cdeff"),Color("86dcff"),Color("69f1cd"),Color("ffdda0"),Color("ffb65f"),Color("ff7045")]
const DURATIONS = [1.65,1.2,2.1,2.7,1.2,1.05,0.9,2.2]
const STRIKES = [0.22,0.26,0.34,0.45,0.18,0.16,0.04,0.32]
const PEAKS = [0.42,0.30,0.66,0.95,0.32,0.24,0.09,0.62]
const SOURCES = ["Genshin · Hu Tao", "Genshin · Raiden Shogun", "Genshin · Ayaka", "Genshin · Kokomi", "Wuthering Waves · Jiyan", "JRPG lance / Jiyan thrust", "Wuthering Waves · Chixia", "Wuthering Waves · Changli"]
const URLS = ["https://www.youtube.com/watch?v=qrH9vMZBwAk", "https://www.youtube.com/watch?v=mvrW4aKwAXw&t=104s", "https://www.youtube.com/watch?v=5RCsr1Y8UZA", "https://www.youtube.com/watch?v=fVf0RB3nvOU", "https://www.youtube.com/watch?v=wnxtQsHOy1k", "https://www.youtube.com/watch?v=wnxtQsHOy1k", "https://www.youtube.com/watch?v=j6HReyWAM-s", "https://www.youtube.com/watch?v=jYjxjy1l6Co&t=140s"]
const TARGETS = [
"Red-orange sweeping blade; golden butterflies peel away after its burning edge passes.",
"A violet almond eye compresses into a near-instant incision; branches arrive after contact.",
"A floor seal opens into asymmetric icy petals. Large facets rise first; fine snow settles last.",
"A translucent water canopy breathes above a shallow ripple pool. Tendrils and drops communicate restoration.",
"A teal sword ribbon sweeps toward the target. Pale cutting edge, dark open center, trailing wind fragments.",
"A rear charge becomes a long ivory thrust. A separate contact diamond and segmented wake resolve the hit.",
"A fixed barrel emits a three-lobed gas flash. Pressure travels ahead; residual smoke rises behind.",
"Crimson feathers gather, then open into fire wings. A broken pressure ring and falling ash finish the release."
]
const SPRITES = ["Curved brush mask and legible butterfly silhouettes", "Eye/iris mask and tapered incision card", "Faceted frost petals and a ring seal", "Water canopy, tendrils and droplet masks", "Torn crescent masks staggered behind the cutting edge", "Tapered lance and compact contact rosette", "Three-lobed gas silhouette and smoke mask", "Painted flame-feather texture articulated into two wings"]
const SHADERS = ["Arc reveal, gold edge / crimson body, erosion; elliptical fire wake", "Eye contraction, violet-white cut gradient; delayed procedural branches", "Faceted ramps and growth reveal; broken frost rings", "Caustic bands and rim shading; elliptical pool ripples", "Leading-edge reveal and directional breakup; trailing air ribbons", "Rapid axis reveal and bright tip; contact ring and segmented wake", "Ivory-to-amber cooling and gas erosion; advancing pressure arc", "Directional feather reveal and red-to-gold breakup; expanding shock front"]
const PARTICLES = ["Butterfly debris and sparse delayed embers", "Endpoint needle sparks and secondary discharge", "Delayed petal chips and falling snow", "Rising drops and sparse pink pearl highlights", "Aligned wind chips released across the arc", "Longitudinal target sparks and returning fragments", "Six fast sparks plus a separate gray smoke emitter", "Outward flame feathers followed by slower ash"]
static func inspector(k:int)->String:
	var s="[color=#8faec5]REFERENCE TARGET[/color]\n\n"+SOURCES[k]+"\n\n"+TARGETS[k]+"\n\n[url="+URLS[k]+"]Open source reference ↗[/url]\n\n[color=#8faec5]HYBRID CONSTRUCTION[/color]\n\n[b]01 · Sprite / authored silhouette[/b]\n"+SPRITES[k]+".\n\n[b]02 · Shader / material & energy[/b]\n"+SHADERS[k]+".\n\n[b]03 · Particles / independent motion[/b]\n"+PARTICLES[k]+".\n\n[b]Timing[/b]\nAnticipation → fast strike → longer recovery. Strike at %.2f s; duration %.2f s.\n\n" % [STRIKES[k],DURATIONS[k]]
	s+="[b]Layer controls[/b]\nMute or solo each layer to see its job. Shader mute removes the energy field and restores plain alpha shading on the hero sprites.\n\n[b]Similarity & limits[/b]\nOriginal 2.5D reconstruction study, not extracted game assets or a frame-exact replica. Character choreography, full 3D trails and cinematic camera cuts are outside this isolated effect.\n\n[b]Asset provenance[/b]\nOriginal code-authored alpha masks and Godot shaders. Phoenix uses a new ImageGen flame feather. No commercial textures or footage embedded in the runtime."
	return s
