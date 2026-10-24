# Electric slash — asset design and production

[Live study](https://zitian-ff.github.io/godot-effects-lab/studies/electric-skills-trial/)

This pass follows the user's asset-first breakdown: a crescent mask on a matching mesh, shader distortion, then individually designed spark silhouettes before emitter logic. An Ultra-effort asset-design agent produced the package; root integrated production and composition. Character pose/timing code remains unchanged. The old proxy hit-color flash is capped to a neutral value for effect readability.

## Inspect the work

- **Assets:** four grayscale assets on a labelled board: crescent body, narrow edge, needle streak and tapered chip.
- **Mesh / UV diagram:** the menu's final view shows the support topology and direct XY-to-UV relationship.
- **Crescent mask:** the actual source silhouette rendered without distortion or material color.
- **Distorted material:** violet body and pale edge with the same small UV displacement, a separate reveal and late erosion.
- **Needle / chip sparks:** each designed shape has its own system and can be inspected alone.
- **Production / composition:** combines the crescent, its edge and the two spark roles. The earlier trial's star flash and extra bolt lines are absent.

Guide / Production and pass selection hold the playhead. VFX peak selects 0.315 seconds; contact is still 0.30 seconds. The Distortion toggle holds time and disables only mask displacement, retaining color/reveal/erosion. Frame stepping, slow playback, scrub and VFX/path isolation remain available. The side inspector explains actual assets and implementation. The main eight-effect lab links this study from Electric's **Asset breakdown** button.

## Asset-to-runtime mapping

The design uses a planar annular-sector support: 48 angular segments, two radial rows, 98 vertices and 96 triangles. The texture itself is crescent-shaped; it is not a straight brush stretched around an angular UV strip. The texture-space pivot is (512,652) for a 1024×640 canvas. Planar UVs are `((x+512)/1024,(y+652)/640)`.

The active mask head is radius 520 at -26 degrees. Production rotates by `guide.angle(t)+26 degrees`, scales by `235/520`, projects Y by 0.58, then adds the guide's hand position. A functional check confirms that this designed head aligns with the guide tip. The static support mesh is built once; vertex-shader uniforms supply its transform.

`slash.gdshader` samples body and edge with the same offset. Distortion is limited to at most four design pixels per component and fades to zero at both tips. Color, reveal, distortion and erosion have separate responsibilities. Grayscale values and alpha from the source assets are preserved rather than replacing the body with solid white.

The needle is a 192×48 texture with a 176×14 active silhouette; the chip is a 128×64 texture with a 104×28 active silhouette. Both point +X in the design. A tiny quad-rotation shader maps the needle into Godot's align-Y-to-velocity convention without editing the source texture. Seven short-lived needles align to release velocity; four slower chips tumble. Both are fixed-seed GPUParticles2D using global coordinates, drag, scale/alpha curves and explicit bounds. Emitter timing and counts are production choices made after the shapes were designed.

## Source package and provenance

[Asset handoff](art/designed/HANDOFF.md), [manifest](art/designed/manifest.json), [mesh/UV board](art/designed/topology-uv.png) and [geometry checks](art/designed/geometry-checks.json) are included beside editable SVGs, PNG rasterizations and exact mesh JSON/OBJ. The design package contains its own source generation/rasterization scripts. These are original code-native assets; no game assets, generated brush bitmap, reference footage or baked glow are used by this pass. Old trial files remain in source/history but are excluded from this Web export.

The earlier installed Godot/Scenario skills still inform renderer choice, shader/particle handling, capture and checking. They are not evidence that the design matches a commercial game's production pipeline. The reference screenshot supplied qualitative shape families only. This is a teachable original slash study, not an exact Raiden recreation or a finished reusable combat package.

## Verification

- Godot 4.7.2 Compatibility; windowed capture at 1280×800 through an offscreen render viewport.
- Asset checks: all four masks are grayscale with real alpha and transparent borders; mask coverage lies inside the support; all UVs are within [0,1].
- Focused runtime checks: designed head alignment, distinct spark textures and held review time.
- Captures: 70 motion frames, six phase stills, asset/layer views, guide/composition comparison. Three full-composition backward-seek pairs at 0.33, 0.39 and 0.48 seconds are pixel-identical natively.
- Source character motion is unchanged. The main lab changes only its Electric study link and shortcut-label position.
- Native rendering completed without script/shader errors. The host certificate-store warning and an unavailable audio-device fallback are environmental; this silent study needs no audio. Web console verification is separate.
- No browser/mobile frame-budget claim is made. The prior pass's native profile is not reused as a measurement of this pass.

Run `godot --headless --path studies/electric-skills-trial -- --trial-check`, or open its project. Export with its Web preset. Development AgentKit, source vectors/mesh documentation and legacy trial assets are excluded from the Web runtime.
