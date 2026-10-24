# Electric skills trial — pass 03

[Live trial](https://zitian-ff.github.io/godot-effects-lab/studies/electric-skills-trial/)

An original gameplay Electric slash using the previously fixed attack guide. The motion guide is copied without animation edits; the new work is VFX. Guide / Skills trial holds the playhead for comparison. The menu steps through brush mask, shader material, electricity/impact, full composition, particles solo and contact/electricity solo. VFX peak selects 0.315 seconds; actual contact remains 0.30 seconds. Scrub, frame step, slow motion and VFX/path toggles remain available. The inspector explains how each layer is constructed.

## Installed skills actually tried

- `scenario-godot-vfx` plus required `scenario-godot-expert`, from [scenario-labs/skills](https://github.com/scenario-labs/skills): separate silhouette, material, contact and residual layers; explicit renderer choice; deterministic captures and technical checks. Its Python AgentKit was used for project audit, script checking, actual windowed capture/image checks and local profiling. The stock recipes target 3D fireball/explosion systems and were **not** copied unchanged into this 2D study. Its stock 3D VFX audit/overdraw calibration is not represented as a valid 2D audit.
- `godot-particles`, from [GD-Agentic-Skills](https://github.com/thedivergentai/GD-Agentic-Skills/tree/main/skills/godot-particles): one-shot/restart, global coordinate space, explicit bounds, alpha/scale curves. Its mandatory burst/recycler/coordinate examples were inspected. The burst example uses timer cleanup despite the skill's advice against it; it was not copied. The reusable preview retains two emitters, uses `restart(true)` with fixed seeds and manually advances particle time. Gameplay disposal/pooling is outside this preview.
- `godot-shaders`, from [awesome-gamedev-agent-skills](https://github.com/gamedev-skills/awesome-gamedev-agent-skills/tree/main/skills/godot/godot-shaders): texture/UV sampling, color uniforms and noise-threshold dissolve. Runtime animation uses an explicit age uniform for deterministic scrub instead of unbounded `TIME`.

These skills provide technical recipes and workflows. This trial does not establish that installing them guarantees professional art quality or exact reproduction of a game's effect.

## Runtime construction

1. **Brush body:** one generated grayscale dry-brush alpha mask mapped onto an animated MeshInstance2D ribbon following the fixed sword path. The texture supplies broad gaps, torn tips and striation; it is not a clean vector outline.
2. **Material:** `slash.gdshader` supplies violet body/pale edge and localized erosion. Reveal follows the guide's arc and late recovery contracts; there is no long horizontal beam.
3. **Contact:** a Sprite2D with an original irregular star mask and a short ShaderMaterial flash begins at 0.30 seconds. A small number of unequal, authored electrical paths branch near contact; a single uneven arc follows the blade path.
4. **Residual motion:** 18 fast streaks and 12 slower flecks use actual seeded GPUParticles2D. They detach near contact, damp, shrink and fade. The renderer is Compatibility for Web; no particle trails, sub-emitters, decals or compute-only features are assumed.

## Validation and limits

- Godot 4.7.2 Compatibility, native RTX 5070, logical viewport 1280×800.
- Scenario `gd_run.check_all`: 3 application scripts checked, zero failures. Native captures compiled and rendered both shaders without script/shader errors.
- Project audit: intended renderer, main scene and stretch confirmed. The generic 3D Jolt-default flag is inapplicable to this 2D project; no 3D physics is used. Version feature metadata was added.
- Focused checks: six passes preserve paused time; sprite/shader/two seeded particle layers exist; target contact still aligns within 2 px.
- Captures: 70 frames sampled at 60 fps, six effect phases, six layer passes and guide/full comparisons. Three native particle backward-seek pairs were pixel-identical at 0.33, 0.42 and 0.60 seconds.
- Scenario capture and image checks ran; six phase captures also passed blank/uniform checks. These are technical checks, not proof of artistic quality. Captures were visually inspected without a critique agent.
- A short 181-frame native whole-scene profile averaged 16.654 ms at display pacing; p95 was 16.885 ms. The strict 16.67 ms wall-time gate did not pass. Reported scene GPU p95 was 0.044 ms on this machine; the toolkit's relative-hitch gate also flagged small variations. These measurements do not establish browser/mobile performance or isolate VFX cost. No performance guarantee is made.
- Native runs print an environment certificate-store warning before the scene starts. Windowed rendering and checks complete; browser console verification is separate.
- The generated brush texture also affects the visual result, so this is not an isolated benchmark of skill instructions alone. No exact Raiden/Genshin recreation is claimed. The fixed mannequin poses are only context, not final character animation.

## Reproduce

```text
godot --headless --path studies/electric-skills-trial --editor --import --quit
godot --headless --path studies/electric-skills-trial -- --trial-check
godot --path studies/electric-skills-trial -- --trial-capture ABS_DIR
godot --headless --path studies/electric-skills-trial --export-release Web ../../docs/studies/electric-skills-trial/index.html
```

AgentKit is development tooling installed from the user's skill directory and excluded from Git and the Web export. `ASSETS.json` records asset provenance and the brush prompt. Runtime code and original vector masks are project-authored; no game textures or footage are redistributed.
