"""Design review composition only; NOT a screenshot of the Godot runtime.
Matches logical sprite coordinates, integer scaling, anchor and window bars.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[1]
BG=ROOT/'assets'/'biomes'/'green_plains'
HERO=ROOT/'assets'/'characters'
ENEMY=ROOT/'assets'/'enemies'
FX=ROOT/'assets'/'effects'
FONT=ImageFont.load_default()

def blit(dst,src,x,y):
    if src.mode != 'RGBA':src=src.convert('RGBA')
    dst.alpha_composite(src,(int(x),int(y)))

def tile(canvas,name,y,crop_w,scroll=0):
    tex=Image.open(BG/f'{name}.png').convert('RGBA')
    w=tex.width
    x=-(scroll%w)
    while x<crop_w:
        blit(canvas,tex,x,y)
        x+=w

def sprite(p,frame=0):
    im=Image.open(p).convert('RGBA')
    w=48 if 'characters' in str(p) else im.width//4
    return im.crop((frame*w,0,(frame+1)*w,im.height))

def scene(compact=False):
    W,H=(480,120) if compact else (384,216)
    baseline=H-(26 if compact else 65)
    im=Image.new('RGBA',(W,H),'#1F92FD')
    tile(im,'clouds',baseline-10-150,W,scroll=25)
    tile(im,'mountains',baseline-10-72,W,scroll=12)
    tile(im,'treeline',baseline-10-42,W,scroll=42)
    dr=ImageDraw.Draw(im)
    dr.rectangle((0,baseline-18,W,H),fill='#89C347')
    tile(im,'meadow',baseline-18,W,scroll=90)
    phase='combat'
    pp=[.10,.25,.40,.55]
    for i,hero in enumerate(('rudeus','sylphie','roxy','eris')):
        img=sprite(HERO/f'{hero}_sheet.png', 4+(i%6))
        x=round(W*pp[i])
        dr=ImageDraw.Draw(im)
        dr.rectangle((x-14,baseline-1,x+14,baseline+1),fill='#4D8956')
        blit(im,img,x-24,baseline-54)
        if hero=='rudeus':
            e=Image.open(FX/f'{hero}_cast.png').convert('RGBA').crop((64,0,96,32))
            blit(im,e,x+6,baseline-46)
    for i,mob in enumerate(('wolf','mushroom','slime')):
        img=sprite(ENEMY/f'{mob}_sheet.png',1)
        x=round(W*(.75+.10*i))
        blit(im,img,x-img.width//2,baseline-img.height+4)
        dr=ImageDraw.Draw(im)
        ww=int(img.width*.68)
        y=baseline-img.height-5
        dr.rectangle((x-ww//2,y,x+ww//2,y+3),fill='#122B39')
        dr.rectangle((x-ww//2+1,y+1,x+5,y+2),fill='#E66A72')
    tile(im,'foreground',baseline+2,W,scroll=100)
    d=ImageDraw.Draw(im)
    hh=14 if compact else 25
    d.rectangle((0,0,W,hh-1),fill='#162934')
    d.line((0,hh-1,W,hh-1),fill='#61998A')
    text='PLANICIES 04/10  $72  LV2' if compact else 'KMUSHOKOPIXEL  |  PLANICIES 04/10'
    d.text((6,2 if compact else 7),text,font=FONT,fill='#F8F5DE')
    d.text((W-52,2 if compact else 7),'||  []',font=FONT,fill='#E9EEE7')
    if not compact:
        d.rectangle((5,27,163,43),fill='#17333E')
        d.text((10,30),'OURO 72  NIV 2  VIT 3',font=FONT,fill='#FFE6A1')
        d.text((8,46),'COMBATE | INIMIGOS 3',font=FONT,fill='#FFF3CF')
        d.rectangle((8,57,140,60),fill='#263D45')
        d.rectangle((8,57,99,60),fill='#E27A68')
        yy=H-37
        for i,name in enumerate(('RUDEUS','SYLPHIE','ROXY','ERIS')):
            x=7+i*W//4
            d.rectangle((x-3,yy-13,x+W//4-9,yy+11),fill='#17343B')
            d.text((x,yy-10),name,font=FONT,fill='#FFF3DD')
            d.rectangle((x,yy+1,x+W//4-14,yy+4),fill='#224736')
            d.rectangle((x,yy+1,x+W//4-23,yy+4),fill='#73D987')
        d.rectangle((0,H-22,W,H),fill='#122B35')
        d.rectangle((4,H-17,90,H-3),fill='#376656')
        d.rectangle((94,H-17,170,H-3),fill='#415F6B')
        d.text((8,H-15),'[U] UP 80',font=FONT,fill='white')
        d.text((99,H-15),'[F] FARM',font=FONT,fill='white')
        d.text((W-115,H-14),'TAB | SALVAR',font=FONT,fill='#C9DBE5')
    else:
        d.rectangle((0,H-18,W,H),fill='#172F38')
        d.rectangle((4,H-17,90,H-3),fill='#376656')
        d.rectangle((94,H-17,170,H-3),fill='#415F6B')
        d.text((9,H-15),'UP 80',font=FONT,fill='white')
        d.text((101,H-15),'FARM OFF',font=FONT,fill='white')
        for i in range(4):
            x=180+i*40
            d.rectangle((x,H-11,x+35,H-8),fill='#224736')
            d.rectangle((x,H-11,x+25+i*2,H-8),fill='#73D987')
        d.text((W-96,H-15),'TAB EXPANDIR',font=FONT,fill='#D5E8EB')
    factor=2 if compact else 3
    return im.convert('RGB').resize((W*factor,H*factor),Image.Resampling.NEAREST)

expanded=scene(False); compact=scene(True)
root=Image.new('RGB',(1152,1050),'#111D29')
root.paste(expanded,(0,45))
root.paste(compact,(96,757))
d=ImageDraw.Draw(root)
d.text((14,16),'CP02B  |  MODO EXPANDIDO - 384x216 @ 3x',font=FONT,fill='white')
d.text((98,731),'MODO COMPACTO - 480x120 @ 2x',font=FONT,fill='white')
out=ROOT/'PREVIEW_CP02B_VISUAL.png'
root.save(out)
print('Visual concept render (NOT Godot screenshot):',out)
