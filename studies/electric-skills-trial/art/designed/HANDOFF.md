# Electric slash asset handoff

This package is an original asset-design proposal for one curved gameplay sword slash. It supplies the shapes before emitter tuning. It contains no character-animation changes, production scene, generated brush texture, game-extracted art, hit-star filler or bolt lines.

## Review and usable files

Open `asset-board.png` to assess the four grayscale assets separately. Open `topology-uv.png` for the explicit geometry/UV relationship. Both also have editable SVG sources. The PNG boards are 1600 px wide for direct display in the lab.

| Role | Editable source | Ready-to-import RGBA | Canvas | Anchor in texture pixels |
| --- | --- | --- | --- | --- |
| Crescent body | `textures/crescent_mask.svg` | `textures/crescent_mask.png` | 1024 × 640 | (512,652), below canvas |
| Narrow outside edge | `textures/crescent_edge.svg` | `textures/crescent_edge.png` | 1024 × 640 | (512,652), below canvas |
| Needle streak | `textures/spark_needle.svg` | `textures/spark_needle.png` | 192 × 48 | (96,24), centered |
| Tapered chip | `textures/spark_chip.svg` | `textures/spark_chip.png` | 128 × 64 | (64,32), centered |

Every texture is neutral grayscale with genuine alpha, a fully transparent border and no baked glow/background. The PNGs are direct SVG rasterizations; SVG sources remain editable. Use PNGs in production for consistent importer results. Keep linear filtering and clamp sampling. Preserve grayscale RGB as energy as well as alpha as coverage; replacing RGB with solid white would discard the authored body/facet values.

## Chosen mesh and UVs

Use a **planar annular-sector support**, with 48 angular segments, two radial rows, 98 vertices and 96 triangles. `meshes/crescent_support.json` contains the exact vertices, triangle indices and Godot-style top-left UVs. `meshes/crescent_support.obj` is reference geometry, with standard lower-left OBJ V coordinates; JSON is authoritative for MeshInstance2D.

For sample `i = 0…48` and each radius `r ∈ {378,544}`:

```text
theta = radians(-158 + 136*i/48)
local = (r*cos(theta), r*sin(theta))
UV = ((local.x+512)/1024, (local.y+652)/640)
```

The mesh origin is the orbit center, local `(0,0)`. Texture pixel `(512,652)` maps to that pivot, at UV `(0.5,1.01875)`. All actual mesh UVs remain inside the texture. The pivot itself is outside the textured surface.

The texture visibly contains a crescent; this is not a rectangular strip with angular U and radial V. The outer mask arc has radius 520 px and active angle −154°…−26°. The narrower support bounds leave transparent room for modest shader distortion. A four-vertex card is a valid static alternative; the chosen support avoids the empty center and makes the curved geometry and texture correspondence teachable. An angularly unwrapped strip would require redesigning the texture as a straight mask, so it was not selected.

## Active tip alignment to the existing guide

**Use the visible mask tip, not a support-mesh corner.** The forward/right tip is exactly:

```text
angle = -26 degrees
radius = 520 design pixels
local = (467.372904, -227.952996)
texture pixel = (979.372904, 424.047004)
UV = (0.956418852, 0.662573443)
```

To place this tip on the existing 235 px blade reach:

1. Rotate local XY by `guide.angle(t) - deg_to_rad(-26)`.
2. Uniformly scale by `235.0 / 520.0`.
3. Apply the existing projection to the rotated/scaled coordinate: `y *= 0.58`.
4. Add `guide.hand(t)`.

The transform order matters: apply the Y projection **after** local rotation. This should put the active head on `guide.tip(t)` without modifying the character motion. Reversing rotation and elliptical projection produces a different orbit.

The shape's width varies asymmetrically as `125*sin(pi*s)^0.9*(0.5+0.8*s)`, where `s=(theta+154)/128` in degrees. It broadens toward the leading portion and tapers to both ends. The inside contour has a 12 px feather. The separate outside edge is 7 px thick at the arc midpoint, about 3.2 px after radial scale, before the existing Y projection.

## Individual spark designs

**Needle:** a single long teardrop-like streak with a fine trailing end, fuller pointed head and narrow white spine. Its forward axis is **+X**. The source silhouette envelope is 176 × 14 px, approximately 12.6:1. Values and alpha rise toward the head; it has no cross arms. It should communicate the direction of a small, fast release. Default centered sprite origin is correct; forward mathematical tip is `(184,24)`.

**Chip:** a compact unequal six-point polygon with a bright upper facet, darker lower facet and thin spine. Its forward axis is also **+X**. The source envelope is 104 × 28 px, approximately 3.7:1. Its body remains broader than the needle and reads as a detached fleck. Default centered sprite origin is `(64,32)`; forward point is `(116,29)`.

These dimensions describe the assets, not final screen size or emitter counts. The PNG raster bounds and alpha statistics are in `manifest.json`.

## Material and compositing proposal

1. Crescent body: grayscale energy tinted to the chosen electric hue, with restrained additive blending.
2. Crescent edge: the same mesh, transform, planar UVs and exact distortion offset; a pale narrow rim above the body. Avoid independent noise that separates the two contours.
3. Needle releases: sparse supporting streaks that remain thinner than the crescent.
4. Compact chips: a few detached flecks, with lower travel than needles.

There is no required glow sprite or screen-refraction pass. Those are later compositing choices, not missing assets.

For shader distortion, recover local texture position as `UV*vec2(1024,640)-vec2(512,652)`. This gives an angle/radius field while leaving the authored mask in planar UVs. Start with at most 4 design pixels of mask-sampling displacement, divided by the texture dimensions. Fade displacement to zero in the first and last 8% of the active angular span so the pointed ends, especially the guide-aligned head, remain fixed. Apply identical offsets to body and edge. Noise should perturb the established crescent, not replace it. Erosion should retain the broad shape long enough to read before breaking up.

## Emitter implications, after shape choice

Use separate needle and chip systems because their silhouettes have different roles. Align the needle's +X long axis with release velocity; if an engine uses +Y alignment, rotate the draw quad/UV convention once rather than changing the source asset. Keep a needle slender when scaling. Chips can tumble independently while retaining their compact aspect. Place the few releases around the leading release region after the crescent becomes legible. Final counts, velocities, life curves, timing and screen size belong to the production/composition pass and remain proposals until seen in the unchanged guide.

## Provenance, checks and remaining work

`build_assets.py` authors the vector paths and mesh. `rasterize_vectors.js` uses the bundled Sharp SVG renderer to produce PNGs and populate `manifest.json` with dimensions, visible bounds, grayscale/alpha checks and SHA-256 hashes. These scripts write only within this package. No image-generation tool was needed because these are original code-native geometric assets rather than painterly raster imagery.

Viewed: current trial pass sheet, blockout beat sheet, source screenshot for qualitative shape families, final asset board, final topology board and crescent mask. All four PNGs have zero non-grayscale visible pixels and zero nontransparent border pixels. The body alpha maximum is 232/255; edge and chip reach 255/255; needle reaches 253/255. A first raster's gradient quantization was corrected before this handoff; current body SHA-256 is `4eaecaf8b8d85e45f16c9c516c1b73eb434c8945c43dc1ab93f91581c78546c9`.

The reference screenshot does not establish the source game's mesh topology, shader implementation, particle count or timing. No such implementation claims are made here. This board is an asset-design review. Root still needs to validate projected shape, shader distortion/erosion, additive balance and the two particle motions at gameplay size. No export, deployment, commit or push was performed.
