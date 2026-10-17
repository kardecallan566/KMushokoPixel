"""Original foliage embellishment with reproducible pixel-grid placement."""
from pathlib import Path
from PIL import Image,ImageDraw
import random
ROOT=Path(__file__).resolve().parents[1]
W,H=960,64
out=Image.new('RGBA',(W,H));d=ImageDraw.Draw(out)
rng=random.Random(1025)
for _ in range(190):
    x=rng.randrange(0,W);y=rng.randrange(12,60)
    # distinct foreground grass & stalks at natural pixel resolution
    if rng.random()<.72:
        color=rng.choice(['#2F7E53','#286D55','#65B45B','#B3D76D'])
        d.line((x,y+4,x-2,y-2),fill=color,width=1)
        d.line((x,y+4,x+3,y-3),fill=color,width=1)
        d.line((x,y+4,x,y-5),fill=color,width=1)
    else:
        col=rng.choice(['#F6F0D9','#F7D376','#F4B9CA'])
        d.line((x,y+6,x,y+1),fill='#2C6E50',width=1)
        d.rectangle((x-2,y-2,x+2,y+2),fill=col)
        d.rectangle((x-1,y-1,x+1,y+1),fill='#FEFAE8')
        d.point((x,y),fill='#E6B64B')
for x in (132,426,688,925):
    d.polygon([(x-10,50),(x-7,44),(x+2,40),(x+10,43),(x+15,50),(x+8,54),(x-7,54)],fill='#5A6673')
    d.line((x-7,47,x+1,43,x+7,44),fill='#A2A8A1',width=2)
out.save(ROOT/'assets/biomes/green_plains/details.png')
if __name__=='__main__':print('Created',W,H)
