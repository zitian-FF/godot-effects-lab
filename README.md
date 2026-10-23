# Godot Effects Lab

[Open the live lab](https://zitian-ff.github.io/godot-effects-lab/)

Eight interactive 2D effects: fire, electric, ice, healing, slash, stab, muzzle flash and explosion. Includes replay, scrub/pause, slow motion, size/intensity, layer switches, seed variation and a light-background check.

Open `source/project.godot` with Godot 4.7.2. Uses the Compatibility renderer and a single-threaded Web export. No plugins or external services are required at runtime.

The optional explosion layer reuses a local Wan 2.2 TI2V 5B flipbook. Everything else is native procedural geometry, additive sprites and deterministic particles. These are effect studies, not production assets.

## Rebuild

Install matching export templates, then run:

```text
godot --headless --path source --editor --import --quit
godot --headless --path source -- --self-test
godot --headless --path source --export-release Web ../docs/index.html
```

Serve `docs/` over HTTP to preview. Commit the source and its reviewed Web export together. GitHub Actions deploys only the frozen export under `docs/`; it does not build or deploy other games.

Desktop landscape is the primary review layout. Keyboard: 1–8 select, Space replay, P pause. The interface scales to the available browser area.
