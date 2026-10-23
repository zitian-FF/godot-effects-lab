# Effects Lab

Standalone Godot 4.7.2 Compatibility project. Open `project.godot` and run the main scene.

Eight real-time 2D categories, each with Sprite / Particles / Shader paths and three named mutations (72 configurations). Select with 1–8, replay with Space or click the viewport, pause with P. The timeline pauses on scrub. Method/mutation switches preserve time and seed. Use Best attempt for curated selections. The side inspector explains each configuration, texture source and tradeoff.

Selected raster clips are generated locally with Wan 2.2 TI2V 5B, including the prior explosion test. The engine supplies fade and a supporting black-floor matte shader for these black-backed clips. Other sprite paths animate alpha texture cards. Genuine particle emitters use selected Kenney CC0 or ImageGen billboards; shader paths use analytic noise and distance fields. No generation service is needed at runtime.

`godot --headless --path source -- --self-test` checks 72 configurations and time/seed hold. Run with `-- --seek-test` on a graphics device to test pixel parity after backward particle seeks. `-- --capture ABSOLUTE_DIRECTORY` captures all configurations, three phases and light-background samples.

Web export uses a single thread and requires WebGL 2. Install matching Godot 4.7.2 export templates before exporting. Build output is ignored.
