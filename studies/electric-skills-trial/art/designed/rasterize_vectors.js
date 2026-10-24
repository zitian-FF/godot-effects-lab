// Direct rasterization of original SVG vectors. No image synthesis or editing.
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const sharp = require('C:/Users/Zitian/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/sharp');
const root = __dirname;
const names = ['textures/crescent_mask','textures/crescent_edge','textures/spark_needle','textures/spark_chip','asset-board','topology-uv'];
(async()=>{
  for (const name of names) {
    await sharp(path.join(root,name+'.svg'), { density: 72 }).png().toFile(path.join(root,name+'.png'));
  }
  const measures=[];
  for (const name of names.slice(0,4)) {
    const file=path.join(root,name+'.png');
    const {data,info}=await sharp(file).ensureAlpha().raw().toBuffer({resolveWithObject:true});
    let minx=info.width,miny=info.height,maxx=-1,maxy=-1,minAlpha=255,maxAlpha=0,nonGray=0,covered=0,borderNonzero=0;
    for(let y=0;y<info.height;y++)for(let x=0;x<info.width;x++) {
      const o=(y*info.width+x)*4, a=data[o+3];
      minAlpha=Math.min(minAlpha,a);maxAlpha=Math.max(maxAlpha,a);
      if(a>0){minx=Math.min(minx,x);maxx=Math.max(maxx,x);miny=Math.min(miny,y);maxy=Math.max(maxy,y);covered++;
        if(data[o]!==data[o+1]||data[o]!==data[o+2])nonGray++;
        if(x===0||y===0||x===info.width-1||y===info.height-1)borderNonzero++;
      }
    }
    measures.push({path:name+'.png',width:info.width,height:info.height,alpha_range:[minAlpha,maxAlpha],
      alpha_nonzero_bounds_inclusive:[minx,miny,maxx,maxy],covered_fraction:covered/(info.width*info.height),
      non_grayscale_visible_pixels:nonGray,nontransparent_border_pixels:borderNonzero,
      sha256:crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
  }
  const manifestPath=path.join(root,'manifest.json');
  const manifest=JSON.parse(fs.readFileSync(manifestPath,'utf8'));
  manifest.raster_validation=measures;
  manifest.provenance_files=['build_assets.py','rasterize_vectors.js'];
  manifest.sha256={};
  for(const name of [...names.flatMap(n=>[n+'.svg',n+'.png']),'meshes/crescent_support.json','meshes/crescent_support.obj','build_assets.py','rasterize_vectors.js']) {
    manifest.sha256[name]=crypto.createHash('sha256').update(fs.readFileSync(path.join(root,name))).digest('hex');
  }
  fs.writeFileSync(manifestPath,JSON.stringify(manifest,null,2)+'\n');
  console.log(JSON.stringify({rasterized:names.length,validation:measures},null,2));
})().catch(e=>{console.error(e);process.exit(1)});
