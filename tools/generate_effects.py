"""Repeatable 1:1 pixel effects. Six 32x32 frames per character."""
from pathlib import Path
from PIL import Image, ImageDraw
from math import sin, cos, pi

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets'/'effects'
OUT.mkdir(parents=True,exist_ok=True)
SIZE=32

COLORS={
 'rudeus':('#183E67','#49B5FE','#E8F9F5'),
 'sylphie':('#225842','#7DDE95','#F1FDE2'),
 'roxy':('#234B83','#64D6FF','#F2FDFF'),
 'eris':('#933E3B','#FF8B59','#FFF5BF')
}

def frame(hero, index):
    image=Image.new('RGBA',(SIZE,SIZE),(0,0,0,0))
    d=ImageDraw.Draw(image)
    dark,mid,light=COLORS[hero]
    t=index/5
    if hero=='eris':
        # A six-frame pixel sword arc and impact burst.
        reach=5+index*3
        d.line([(7,25),(10+reach,24-int(reach*.58))],fill=dark,width=5)
        d.line([(8,24),(11+reach,23-int(reach*.58))],fill=mid,width=3)
        d.line([(10,23),(10+reach,22-int(reach*.58))],fill=light,width=1)
        for j in range(3):
            x=min(30,14+index*3+j*2); y=max(1,20-index*2-j)
            d.rectangle((x,y,x+1,y+1),fill=light)
    elif hero=='rudeus':
        # Blue arcane diamond / stone cast traveling toward the target.
        x=7+index*3; y=15
        d.polygon([(x,y-8),(x+6,y),(x,y+8),(x-6,y)],fill=dark)
        d.polygon([(x,y-6),(x+4,y),(x,y+6),(x-4,y)],fill=mid)
        d.line([(x,y-5),(x+3,y),(x,y+3)],fill=light,width=1)
        d.rectangle((max(0,x-10),19,max(0,x-9),20),fill=mid)
    elif hero=='roxy':
        # Ice crystals: angular shards, not blurred rings.
        x=14+int(3*sin(t*pi)); y=16
        d.polygon([(x,y-12),(x+5,y),(x,y+11),(x-4,y)],fill=dark)
        d.polygon([(x,y-10),(x+3,y),(x,y+9),(x-2,y)],fill=mid)
        d.line([(x,y-8),(x,y+6)],fill=light,width=1)
        for dx,dy in [(-8,3),(8,-4),(-9,-6),(8,7)]:
            if (index+dx)%3!=0:
                d.rectangle((x+dx,y+dy,x+dx+1,y+dy+1),fill=light)
    else:
        # Sylphie's healer sigil / shield, cross readable at compact size.
        x,y=16,16; radius=5+index//2
        d.rectangle((x-radius,y-radius,x+radius,y+radius),outline=dark,width=2)
        d.line([(x,y-8),(x,y+8)],fill=mid,width=3)
        d.line([(x-8,y),(x+8,y)],fill=mid,width=3)
        d.line([(x,y-5),(x,y+5)],fill=light,width=1)
        d.line([(x-5,y),(x+5,y)],fill=light,width=1)
    return image

for name in COLORS:
    sheet=Image.new('RGBA',(SIZE*6,SIZE),(0,0,0,0))
    for i in range(6):sheet.paste(frame(name,i),(SIZE*i,0))
    sheet.save(OUT/f'{name}_cast.png',optimize=True)
print('Generated 4 x 6-frame pixel combat effect sheets')
