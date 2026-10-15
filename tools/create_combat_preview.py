"""Documentation-only layout concept composed from sprites. Not an in-engine capture."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[1]
BG=ROOT/'assets/biomes/green_plains'
HERO=ROOT/'assets/characters'
ENEMY=ROOT/'assets/enemies'
W,H=576,270
font=ImageFont.load_default()

def make(frame):
    canvas=Image.new('RGBA',(W,H),'#1F92FD')
    for n,y in [('clouds',0),('mountains',72),('treeline',100),('meadow',135)]:
        layer=Image.open(BG/(n+'.png')).convert('RGBA').crop((frame*4,0,frame*4+W,{'clouds':118,'mountains':76,'treeline':64,'meadow':144}[n]))
        canvas.alpha_composite(layer,(0,y))
    ground=185
    d=ImageDraw.Draw(canvas)
    for i,name in enumerate(['rudeus','sylphie','roxy','eris']):
        source=Image.open(HERO/(name+'_sheet.png')).convert('RGBA')
        j=4+(frame+i)%6
        actor=source.crop((j*48,0,(j+1)*48,60)).resize((65,81),Image.Resampling.NEAREST)
        x=45+i*79
        d.ellipse((x-15,ground-1,x+19,ground+3),fill='#357A56')
        canvas.alpha_composite(actor,(x-30,ground-74))
    for i,name in enumerate(['wolf','mushroom','slime']):
        w,h={'wolf':(64,56),'mushroom':(48,56),'slime':(48,48)}[name]
        im=Image.open(ENEMY/(name+'_sheet.png')).convert('RGBA').crop((((frame+i)%4)*w,0,((frame+i)%4+1)*w,h))
        sc=1.28
        im=im.resize((round(w*sc),round(h*sc)),Image.Resampling.NEAREST)
        x=358+i*73
        canvas.alpha_composite(im,(x-im.width//2,ground-im.height+4))
        d.rectangle((x-21,ground-im.height-4,x+22,ground-im.height-1),fill='#25313B')
        d.rectangle((x-20,ground-im.height-3,x+13-(frame%4)*2,ground-im.height-2),fill='#E96D77')
    layer=Image.open(BG/'foreground.png').convert('RGBA').crop((0,0,W,80))
    canvas.alpha_composite(layer,(0,192))
    d=ImageDraw.Draw(canvas)
    d.rectangle((0,0,W-1,26),fill='#142B37')
    d.text((8,8),'KMUSHOKOPIXEL  |  PLANICIES VERDES  |  FASE 04/10',font=font,fill='#F8F5DE')
    d.text((467,8),'[ II ]  [ <> ]',font=font,fill='#D5EDF0')
    d.rectangle((6,30,164,50),fill='#1A3742')
    d.text((10,37),'OURO 72   NIV 2  VIT 3',font=font,fill='#FFE2A1')
    d.rectangle((196,53,365,72),fill='#202D38')
    d.text((201,59),'RUDEUS: CANHAO DE PEDRA!',font=font,fill='#F2D8A5')
    for i,name in enumerate(['RUDEUS','SYLPHIE','ROXY','ERIS']):
        x=8+i*142
        d.rectangle((x,213,x+131,241),fill='#18333A')
        d.text((x+5,217),name,font=font,fill='#FCEFD7')
        d.rectangle((x+5,231,x+124,235),fill='#31404B')
        d.rectangle((x+5,231,x+int((111-i*6)),235),fill='#65DA83')
    d.rectangle((0,245,W-1,269),fill='#162C37')
    d.rectangle((8,249,140,264),fill='#346558')
    d.rectangle((146,249,256,264),fill='#3B5568')
    d.text((14,253),'[U] MELHORAR 80',font=font,fill='#F4FCE3')
    d.text((153,253),'[F] FARM OFF',font=font,fill='#DFF5F8')
    d.text((401,253),'TAB JANELA | S SALVAR',font=font,fill='#C2DFE7')
    return canvas.resize((1152,540),Image.Resampling.NEAREST).convert('RGB')

make(0).save(ROOT/'PREVIEW_CP02_COMBAT.png')
frames=[make(i) for i in range(6)]
frames[0].save(ROOT/'PREVIEW_CP02_COMBAT.gif',save_all=True,append_images=frames[1:],duration=145,loop=0,optimize=True)
print('Combat layout reference composed from original project sprites')