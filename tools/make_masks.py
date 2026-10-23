from pathlib import Path
import random, math
r=Path(__file__).resolve().parents[1]/'source/art/rpg';r.mkdir(parents=True,exist_ok=True)
def svg(name,body,w=512,h=512):
    (r/(name+'.svg')).write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}"><defs><linearGradient id="g" x1="0" y1="1" x2="1" y2="0"><stop stop-color="#777" stop-opacity=".1"/><stop offset=".5" stop-color="#ccc"/><stop offset="1" stop-color="white"/></linearGradient><radialGradient id="r"><stop stop-color="white"/><stop offset=".3" stop-color="#ddd" stop-opacity=".8"/><stop offset="1" stop-color="#aaa" stop-opacity="0"/></radialGradient></defs>{body}</svg>')
random.seed(2901)
for name,depth in [('wind',105),('fire',160)]:
    body=f'<path d="M35 366 Q105 80 355 130 Q470 155 495 290 Q383 123 191 220 Q103 265 35 366Z" fill="url(#g)"/>'
    for j in range(27):
        y=random.randint(132,230);x=random.randint(45,130)
        body+=f'<path d="M{x} {365-j*3} Q{120+j*2} {y} {365+j*2} {148+j*3}" fill="none" stroke="white" stroke-opacity="{random.uniform(.08,.5):.2f}" stroke-width="{random.uniform(.8,3):.1f}"/>'
    body+='<path d="M35 366 Q105 80 355 130 Q470 155 495 290" fill="none" stroke="white" stroke-width="3"/>'
    svg(name,body)
svg('butterfly','<path d="M252 263 C160 87 46 127 98 250 C119 283 178 291 241 279 C140 281 125 403 212 352 L254 282 L277 355 C371 396 383 280 269 276 C359 289 433 215 397 159 C365 109 293 158 261 258Z" fill="url(#g)"/><path d="M255 238 L260 300 M254 243 Q221 211 221 196 M261 243 Q292 210 296 199" fill="none" stroke="white" stroke-width="7"/>')
svg('eye','<path d="M29 255 Q255 69 484 255 Q256 438 29 255Z M62 255 Q255 145 450 255 Q256 365 62 255Z" fill="white" fill-rule="evenodd"/><circle cx="256" cy="255" r="63" fill="none" stroke="white" stroke-width="9"/><path d="M256 198 L282 273 L234 281Z" fill="white"/><path d="M64 232 L6 214 M448 276 L508 293" stroke="white" stroke-width="5"/>')
svg('petal','<path d="M249 466 C189 366 75 279 162 90 Q189 37 242 15 C340 107 388 277 260 466Z" fill="url(#g)"/><path d="M249 466 Q267 176 242 15 L303 241Z" fill="white" fill-opacity=".8"/><path d="M242 15 Q129 189 249 466 Q179 304 183 230Z" fill="#aaa"/><path d="M242 15 L249 466 M164 137 L288 297 M173 224 L280 355" stroke="white" stroke-width="2" fill="none"/>')
svg('canopy','<path d="M54 273 C62 33 448 33 458 273 C393 316 346 267 319 281 C284 314 237 319 201 280 C160 267 116 318 54 273Z" fill="url(#g)" fill-opacity=".43"/><path d="M54 273 C62 33 448 33 458 273 M54 273 Q117 311 171 276 Q253 331 323 278 Q397 317 458 273" fill="none" stroke="white" stroke-width="6"/><path d="M143 286 C190 339 101 391 176 474 M251 304 C325 370 192 405 260 490 M355 286 C319 352 416 399 342 458" stroke="white" stroke-opacity=".7" stroke-width="7" fill="none"/><ellipse cx="255" cy="174" rx="96" ry="50" fill="url(#r)"/>')
svg('lance','<path d="M8 249 L365 227 L497 255 L365 282 L8 261 L256 254Z" fill="url(#g)"/><path d="M26 255 L490 255" stroke="white" stroke-width="4"/><path d="M344 231 L365 206 L493 255 L367 301 L344 280 L405 255Z" fill="white" fill-opacity=".7"/>')
svg('gas','<path d="M47 254 C102 235 113 217 176 201 L211 133 L247 197 L381 173 L341 218 L484 251 L370 272 L410 314 L252 293 L212 371 L177 298 C123 288 95 270 47 254Z" fill="url(#g)"/><path d="M49 255 Q236 213 406 254 Q233 288 49 255Z" fill="white"/><path d="M129 244 L234 231 L375 256 L207 268Z" fill="#fff"/>')
svg('drop','<path d="M256 50 C240 151 122 248 145 346 C172 473 348 469 371 347 C389 260 274 140 256 50Z" fill="url(#g)"/><path d="M195 277 Q158 352 216 388" stroke="white" stroke-width="14" stroke-linecap="round" fill="none"/>')
svg('feather','<path d="M60 449 C126 345 106 105 456 43 C412 131 392 218 238 256 C379 259 223 381 60 449Z" fill="url(#g)"/><path d="M59 450 Q245 204 456 43" fill="none" stroke="white" stroke-width="7"/>'+''.join(f'<path d="M{100+i*19} {400-i*19} Q{150+i*19} {260-i*14} {245+i*12} {165-i*9}" stroke="white" stroke-opacity=".5" stroke-width="4" fill="none"/>' for i in range(12)))
svg('spark','<path d="M256 33 L273 231 L443 256 L275 274 L256 482 L238 278 L58 256 L238 235Z" fill="white"/>')
svg('smoke','<path d="M91 332 C-12 220 163 118 236 201 C165 80 362 26 410 179 C491 152 533 277 451 337 C372 426 259 374 239 320 C172 401 114 395 91 332Z" fill="url(#r)"/>')
svg('seal','<ellipse cx="256" cy="256" rx="220" ry="200" fill="none" stroke="white" stroke-opacity=".6" stroke-width="5"/><ellipse cx="256" cy="256" rx="189" ry="174" fill="none" stroke="white" stroke-width="2"/>'+''.join(f'<path d="M{256+207*math.cos(i*math.pi/6):.1f} {256+190*math.sin(i*math.pi/6):.1f} l8 -15 l9 14 l-8 16Z" fill="white"/>' for i in range(12)))
print('Authored original alpha masks in',r)
