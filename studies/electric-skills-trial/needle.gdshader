shader_type canvas_item;
render_mode unshaded, blend_add;
// The designed asset points along +X. Particle align-Y follows velocity.
// Rotate the quad (not the source asset) so its +X tip becomes local +Y.
void vertex(){VERTEX=vec2(-VERTEX.y,VERTEX.x);}
void fragment(){COLOR=texture(TEXTURE,UV)*COLOR;}
