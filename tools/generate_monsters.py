"""Deterministic hand-coded 8-bit-inspired pixel monsters. No copied game/video sprites."""
from pathlib import Path
from PIL import Image, ImageDraw
import math

ROOT=Path(__file__).resolve().parents[1]
DIR=ROOT/'assets'/'enemies'
DIR.mkdir(parents=True,exist_ok=True)
SIZES={'slime':(48,48),'boar':(64,56),'wolf':(64,56),'mushroom':(48,56),'elite_boar':(64,56),'alpha_wolf':(96,80)}
INK='#19182B'

def monster(kind,frame):
    w,h=SIZES[kind]; im=Image.new('RGBA',(w,h),(0,0,0,0));d=ImageDraw.Draw(im)
    oy=(frame%2)*2
    def rect(box,c,outline=None):d.rectangle(box,fill=c,outline=outline)
    def poly(points,c,outline=INK,width=2):d.polygon(points,fill=c);d.line(points+[points[0]],fill=outline,width=width) if outline else None
    def eye(x,y):rect((x,y,x+3,y+4),INK);rect((x,y,x+1,y+1),'#FFFFFF')
    if kind=='slime':
        # hopping moss slime with highlights and distinct dark pixel silhouette
        poly([(8,37),(7,29+oy),(10,21+oy),(16,16+oy),(25,15+oy),(33,19+oy),(40,29+oy),(40,38),(34,41),(14,41)],'#258E83')
        poly([(14,24+oy),(19,18+oy),(27,18+oy),(34,24+oy),(34,32+oy),(13,32+oy)],'#43C8AE',None)
        rect((15,21+oy,21,23+oy),'#97ECD5');rect((13,35,17,37),'#126D76');rect((32,37,37,40),'#126D76')
        eye(18,29+oy);eye(29,28+oy);rect((24,34,29,34),INK)
    elif kind in ('boar','elite_boar'):
        elite=kind=='elite_boar';body='#805157' if elite else '#A87046';light='#BF7B72' if elite else '#DDA071'
        poly([(7,31+oy),(12,24+oy),(23,20+oy),(45,22+oy),(54,30+oy),(50,42+oy),(13,43+oy)],body)
        rect((14,39+oy,21,50),INK);rect((41,39+oy,48,50),INK)
        poly([(39,24+oy),(50,23+oy),(58,30+oy),(58,36+oy),(50,40+oy),(42,35+oy)],light)
        poly([(42,31+oy),(53,33+oy),(60,40+oy),(54,40+oy),(47,36+oy)],'#B86B6E' if elite else '#E7A18E',None)
        poly([(47,35+oy),(50,44+oy),(55,43+oy),(53,34+oy)],'#FFF3D6')
        poly([(13,24+oy),(17,14+oy),(25,21+oy)],'#6B4047' if elite else '#84523C')
        eye(43,28+oy)
        if elite:
            for bx in [16,30,43]:poly([(bx,22+oy),(bx+4,12+oy),(bx+8,20+oy)],'#8899A8')
            rect((17,25+oy,40,29+oy),'#C6AF69');rect((23,29+oy,28,34+oy),'#EFE2AB')
    elif kind in ('wolf','alpha_wolf'):
        boss=kind=='alpha_wolf';sx=1.35 if boss else 1.0;sy=1.15 if boss else 1.0
        # draw to normalized space then nearest-neighbor enlarge for the boss
        if boss:
            mini=monster('wolf',frame)
            im=mini.resize((90,78),Image.Resampling.NEAREST)
            d=ImageDraw.Draw(im);d.polygon([(10,36),(20,11),(30,31)],fill='#25263D');d.polygon([(27,22),(50,7),(67,22),(58,31)],fill='#54546E');d.rectangle((70,36,79,39),fill='#FF9B59')
            return im.crop((0,0,w,h))
        poly([(9,28+oy),(12,18+oy),(17,13+oy),(25,20+oy),(39,22+oy),(49,16+oy),(58,24+oy),(52,34+oy),(45,36+oy),(16,37+oy)],'#465B65')
        poly([(41,21+oy),(50,13+oy),(60,13+oy),(62,24+oy),(53,31+oy),(44,28+oy)],'#677A78')
        poly([(44,18+oy),(46,7+oy),(51,14+oy)],'#354452');poly([(53,17+oy),(60,8+oy),(61,21+oy)],'#354452')
        rect((17,36+oy,22,47),INK);rect((39,34+oy,44,47),INK)
        poly([(11,22+oy),(7,13+oy),(5,14+oy),(6,28+oy)],'#819393')
        poly([(45,29+oy),(53,31+oy),(54,37+oy),(45,34+oy)],'#CFD0AF',None)
        eye(53,20+oy);rect((60,28+oy,62,31+oy),INK)
    elif kind=='mushroom':
        poly([(16,31+oy),(33,31+oy),(34,43+oy),(29,49+oy),(19,49+oy),(15,43+oy)],'#E9D3A9')
        poly([(6,30+oy),(10,19+oy),(18,13+oy),(30,12+oy),(39,20+oy),(44,31+oy),(36,34+oy),(12,34+oy)],'#8C447A')
        for x,y in [(14,25),(24,18),(34,25)]:rect((x,y+oy,x+5,y+2+oy),'#F3DDB7')
        rect((19,39+oy,22,43+oy),INK);rect((29,39+oy,32,43+oy),INK)
        rect((20,47+oy,27,47+oy),'#BE9369')
    return im

for kind,(w,h) in SIZES.items():
    sheet=Image.new('RGBA',(w*4,h))
    # Use the SAME shift for all frames, preserving bounce/walk animation.
    base_bounds = monster(kind,0).getchannel('A').getbbox()
    shift_y = (h - 3) - base_bounds[3]
    shift_x = -2 if base_bounds[2] >= w - 1 else 0
    for frame in range(4):
        image = monster(kind,frame)
        grounded = Image.new('RGBA',(w,h),(0,0,0,0))
        grounded.paste(image,(shift_x,shift_y))
        sheet.paste(grounded,(frame*w,0))
    sheet.save(DIR/f'{kind}_sheet.png',optimize=True)
print('Generated',len(SIZES),'8-bit styled enemy sheets in',DIR)
