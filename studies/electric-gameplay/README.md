# Electric gameplay study — pass 02

This reviewable motion and silhouette blockout follows the user's choice of a gameplay attack around a character. It is an original authored attack, informed by the earlier Raiden motif study, rather than a reconstruction of the cinematic burst. It is not finished Electric VFX.

The hand drives the sword. A broad, tapered crescent occupies the sword tip's recent arc. A planted rear foot, a short leading step and 28 px of forward weight shift support the sweep; the sword tip reaches the review target at 0.30 seconds. The mass closes after follow-through so recovery reads clearly. Body, sword and leading foot return to the same ready pose before looping. Characters are neutral geometric pose proxies, not finished rigs or animation. Reach is exaggerated for an RPG sword attack. The contact marker is a deterministic presentation event, not an implemented damage/collision system.

The inspector explains intent, motion, timing and the next passes. Pause, replay, slow motion, frame stepping, scrub, phase checkpoints, path overlay and slash-mass toggling allow focused review. All construction is grayscale; textures, shaders, electricity, particles and camera response are deliberately deferred until the motion pass is reviewed. The finished effect is still intended to combine useful sprite, shader and particle layers.

## Authored timing

- 0.00–0.18 seconds: wind-up.
- 0.18–0.30: forward sweep.
- 0.30: sword-tip/contact marker alignment.
- 0.30–0.46: follow-through / trail contraction.
- 0.46–0.90: recovery; cycle duration 1.15 seconds.

These times are designed for the prototype, not measured source footage timings. The character's attack animation must eventually own the actual contact event. Final reach and duration require a real character rig, camera and combat implementation.

## Review gate

Review normal-speed motion first, then entry/contact/recovery stills. Check character attachment, direction, reach, weapon-to-trail continuity, contact and a clear exit. The silhouette must remain legible at reduced on-screen size and without bloom. A technical check passing is not visual approval.

Next: authored directional brush masks; material reveal/erosion; a few art-directed electrical discharges and detached particle fragments; real combat integration and measured Web performance. Preserve the earlier A/B lab as comparison history.

## Run

Godot 4.7.2 Compatibility renderer, standalone project, no external assets or dependencies.

```text
godot --headless --path studies/electric-gameplay -- --check-study
godot --path studies/electric-gameplay -- --capture-study ABS_DIR
godot --headless --path studies/electric-gameplay --export-release Web ../../docs/studies/electric-gameplay/index.html
```

`--check-study` verifies the authored blade tip is within 2 px of the contact marker, wind-up remains outside the target, forward reach/recovery work and review toggles hold time. `--capture-study` writes 70 native frames at 60 fps, four beat stills and a clean contact still. Neither check claims actual combat integration or production visual quality.
