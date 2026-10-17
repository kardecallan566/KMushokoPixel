"""Coherent pixel-art bestiary. Rendered at native size; no fractional scale."""
from pathlib import Path
from PIL import Image, ImageDraw
import math
ROOT=Path(__file__).resolve().parents[1]
CHARCOAL='#151E2C'
SHADOW='#304457'

def poly(d, p, fill, outline=CHARCOAL, width=2):
    d.polygon(p,fill=fill)
    d.line(p+[p[0]],fill=outline,width=width,joint='curve')

def sprite(name, phase=0):
    big=name=='alpha_wolf'; w,h=(96,80) if big else (48,48) if name=='slime' else (48,56) if name=='mushroom' else (64,56)
    im=Image.new('RGBA',(w,h));d=ImageDraw.Draw(im);b=(0,1,2,1)[phase]
    if name=='slime':
        # blue/green glassy body with inset glints and charming eyes.
        poly(d,[(9,36-b),(6,29-b),(10,18-b),(16,12-b),(29,11-b),(38,16-b),(42,29-b),(38,38-b),(16,39-b)],'#257D73')
        poly(d,[(11,32-b),(12,21-b),(18,15-b),(29,15-b),(36,20-b),(39,32-b),(34,36-b),(16,36-b)],'#63C9A2',outline='#318E80',width=1)
        d.polygon([(12,24-b),(16,17-b),(24,15-b),(19,20-b),(17,28-b)],fill='#BBFDE0')
        for x in (20,31):
            d.rectangle((x,27-b,x+2,32-b),fill='#173F4B')
        d.point((26,34-b),fill='#2D5157')
        d.line([(14,39),(17,40),(34,40),(38,38)],fill='#1C675D',width=2)
    elif name=='mushroom':
        poly(d,[(21,27-b),(29,27-b),(35,45-b),(33,50-b),(16,50-b),(14,45-b)],'#DDC9AD')
        d.rectangle((18,35-b,30,45-b),fill='#FAE7C5')
        poly(d,[(4,26-b),(7,15-b),(14,10-b),(33,10-b),(41,18-b),(45,26-b),(40,32-b),(8,32-b)],'#AE4C64')
        poly(d,[(8,24-b),(14,13-b),(32,13-b),(41,23-b),(40,28-b),(9,28-b)],'#DC6B6E',outline='#D55A5A',width=1)
        for x,y in [(16,20),(30,17),(37,24)]:d.ellipse((x-3,y-3-b,x+3,y+1-b),fill='#FFEBCF')
        for x in (20,29):d.rectangle((x,38-b,x+1,43-b),fill=CHARCOAL)
        d.line((23,46-b,27,46-b),fill='#A96369')
    elif name in ('boar','elite_boar'):
        elite=name=='elite_boar';body='#754A3A' if elite else '#846454';light='#B57B5B' if elite else '#B4987D'
        tail=[(51,26),(56,18),(61,23),(58,29)]
        poly(d,tail,body)
        for x,y in [(16,42),(39,40),(48,40)]:
            poly(d,[(x-3,y-2),(x+5,y),(x+3,50),(x-3,50)],'#52372D')
        poly(d,[(10,24-b),(19,16-b),(43,15-b),(53,21-b),(55,34-b),(45,41-b),(14,42-b),(5,35-b)],body)
        poly(d,[(11,27-b),(18,19-b),(40,17-b),(48,25-b),(35,28-b)],light,outline=body,width=1)
        for x,y in [(29,16),(36,13),(43,16),(48,20)]:d.polygon([(x-4,y-b),(x,y-7-b),(x+3,y+1-b)],fill='#4A2C28' if elite else '#735344')
        poly(d,[(4,29-b),(10,24-b),(17,27-b),(17,36-b),(10,38-b),(3,35-b)],'#C79675')
        d.rectangle((9,30-b,11,33-b),fill=CHARCOAL)
        d.polygon([(15,36-b),(21,32-b),(20,40-b)],fill='#FBE8BC')
        d.ellipse((22,24-b,27,29-b),fill=CHARCOAL)
        d.point((25,25-b),fill='#FDE5CB')
        if elite:
            poly(d,[(17,19-b),(20,7-b),(29,17-b)],'#C35143')
            poly(d,[(36,18-b),(45,5-b),(51,22-b)],'#A93F37')
            d.line((19,24-b,35,20-b),fill='#E6AF67',width=2)
    else:
        wolf=name=='wolf'; fur='#66727D' if wolf else '#E2DDD5'; dark='#34404A' if wolf else '#59677A';light='#B1BFC2' if wolf else '#FEF5DF'
        s=1.40 if big else 1.0
        xoffset=5 if big else 0;yoffset=6 if big else 0
        def spts(points): return [(int(x*s+xoffset),int(y*s+yoffset-b)) for x,y in points]
        def sp(points,fill,outline=CHARCOAL,width=2):poly(d,spts(points),fill,outline,width)
        sp([(44,26),(55,17),(61,20),(61,23),(54,30)],dark)
        for x in (22,36,48):
            sp([(x-5,35),(x+3,36),(x+2,50),(x-3,50)],dark)
        sp([(10,22),(22,15),(40,18),(51,22),(53,35),(42,41),(20,40),(11,33)],fur)
        sp([(15,20),(23,16),(38,20),(45,27),(34,29),(14,27)],light,outline=fur,width=1)
        sp([(10,16),(12,6),(21,14),(28,7),(31,19)],dark)
        sp([(11,18),(5,23),(0,28),(7,32),(15,32),(20,27)],fur)
        sp([(4,25),(1,28),(11,30),(14,25)],light,outline=fur,width=1)
        eye=(16,22);e=spts([eye])[0]
        d.rectangle((e[0],e[1],e[0]+(2 if big else 1),e[1]+(2 if big else 1)),fill='#F6B95C' if wolf else '#ED5B69')
        for x,y in [(18,14),(26,13),(31,19),(39,24)]:
            p=spts([(x,y),(x+5,y+5),(x,y+7)])
            d.polygon(p,fill=light)
        nose=spts([(1,27)])[0];d.rectangle((nose[0],nose[1],nose[0]+2,nose[1]+2),fill=CHARCOAL)
        if big:
            sp([(17,10),(20,4),(24,12)],'#D1D3E7')
            sp([(36,13),(40,4),(45,18)],'#D1D3E7')
            d.line(spts([(8,30),(17,33),(27,30)]),fill='#A6C9DF',width=2)
    return im

def main():
    out=ROOT/'assets/enemies';out.mkdir(parents=True,exist_ok=True)
    for name in ('slime','boar','wolf','mushroom','elite_boar','alpha_wolf'):
        images=[sprite(name,i) for i in range(4)]
        w,h=images[0].size;sheet=Image.new('RGBA',(w*4,h))
        for i,im in enumerate(images):sheet.alpha_composite(im,(i*w,0))
        sheet.save(out/f'{name}_sheet.png',optimize=True)
        print(name,sheet.size)
if __name__=='__main__':main()
