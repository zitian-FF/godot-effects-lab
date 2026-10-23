# Elemental Atelier — Godot Effects Lab

[Open the live lab](https://zitian-ff.github.io/godot-effects-lab/)

Eight composed RPG effects replace the former implementation studies. Every effect combines **authored sprite silhouettes, animated shader materials / energy fields, and genuine GPUParticles2D motion**. The default view is the finished combination. Mute or solo a layer to inspect its contribution at the same time and seed.

| Effect | Reference target | Composition |
|---|---|---|
| Butterfly blaze | Genshin / Hu Tao | Flame sweep, separate butterflies, ember wake |
| Eye of thunder | Genshin / Raiden | Eye anticipation, white-violet cut, endpoint discharge |
| Frost blossom | Genshin / Ayaka | Floor seal, rising frost petals, delayed chips / snow |
| Tidal benediction | Genshin / Kokomi | Water canopy / tendrils, traveling caustics, drops / pearls |
| Verdant sever | Wuthering Waves / Jiyan | Swept wind ribbon, eroding material, aligned wind fragments |
| Astral pierce | JRPG lance / Jiyan thrust | Origin-to-target lance, contact ring, longitudinal sparks |
| Resonant gunshot | Wuthering Waves / Chixia | Barrel-anchored gas flash, pressure arc, sparks and smoke |
| Phoenix release | Wuthering Waves / Changli | Articulated flame wings, shock front, spreading feathers / ash |

These are original isolated 2.5D reconstructions of RPG visual motifs, not frame-exact game copies. In particular, phoenix uses a denser feather silhouette than Changli's thin red combat wakes. Full character choreography, 3D trails and cinematic camera cuts are outside this project. No extracted game assets or reference footage are embedded in the runtime. Official source links are in the composition inspector; [REFERENCES.md](REFERENCES.md) records what was actually inspected.

The original 72 studies and their assets were removed from the active project; they remain recoverable in Git history. This version uses new code-authored alpha masks and one new ImageGen flame-feather texture. See [ASSETS.json](ASSETS.json) for the prompt and provenance. No AI service or local model is needed at runtime.

## Controls

1–8 select effects; Space replays; P pauses. Scrubbing pauses at the chosen age. Show peak selects a useful review frame. Mute / Solo / All controls hold the playhead and seed. Slow motion, size, energy, light-stage and context controls support inspection. The side panel explains each layer's actual role and sequence timing.

## Run and verify

Open `source/project.godot` with Godot 4.7.2; Compatibility renderer, single-threaded Web export, no plugins.

```text
godot --headless --path source --editor --import --quit
godot --headless --path source -- --self-test
godot --path source -- --seek-test
godot --path source -- --capture ABSOLUTE_DIRECTORY
godot --path source -- --motion-capture ABSOLUTE_DIRECTORY
godot --headless --path source --export-release Web ../docs/index.html
```

The independent critic reviewed full, solo, mute, phase and light-stage captures. The final hybrid compositions passed after revisions to material contrast, water clarity, particle placement and wing motion. Native particle backward seeking was pixel-identical in 8/8 categories on RTX5070. Browser/GPU differences remain possible. Desktop landscape is the main layout.

Matching export templates are required. GitHub Actions verifies SHA256 hashes and publishes the frozen `docs/` export. It does not build other games.
