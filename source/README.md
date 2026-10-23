# Effects Lab

Standalone Godot 4.7.2 Compatibility project. Open `project.godot` and run the main scene.

Eight real-time 2D studies: fire, electric, ice, healing, slash, stab, muzzle flash, explosion. Select with 1–8, replay with Space or click the viewport, pause with P. The timeline pauses on scrub. Inspect layers, intensity, size, speed, background and deterministic seed variations.

The optional explosion flipbook is the existing locally generated Wan 2.2 TI2V 5B test (seed 22102026, 49 frames, 20 steps). Its black background uses additive blending; the engine supplies fade because the original clip did not dissipate. This is a prototype source layer, not a transparent production asset. No new AI generation is required to run this lab.

`godot --headless --path games/effects-lab -- --self-test` checks controls and deterministic setup. Run with `-- --capture ABSOLUTE_DIRECTORY` using a graphics device to capture each effect.

Web export uses a single thread and requires WebGL 2. Install matching Godot 4.7.2 export templates before exporting. Build output is ignored.
