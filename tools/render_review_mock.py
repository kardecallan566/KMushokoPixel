"""Illustration from real PNG assets. NOT an in-game Godot screenshot."""
from PIL import Image,ImageDraw,ImageFont
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
W,H=384,216;GY=166;BASELINE=177
im=Image.new('RGBA',(W,H),'#1F92FD');d=ImageDraw.Draw(im)
base=ROOT/'assets/biomes/green_plains'
for n,y in [('clouds',16),('mountains',GY-72),('treeline',GY-42)]:
 a=Image.open(base/f'{n}.png').convert('RGBA');im.alpha_composite(a,(0,y))
d.rectangle((0,GY-8,W,H),fill='#89C347')
for n,y in [('meadow',GY-8),('details',GY-24)]:
 a=Image.open(base/f'{n}.png').convert('RGBA');im.alpha_composite(a,(0,y))
for i,name in enumerate(['rudeus','sylphie','roxy','eris']):
 a=Image.open(ROOT/f'assets/characters/{name}_sheet.png').convert('RGBA')
 frame=a.crop((72*(4+i%4),0,72*(5+i%4),100))
 # same left-facing direction in exploration
 cx=int(W*(.10+.15*i))
 im.alpha_composite(frame,(cx-36,BASELINE-94))
for i,n in enumerate(['slime','boar']):
 a=Image.open(ROOT/f'assets/enemies/{n}_sheet.png');fr=a.crop((0,0,a.width//4,a.height))
 im.alpha_composite(fr,(300+i*43-fr.width//2,BASELINE-fr.height+4))
fg=Image.open(base/'foreground.png').convert('RGBA');im.alpha_composite(fg,(0,GY+12))
d=ImageDraw.Draw(im)
d.rectangle((0,0,W,19),fill='#102A3C');d.line((0,18,W,18),fill='#598C8B')
d.text((6,4),'PLANICIES VERDES',fill='#F3ECD2');d.text((156,4),'FASE 03/10',fill='#B9E7D9');d.text((266,4),'230 G',fill='#F8D591');d.text((319,4),'NV 2',fill='#C5DAE9')
d.rectangle((0,203,W,216),fill='#102838')
colors=['#79C6EB','#81DEA0','#B3A5F5','#EAB5A6']
for i,n in enumerate(['rudeus','sylphie','roxy','eris']):
 x=4+i*93;y=178;d.rectangle((x,y,x+89,202),fill='#122C3D',outline=colors[i])
 source=Image.open(ROOT/f'assets/characters/{n}_sheet.png').convert('RGBA').crop((22,21,39,39))
 im.alpha_composite(source,(x+2,y+2))
 d.text((x+23,y+3),n.upper(),fill='#F3ECD2');d.rectangle((x+23,y+13,x+78,y+16),fill='#72DFAC');d.text((x+23,y+17),'LV 2',fill='#9DB7C4')
d.text((5,206),'[U] EVOLUIR 85',fill='#B8E2C6');d.text((112,206),'[F] FARM OFF',fill='#C9E0ED')
res=im.resize((1152,648),Image.Resampling.NEAREST).convert('RGB');res.save(ROOT/'PREVIEW_SCENE_CP03C.png',optimize=True)
print('PREVIEW_SCENE_CP03C.png (illustrative, NOT Godot screenshot)')
