# Elemental Atelier

Open project.godot in Godot4.7.2 and run. Eight composed RPG effects replace the previous72 isolated studies. Each has Sprite2D heroes with animated ShaderMaterial surfaces, independent procedural energy fields and GPUParticles2D secondary motion. Layer mute/solo holds time and seed.

The composition inspector links official references and explains the purpose of each layer. Sprites are original alpha masks plus a new ImageGen flame feather; shaders and particle sequences are original code. Runtime is fully local, single-threaded WebGL2 / Compatibility. See the repository README, ASSETS.json and REFERENCES.md for provenance and limitations.

From this directory, run `godot --headless --path . -- --self-test` to verify the eight compositions. Native graphics is required for `-- --seek-test`, `-- --capture ABSOLUTE_DIRECTORY` and `-- --motion-capture ABSOLUTE_DIRECTORY`.
