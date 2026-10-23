# Godot Effects Lab

[Open the live lab](https://zitian-ff.github.io/godot-effects-lab/)

Eight interactive 2D categories: fire, electric, ice, healing, slash, stab, muzzle flash and explosion. Each has Sprite, Particles and Shader implementations with three named mutations: **24 implementations, 72 configurations**.

The **Best attempt** button opens a curated configuration. Implementation and mutation switches preserve the playhead and seed for comparison. Includes replay, scrub/pause, slow motion, size/intensity and light-background review. The scrolling side inspector explains the exact mutation, nodes/materials, texture source, construction steps, tradeoff and online references.

Open `source/project.godot` with Godot 4.7.2. Uses the Compatibility renderer and a single-threaded Web export. No plugins or external services are required at runtime.

Sprite paths use selected local Wan 2.2 TI2V 5B flipbooks, alpha texture cards from Kenney's CC0 Particle Pack, an original crystal raster and an ImageGen flame plume. Particle paths use genuine GPUParticles2D emitters with ParticleProcessMaterial, fixed seeds and timeline simulation. Shader paths evaluate original CanvasItem noise/distance fields from an explicit playhead uniform.

The first local AI pass produced seven clips; electric, ice and slash were selected, alongside the earlier explosion. Fire, healing, stab and muzzle outputs had poor framing/background/shape and were rejected rather than silently presented as finished work. Prompts/workflows are saved in `provenance/`; asset origins and the ImageGen prompt are in [ASSETS.json](ASSETS.json).

These are capability studies, not production asset certification. The independent critic reviewed 72 dark-background configurations, 24 light-background views and attack/peak/decay strips, and prompted revisions to clipping, particle readability, matte cleanup and inspector accuracy. Native particle backward seeking was pixel-identical in 8/8 categories on the development GPU; browser/GPU differences remain possible.

References are linked in the inspector: [Kenney Particle Pack](https://kenney.nl/assets/particle-pack) supplies reused CC0 textures; [GDQuest's shader library](https://github.com/gdquest-demos/godot-shaders) and [Riot's VFX education](https://www.riotgames.com/en/artedu/visual-effects) inform technique and visual hierarchy. No commercial game assets or GDQuest shader source were copied.

## Rebuild

Install matching export templates, then run:

```text
godot --headless --path source --editor --import --quit
godot --headless --path source -- --self-test
godot --headless --path source --export-release Web ../docs/index.html
```

Serve `docs/` over HTTP to preview. Commit the source and its reviewed Web export together. GitHub Actions deploys only the frozen export under `docs/`; it does not build or deploy other games.

Desktop landscape is the primary review layout. Keyboard: 1–8 select, Space replay, P pause. The interface scales to the available browser area.
