"""Original vector asset authoring and mesh data for one gameplay slash.

No image synthesis, tracing, game extraction, brush texture or random noise.
Run with bundled Python, then rasterize_vectors.js with bundled Node/sharp.
All output is confined to this package directory.
"""
from pathlib import Path
import math, json, base64, hashlib

HERE = Path(__file__).resolve().parent
TEX = HERE / 'textures'
MESH = HERE / 'meshes'
TEX.mkdir(exist_ok=True)
MESH.mkdir(exist_ok=True)
CX, CY, W, H = 512., 652., 1024, 640
THETA0, THETA1, R = -154., -26., 520.

def xy(t, radius):
    a = math.radians(THETA0 + (THETA1 - THETA0) * t)
    return (CX + radius * math.cos(a), CY + radius * math.sin(a))

def width(t):
    return 125. * max(0., math.sin(math.pi * t)) ** .9 * (.5 + .8 * t)

def outline(inner_radius, samples=192):
    ts = [i / samples for i in range(samples+1)]
    points = [xy(t, R) for t in ts] + [xy(t, inner_radius(t)) for t in ts[::-1]]
    return 'M' + ' L'.join(f'{x:.3f},{y:.3f}' for x,y in points) + ' Z'

def svg(w,h,body,defs='',desc=''):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">'
            f'<desc>{desc}</desc><defs>{defs}</defs>{body}</svg>')

def write(name, content):
    (HERE / name).write_text(content, encoding='utf-8')

# A true crescent in planar texture coordinates. One smooth gradient core plus
# non-overlapping inner feather bands avoids repeated low-alpha quantization.
# No SVG filters, which are inconsistent across importers.
radial = ('<radialGradient id="body" gradientUnits="userSpaceOnUse" '
          'cx="512" cy="652" r="520">'
          '<stop offset="0.68" stop-color="#484848"/>'
          '<stop offset="0.78" stop-color="#707070"/>'
          '<stop offset="0.90" stop-color="#b4b4b4"/>'
          '<stop offset="1" stop-color="#ececec"/></radialGradient>')
layers = [f'<path d="{outline(lambda t: R-width(t)+12.*math.sin(math.pi*t))}" fill="url(#body)" opacity="0.91"/>']
for i in range(24):
    ts = [j / 192. for j in range(193)]
    # Feather is confined to the inside 12 px. Bands do not accumulate across
    # the whole core, so its continuous grayscale gradient stays continuous.
    outer = lambda t: R-width(t)+12.*(i+1)/24.*math.sin(math.pi*t)
    inner = lambda t: R-width(t)+12.*i/24.*math.sin(math.pi*t)
    points = [xy(t,outer(t)) for t in ts] + [xy(t,inner(t)) for t in ts[::-1]]
    d = 'M' + ' L'.join(f'{x:.3f},{y:.3f}' for x,y in points) + ' Z'
    layers.append(f'<path d="{d}" fill="url(#body)" opacity="{.91*(i+.5)/24.:.5f}"/>')
write('textures/crescent_mask.svg', svg(W,H,''.join(layers),radial,
      'Original grayscale crescent body. Planar mask; pivot at texture pixel 512,652. No glow.'))

edge_def = ('<linearGradient id="edge" gradientUnits="userSpaceOnUse" x1="44.627" y1="424.047" '
            'x2="979.373" y2="424.047">'
            '<stop offset="0" stop-color="#8d8d8d" stop-opacity="0.55"/>'
            '<stop offset="0.30" stop-color="#ededed" stop-opacity="0.92"/>'
            '<stop offset="0.65" stop-color="#ffffff"/>'
            '<stop offset="1" stop-color="#ffffff"/></linearGradient>')
edge_d = outline(lambda t: R - 7.*max(0.,math.sin(math.pi*t))**.9*(.8+.4*t))
write('textures/crescent_edge.svg', svg(W,H,f'<path d="{edge_d}" fill="url(#edge)"/>',edge_def,
      'Original narrow outside contour. Matches the crescent body pivot, scale and UVs exactly.'))

needle_defs = ('<linearGradient id="needle" x1="8" x2="184" y1="24" y2="24" gradientUnits="userSpaceOnUse">'
              '<stop offset="0" stop-color="#747474" stop-opacity="0.02"/>'
              '<stop offset="0.26" stop-color="#a6a6a6" stop-opacity="0.30"/>'
              '<stop offset="0.70" stop-color="#e4e4e4" stop-opacity="0.90"/>'
              '<stop offset="1" stop-color="#ffffff"/></linearGradient>'
              '<linearGradient id="ridge" x1="48" x2="180" y1="24" y2="24" gradientUnits="userSpaceOnUse">'
              '<stop offset="0" stop-color="#ffffff" stop-opacity="0"/>'
              '<stop offset="0.65" stop-color="#ffffff" stop-opacity="0.80"/>'
              '<stop offset="1" stop-color="#ffffff" stop-opacity="0.95"/></linearGradient>')
needle_body = ('<path d="M8 24 C57 23 97 18 142 17 L184 24 L143 31 C98 29 56 25 8 24Z" fill="url(#needle)"/>'
               '<path d="M48 24 L143 22.5 L180 24 L143 25.5Z" fill="url(#ridge)"/>')
write('textures/spark_needle.svg', svg(192,48,needle_body,needle_defs,
      'Original single directed needle. +X is forward. No star arms or glow. Center anchor 96,24.'))

chip_body = ('<path d="M12 35 L37 25 L82 17 L116 29 L91 40 L43 45Z" fill="#9c9c9c" fill-opacity="0.86"/>'
             '<path d="M37 25 L82 17 L116 29 L69 31Z" fill="#eeeeee" fill-opacity="0.98"/>'
             '<path d="M12 35 L69 31 L116 29 L91 40 L43 45Z" fill="#6b6b6b" fill-opacity="0.65"/>'
             '<path d="M27 33 L77 26 L111 29 L69 32Z" fill="#ffffff" fill-opacity="0.90"/>')
write('textures/spark_chip.svg', svg(128,64,chip_body,desc=
      'Original tapered asymmetrical chip with three grayscale facets. +X forward; center anchor 64,32. No glow.'))

# Annular support, NOT the visible silhouette: transparent texture determines it.
verts, uvs, faces = [], [], []
for i in range(49):
    angle = math.radians(-158. + 136. * i/48.)
    for radius in (378., 544.):
        x, y = radius*math.cos(angle), radius*math.sin(angle)
        verts.append([round(x,9),round(y,9),0.])
        uvs.append([round((x+CX)/W,9),round((y+CY)/H,9)])
    if i < 48:
        k=i*2
        faces.extend([[k,k+1,k+2],[k+1,k+3,k+2]])
mesh = {'schema':'electric-slash-support-v1','units':'design_pixels',
        'plane':'XY, +Y down in Godot 2D','pivot':[0,0,0],
        'texture_size_px':[W,H],'pivot_texture_px':[CX,CY],
        'uv_origin':'top_left','uv_mapping':'((local_x+512)/1024, (local_y+652)/640)',
        'angular_segments':48,'radial_rows':2,'inner_radius':378.,'outer_radius':544.,
        'theta_degrees':[-158.,-22.], 'vertices':verts,'uvs':uvs,'triangles':faces}
write('meshes/crescent_support.json',json.dumps(mesh,indent=2))
obj = ['# Original annular support in design pixels. JSON UVs are authoritative for Godot.',
       '# Standard OBJ lower-left V is written as 1 - Godot_V. Pivot is local 0,0,0.','o CrescentSupport']
obj += [f'v {x:.9f} {y:.9f} {z:.9f}' for x,y,z in verts]
obj += [f'vt {u:.9f} {1-v:.9f}' for u,v in uvs]
obj += ['vn 0 0 1']
obj += ['f '+' '.join(f'{i+1}/{i+1}/1' for i in f) for f in faces]
write('meshes/crescent_support.obj','\n'.join(obj)+'\n')

def embedded_asset(name,x,y,w,h):
    data = base64.b64encode((TEX/name).read_bytes()).decode()
    return f'<image x="{x}" y="{y}" width="{w}" height="{h}" href="data:image/svg+xml;base64,{data}"/>'

def text(x,y,value,size=20,color='#c8c8c8',weight=400):
    value=value.replace('&','&amp;').replace('<','&lt;').replace('>','&gt;')
    return f'<text x="{x}" y="{y}" fill="{color}" font-size="{size}" font-weight="{weight}" font-family="Segoe UI,Arial,sans-serif">{value}</text>'

def rect(x,y,w,h,fill='#212327',stroke='#3b3d41',rx=14):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="{fill}" stroke="{stroke}"/>'

def cross(x,y,size=7):
    return f'<path d="M{x-size} {y} H{x+size} M{x} {y-size} V{y+size}" fill="none" stroke="#858585" stroke-width="1"/>'

checker = ('<pattern id="check" width="24" height="24" patternUnits="userSpaceOnUse">'
           '<rect width="24" height="24" fill="#292b2f"/><path d="M0 0H12V12H0ZM12 12H24V24H12Z" fill="#25272b"/></pattern>')
board = [rect(0,0,1600,1060,'#15171b','#15171b',0),
         text(40,58,'ELECTRIC SLASH / ASSET DESIGN',34,'#f0f0f0',600),
         text(40,94,'One curved blade mass + two supporting spark shapes. Grayscale assets; no glow or scene composite.',20),
         rect(40,126,996,514),rect(1064,126,496,514),
         text(66,166,'01 / CRESCENT BODY',23,'#ececec',600),
         text(66,195,'1024 × 640 canvas · asymmetrical thickness · sharp outer arc',18),
         rect(66,217,944,360,'url(#check)','#424448',6),
         embedded_asset('crescent_mask.svg',140,184,796,498),
         text(66,610,'The silhouette lives in the mask. 12 px inner feather; no baked blur or lightning.',18),
         text(1090,166,'02 / OUTER EDGE',23,'#ececec',600),
         text(1090,195,'Same canvas, pivot and planar UVs',18),
         rect(1090,217,444,278,'url(#check)','#424448',6),
         embedded_asset('crescent_edge.svg',1090,217,444,278),
         text(1090,529,'A 7 px band at mid-arc.',19),
         text(1090,558,'Kept separate for a restrained hot rim.',18),
         text(1090,589,'Body and edge must share distortion.',18),
         rect(40,668,740,304),rect(808,668,752,304),
         text(66,708,'03 / NEEDLE STREAK',23,'#ececec',600),
         text(66,738,'192 × 48 canvas · active 176 × 14 · ≈12.6:1',18),
         rect(66,762,688,112,'url(#check)','#424448',6),
         embedded_asset('spark_needle.svg',172,758,480,120),cross(412,818),
         text(66,908,'Directional release: a fine tail, fuller head, pointed +X tip.',18),
         text(66,938,'Value/alpha rise toward the head; no cross-shaped flare.',18),
         text(834,708,'04 / TAPERED CHIP',23,'#ececec',600),
         text(834,738,'128 × 64 canvas · active 104 × 28 · ≈3.7:1',18),
         rect(834,762,700,112,'url(#check)','#424448',6),
         embedded_asset('spark_chip.svg',1030,742,320,160),cross(1190,822),
         text(834,908,'Short-lived fleck: a compact, unequal polygon with three facets.',18),
         text(834,938,'Broader than the needle; direction remains readable when small.',18),
         text(40,1020,'DESIGN PROPOSAL · Original code-authored vectors · Source-game screenshot consulted for shape families only.',18,'#92969d')]
write('asset-board.svg',svg(1600,1060,''.join(board),checker,
      'Review board of usable grayscale slash and spark assets, without compositing or glow.'))

# Explicit geometry ↔ UV relationship, with corresponding triangles and pivot.
topo = [rect(0,0,1600,1100,'#15171b','#15171b',0),
        text(40,58,'CRESCENT / MESH + PLANAR UV',34,'#f0f0f0',600),
        text(40,94,'Chosen support: annular sector. The texture already contains the crescent; its UVs are never unwrapped into a strip.',20),
        rect(40,126,744,650),rect(812,126,748,650),
        text(66,166,'A / LOCAL XY SUPPORT',23,'#ececec',600),
        text(66,196,'48 angular segments · 98 vertices · 96 triangles',18),
        text(838,166,'B / TEXTURE UV SPACE',23,'#ececec',600),
        text(838,196,'1024 × 640 · top-left (0,0) · planar correspondence',18)]
origin=(412.,660.); scale=.64
topo.append(embedded_asset('crescent_mask.svg',origin[0]-CX*scale,origin[1]-CY*scale,W*scale,H*scale))
topo.append(f'<g transform="translate({origin[0]} {origin[1]}) scale({scale})" fill="none" stroke="#75797f" stroke-width="1.0" opacity="0.9">')
for face in faces:
    points=' '.join(f'{verts[i][0]:.4f},{verts[i][1]:.4f}' for i in face)
    topo.append(f'<polygon points="{points}"/>')
topo.append('</g>')
topo += [cross(*origin,10),text(258,703,'Pivot = local (0,0)',18),
         text(66,742,'Support radii 378–544 px / angles −158°…−22°',18)]
uvbox=(858.,234.,640.,400.)
topo += [rect(*uvbox,'url(#check)','#5b5e64',0),embedded_asset('crescent_mask.svg',*uvbox)]
for face in faces:
    points=' '.join(f'{uvbox[0]+uvs[i][0]*uvbox[2]:.4f},{uvbox[1]+uvs[i][1]*uvbox[3]:.4f}' for i in face)
    topo.append(f'<polygon points="{points}" fill="none" stroke="#75797f" stroke-width="0.65" opacity="0.9"/>')
uvpivot=(uvbox[0]+CX/W*uvbox[2],uvbox[1]+CY/H*uvbox[3])
head=xy(1.,R); tail=xy(0.,R)
head_uv=(head[0]/W,head[1]/H)
head_local=(head[0]-CX,head[1]-CY)
head_left=(origin[0]+head_local[0]*scale,origin[1]+head_local[1]*scale)
head_right=(uvbox[0]+head_uv[0]*uvbox[2],uvbox[1]+head_uv[1]*uvbox[3])
for hx,hy in [head_left,head_right]:
    topo.append(f'<circle cx="{hx}" cy="{hy}" r="4" fill="#ffffff" stroke="#15171b"/>')
    topo.append(f'<path d="M{hx} {hy} l-32 47" stroke="#d8d8d8" fill="none"/>')
topo += [text(head_left[0]-140,head_left[1]+70,'active leading tip',18),
         text(head_right[0]-145,head_right[1]+70,'same tip in UV',18),
         cross(*uvpivot,10),text(1000,690,'Pivot px (512,652) = UV (0.5,1.01875)',18),
         text(838,742,'Pivot sits 12 px below the texture; transparent support is padding.',18),
         rect(40,808,1520,234),
         text(66,850,'AUTHORITATIVE MAPPING',20,'#ececec',600),
         text(66,884,'θ = −158° + 136° · i/48     r ∈ {378,544}     local = (r cos θ, r sin θ)',20),
         text(66,920,'UV = ((local.x + 512)/1024, (local.y + 652)/640)     No angular U/radial V remap.',20),
         text(66,956,'Active tip: θ = −26°, r = 520 px. Texture px ≈ (979.373,424.047).',20),
         text(66,992,'Guide alignment: rotate by (blade angle + 26°), scale by 235/520, then project Y × 0.58 and add hand position.',20),
         text(40,1080,'A four-vertex card is viable for a static sprite. This support keeps padding for distortion while avoiding the empty crescent center.',17,'#92969d')]
write('topology-uv.svg',svg(1600,1100,''.join(topo),checker,
      'Original mesh, texture and UV relationship. The active mask tip is distinguished from padded geometry bounds.'))

manifest = {
  'schema':'electric-asset-design-v1','date':'2026-10-24','status':'asset_design_ready_for_production_integration',
  'scope':'One curved gameplay sword slash and two supporting spark shapes; no character or emitter implementation.',
  'origin':'Original code-authored vector paths and mesh data. PNGs are direct SVG rasterizations.',
  'source_game_facts':[],
  'reference_consulted':[
    {'path':'../rpg-references/raiden-104.png','use':'Qualitative shape-family observation only; no tracing/extraction; overloaded scene is not the brief.'},
    {'path':'../electric-skills-trial/electric-skills-passes.jpg','use':'Current rendered trial; confirms prior straight dry-brush ribbon and repeated spark mask.'},
    {'path':'../electric-production-study/gameplay-blockout-beats.jpg','use':'Unchanged motion-guide silhouette and contact context.'}
  ],
  'chosen_topology':{'type':'planar_annular_sector_support','reason':'An authored crescent mask with explicit XY UVs, enough padding for modest distortion, and less transparent center than a quad.',
    'vertices':98,'triangles':96,'angular_segments':48,'radial_rows':2,'radius_px':[378,544],'theta_degrees':[-158,-22],
    'primary_mesh':'meshes/crescent_support.json','reference_mesh':'meshes/crescent_support.obj',
    'obj_uv_convention':'OBJ file stores 1 - Godot V; JSON top-left UVs are authoritative.',
    'not_selected':{'flat_card':'Simplest valid alternative for static display, but retains the empty center and offers no explicit curved support.',
                    'angularly_unwrapped_strip':'Would require a straight mask and makes the authored asset cease to be a visible crescent. Not used.'}},
  'coordinate_contract':{
    'texture_px':[1024,640],'texture_origin':'top_left','local_pivot':[0,0], 'pivot_texture_px':[512,652],
    'pivot_uv':[.5,652/640], 'uv_formula':'((local.x+512)/1024,(local.y+652)/640)',
    'active_theta_degrees':[-154,-26],'active_radius_outer_px':520,
    'active_head':{'theta_degrees':-26,'radius_px':520,'texture_px':list(head),'local_px':list(head_local),'uv':list(head_uv)},
    'active_tail':{'theta_degrees':-154,'radius_px':520,'texture_px':list(tail)},
    'guide_alignment':{'radial_scale':235/520,'rotation_radians':'guide.angle(t)-deg_to_rad(-26)',
      'order':['rotate local XY','uniform radial scale 235/520','project Y *= 0.58','add guide.hand(t)'],
      'tip_should_equal':'guide.tip(t) without any character-motion changes'}
  },
  'assets':[
    {'id':'crescent_body','svg':'textures/crescent_mask.svg','png':'textures/crescent_mask.png','canvas_px':[1024,640],
      'anchor_texture_px':[512,652], 'appearance':'Neutral grayscale RGB, alpha; no glow. Outer circular arc, asymmetrical inner thickness, pointed ends.',
      'design_values':{'rgb_range':'#484848–#ececec','alpha_max_analytic':.91,'inner_feather_px':12,
                       'width_px_formula':'125*sin(pi*t)^0.9*(0.5+0.8*t), t=(theta+154)/128'},
      'role':'Main broad curved mass; supplies readable slash before shader treatment.'},
    {'id':'crescent_edge','svg':'textures/crescent_edge.svg','png':'textures/crescent_edge.png','canvas_px':[1024,640],
      'anchor_texture_px':[512,652],'design_values':{'rgb_range':'#8d8d8d–#ffffff','alpha_range':[0,1],'midarc_width_px':7},
      'role':'Separate thin hot outer contour; exact same mesh, UV and distortion as body.'},
    {'id':'spark_needle','svg':'textures/spark_needle.svg','png':'textures/spark_needle.png','canvas_px':[192,48],
      'anchor_texture_px':[96,24],'direction_axis':'+X','active_bounds_analytic_px':[8,17,184,31],
      'active_aspect_analytic':176/14,'design_values':{'rgb_range':'#747474–#ffffff','alpha':'0.02 at thin tail, rising to 1 at head; narrow white spine'},
      'role':'Few fast directed releases. Fine tapered tail carries speed; pointed fuller head reads direction.'},
    {'id':'spark_chip','svg':'textures/spark_chip.svg','png':'textures/spark_chip.png','canvas_px':[128,64],
      'anchor_texture_px':[64,32],'direction_axis':'+X','active_bounds_analytic_px':[12,17,116,45],
      'active_aspect_analytic':104/28,'design_values':{'facet_rgb':['#9c9c9c','#eeeeee','#6b6b6b','#ffffff'],'facet_alpha':[.86,.98,.65,.90]},
      'role':'Few compact detached flecks near release; unequal polygon and facets remain distinct from thin needles.'}
  ],
  'proposed_material_layers':['crescent body','crescent edge, same geometry/UV/distortion','needle particles','chip particles'],
  'emitter_implications_after_shape_design':[
    'Use separate emitters/material scales for needle and chip; do not reinterpret one star mask as both.',
    'Needle long axis +X follows the release velocity; preserve its thin aspect instead of isotropically scaling a large square.',
    'Chip may rotate independently; keep its compact aspect, lower travel and short visible life.',
    'Spawn a few near the leading release region after the crescent is established. Do not fill the entire arc with generic particles.',
    'No exact counts, speeds or lifetimes are approved at asset stage; tune in the fixed motion guide at gameplay size.'
  ],
  'distortion_contract':{
    'space':'Planar texture pixel offsets, converted by /vec2(1024,640). Use identical offsets for body and edge.',
    'starting_bound_px':4,'head_tail_protection':'Fade distortion to zero within the last/first 8% of active angular extent.',
    'silhouette_first':'Keep the outer arc and pointed tip readable; noise must not become the primary shape.',
    'screen_refraction':'Optional later material decision; not part of these assets or a required additional layer.'},
  'known_limits':[
    'Asset board is a neutral design view, not a final VFX composite or an approved animation.',
    'Clean vector shape is intentional; final shader distortion/erosion, tint and additive balance need root visual validation.',
    'Needle cubic control-point envelope is 14 px high; its raster-visible height can be smaller. Use raster measurement for final particle scale.',
    'OBJ is reference geometry; use JSON for MeshInstance2D to avoid importer coordinate conventions.',
    'No new gameplay hit timing, character animation, emitters, export, deployment or source-repo changes.'
  ]
}
write('manifest.json',json.dumps(manifest,indent=2,ensure_ascii=False)+'\n')
print(json.dumps({'created_in':str(HERE),'vector_assets':4,'mesh_vertices':len(verts),'mesh_triangles':len(faces),'active_head_px':head}))
