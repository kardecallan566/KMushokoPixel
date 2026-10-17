"""Rebuild sprite sheets from checked-in, review-only base art. No video needed at CI time.
The source pixel portraits were traced from the user-provided Reel as prototype assets.
Source rights must be verified before public redistribution or commercial use.
"""
from PIL import Image, ImageDraw, ImageEnhance
from pathlib import Path
import math

ROOT=Path(__file__).resolve().parents[1]
CELL=(72,100)
COUNTS={'idle':4,'walk':8,'cast':6,'hit':2}
TOTAL=sum(COUNTS.values())


def paint(name):
    base=Image.open(ROOT/f'assets/characters/source/{name}.png').convert('RGBA')
    assert base.size==CELL
    sheet=Image.new('RGBA',(CELL[0]*TOTAL,CELL[1]))
    frames=[]
    for i in range(TOTAL):
        im=Image.new('RGBA',CELL)
        if i<4:
            # small breathing motion, with fixed foot anchor at y 94
            bounce=(0,0,1,0)[i]
            shift=0
            state='idle'
        elif i<12:
            step=i-4
            bounce=(0,1,2,1,0,1,2,1)[step]
            shift=(0,-1,-1,0,0,1,1,0)[step]
            state='walk'
        elif i<18:
            bounce=0;shift=0;state='cast'
        else:
            bounce=0;shift=0;state='hit'
        # The fourth pose previously switched to a different art style and changed
        # the character's identity mid-walk. Lock head/hair/face/outfit from one
        # base and animate only the legs and cape using compatible pixel poses.
        if state == 'walk':
            source_index = (0, 1, 2, 1, 0, 1, 2, 1)[i - 4]
            src_path = ROOT / f'assets/characters/source/walk{source_index}/{name}.png'
            if not src_path.is_file():
                raise FileNotFoundError(src_path)
            src = Image.open(src_path).convert('RGBA')
            src.paste(base.crop((0, 0, CELL[0], 59)), (0, 0))
            shift = 0
            bounce = 0
        else:
            src=base.copy()
        if state=='hit':
            red=Image.new('RGBA',CELL,(255,83,91,65))
            # tint only painted pixels
            m=src.getchannel('A'); red.putalpha(m.point(lambda a:int(a*.35)))
            src=Image.alpha_composite(src,red)
        im.alpha_composite(src,(shift,-bounce))
        # no fake procedural limb transformation that could create moonwalking:
        # the video-derived silhouette is kept intact for reference fidelity.
        if state=='cast':
            d=ImageDraw.Draw(im)
            phase=(i-12)/5
            if name=='rudeus':color=(104,211,247)
            elif name=='roxy':color=(109,173,255)
            elif name=='sylphie':color=(105,238,158)
            else: color=(253,143,100)
            x=7 if name!='eris' else 4
            y=52
            for q in range(3):
                rad=2+int((q+phase)*1.2)
                d.line((x+rad,y-4-q*4,x+rad+3,y-4-q*4),fill=(*color,235),width=1)
        sheet.alpha_composite(im,(i*CELL[0],0))
        frames.append(im)
    sheet.save(ROOT/f'assets/characters/{name}_sheet.png',optimize=True)
    return sheet

if __name__=='__main__':
    for name in ['rudeus','sylphie','roxy','eris']:
        sheet=paint(name)
        print(name, sheet.size)
