"""Generate original, deliberately hand-composed pixel sprites and parallax art.
No extracted/reused frames or copyrighted sprites are bundled. Pillow needed only
when regenerating assets; exported PNGs are included in the Godot project.
"""
from PIL import Image, ImageDraw
from pathlib import Path
import random, math

ROOT = Path(__file__).resolve().parents[1]
CHAR_DIR=ROOT/'assets'/'characters'
BG_DIR=ROOT/'assets'/'biomes'/'green_plains'
CHAR_DIR.mkdir(parents=True,exist_ok=True)
BG_DIR.mkdir(parents=True,exist_ok=True)
C={
 'ink':'#140F20','ink2':'#282033','shadow':'#473A47','skin':'#F9CFA7','skin_hi':'#FFE4BD','skin_sh':'#CD916B',
 'r_hair':'#CC6728','r_light':'#F8A83E','r_sh':'#883F28','r_robe':'#868498','r_dark':'#434152','r_lightrobe':'#CDD0C9',
 's_hair':'#EAE9D8','s_light':'#FFFAE6','s_sh':'#AFAAB4','s_cape':'#332C40','s_red':'#9C414A','s_green':'#7D916D',
 'x_hair':'#1A60DA','x_light':'#4D93F5','x_sh':'#123A8F','x_hat':'#2B223F','x_band':'#E9DCD7','x_robe':'#F7F4E8',
 'e_hair':'#C52D26','e_light':'#F75137','e_shadow':'#8D202C','e_armor':'#44302F','e_armor_hi':'#96766F',
 'boots':'#96512B','boot_sh':'#5B2E2E','boots_hi':'#D47839', 'metal':'#EAF0EB','steel':'#95B8C1'
}

def poly(d,points,fill,outline='ink',width=1):
    d.polygon(points,fill=C.get(fill,fill))
    if outline:
        d.line(points+[points[0]],fill=C.get(outline,outline),width=width,joint='curve')

def rect(d, box, color):
    d.rectangle(box,fill=C.get(color,color))

def line(d,points,color,width=1):
    d.line(points,fill=C.get(color,color),width=width,joint='curve')

def leg(d,x,y,boot,delta,far=False):
    dy=int(abs(delta)*0.28)
    poly(d,[(x,y-16),(x+5,y-17),(x+6+delta,y-8+dy),(x+4+delta,y-2+dy),(x-1+delta,y-4+dy)],'ink',None)
    poly(d,[(x+1,y-15),(x+4,y-15),(x+4+delta,y-6),(x+delta,y-6)],'#EEEAD7' if boot=='white' else '#55404A',None)
    poly(d,[(x+delta-1,y-6),(x+delta+5,y-6),(x+delta+6,y-2),(x+delta+2,y+0),(x+delta-4,y+0)],'ink',None)
    poly(d,[(x+delta,y-5),(x+delta+4,y-5),(x+delta+4,y-2),(x+delta-2,y-1)], '#ECEDE7' if boot=='white' else 'boots',None)
    if boot != 'white': rect(d,(x+delta,y-4,x+delta+3,y-4),'boots_hi')

def face(d, x, y, cheek=False):
    poly(d,[(x+1,y+2),(x+11,y+2),(x+12,y+11),(x+10,y+16),(x+2,y+16),(x-1,y+12),(x,y+6)],'skin')
    rect(d,(x+1,y+5,x+3,y+10),'skin_hi')
    rect(d,(x+1,y+8,x+2,y+10),'ink')
    rect(d,(x+3,y+12,x+5,y+12),'skin_sh')
    if cheek: rect(d,(x+5,y+11,x+6,y+12),'#F1A59A')

def generate_hero(name, anim, step):
    im=Image.new('RGBA',(48,60),(0,0,0,0)); d=ImageDraw.Draw(im)
    walk=anim=='walk'; p=step if walk else 0
    legs=[0,-2,-3,0,2,3]
    stride=legs[p] if walk else 0
    bob=(1 if (walk and p in (1,4)) or (not walk and step == 2) else 0)
    sway=(1 if (walk and p in (1,2)) or (not walk and step == 1) else -1 if (walk and p in (4,5)) or (not walk and step == 3) else 0)
    y= -bob
    # shadow on same texture intentionally absent; Godot draws ground contact
    # Far cape, back hair, sword and rear leg first
    if name=='rudeus':
        # robe flutter and shoulder silhouette
        poly(d,[(23,24+y),(31,26+y),(35+sway,46+y),(40+sway,49+y),(32,51+y),(19,46+y)],'r_dark')
        rect(d,(30,34+y,36+sway,43+y),'r_robe')
        leg(d,25,54+y,'brown',stride,True)
        leg(d,15,54+y,'brown',-stride,False)
        # body and long hem
        poly(d,[(15,27+y),(28,26+y),(32,40+y),(34+sway,48+y),(21,51+y),(9,47+y),(12,33+y)],'r_robe')
        poly(d,[(11,44+y),(21,47+y),(28,45+y),(34,48+y),(20,51+y),(10,48+y)],'r_lightrobe',None)
        line(d,[(20,29+y),(19,46+y)],'r_lightrobe',2)
        poly(d,[(16,28+y),(28,26+y),(31,31+y),(27,35+y),(13,33+y)],'r_dark')
        # arm far
        poly(d,[(23,30+y),(29,31+y),(31,41+y),(27,44+y),(24,37+y)],'r_robe')
        rect(d,(25,39+y,28,42+y),'skin')
        # staff long dark diagonally to left
        line(d,[(9,35+y),(13,50+y)],'ink',4)
        line(d,[(9,35+y),(13,50+y)],'#8F5432',2)
        poly(d,[(6,30+y),(9,27+y),(13,29+y),(15,34+y),(12,39+y),(7,39+y),(4,35+y)],'ink',None)
        poly(d,[(7,31+y),(11,30+y),(13,34+y),(10,37+y),(6,35+y)],'#0753C9',None)
        rect(d,(8,31+y,10,33+y),'#9EDDFD')
        # holding arm
        poly(d,[(13,31+y),(10,33+y),(12,40+y),(16,43+y),(20,39+y),(18,34+y)],'r_robe')
        rect(d,(12,39+y,15,42+y),'skin')
        face(d,12,16+y)
        # copper hair: jagged, big and voluminous
        poly(d,[(9,25+y),(6,22+y),(7,15+y),(4,14+y),(9,10+y),(14,10+y),(14,7+y),(19,9+y),(24,7+y),(29,10+y),(31,15+y),(36,16+y),(33,22+y),(29,25+y),(25,22+y),(22,25+y),(17,22+y),(12,28+y)],'r_hair')
        poly(d,[(7,17+y),(12,12+y),(18,13+y),(22,9+y),(27,12+y),(27,16+y),(31,17+y),(27,20+y),(23,17+y),(19,19+y),(15,15+y),(11,21+y)],'r_light',None)
        rect(d,(7,21+y,10,24+y),'r_sh');rect(d,(26,21+y,30,25+y),'r_sh')
        for tx,ty in [(11,13),(18,10),(24,13),(16,18)]:rect(d,(tx,ty+y,tx+2,ty+y),'#FFC073')
    elif name=='sylphie':
        # swinging black cape with burgundy inner side
        poly(d,[(25,27+y),(31,26+y),(35+sway,40+y),(41+sway,48+y),(37,49+y),(31,47+y),(30,52+y),(24,48+y)],'s_cape')
        poly(d,[(30,35+y),(33,42+y),(39+sway,47+y),(35,47+y),(31,44+y)],'s_red',None)
        leg(d,26,54+y,'brown',stride,True);leg(d,16,54+y,'brown',-stride,False)
        poly(d,[(16,29+y),(28,28+y),(31,41+y),(28,49+y),(13,49+y),(12,40+y)],'s_green')
        rect(d,(16,35+y,28,38+y),'#CDD0AF')
        rect(d,(21,36+y,22,45+y),'#5B574A')
        poly(d,[(14,30+y),(11,34+y),(13,41+y),(17,43+y),(19,39+y),(17,34+y)],'s_cape')
        rect(d,(13,39+y,16,42+y),'skin')
        face(d,12,17+y,True)
        # silver/white fringe and short side locks
        poly(d,[(9,24+y),(8,14+y),(12,11+y),(16,9+y),(19,6+y),(23,10+y),(28,10+y),(31,16+y),(31,24+y),(34,29+y),(28,28+y),(26,25+y),(20,26+y),(16,24+y),(11,28+y)],'s_hair')
        poly(d,[(11,14+y),(17,10+y),(20,10+y),(22,13+y),(25,11+y),(29,15+y),(27,19+y),(20,17+y),(17,19+y),(11,18+y)],'s_light',None)
        rect(d,(28,20+y,31,25+y),'s_sh')
        rect(d,(9,20+y,10,23+y),'s_sh')
        rect(d,(22,11+y,26,12+y),'#CECED0')
    elif name=='roxy':
        # trailing cobalt hair flowing on the right
        poly(d,[(23,20+y),(31,21+y),(34,31+y),(40+sway,37+y),(40+sway,44+y),(45+sway,47+y),(43+sway,50+y),(38+sway,48+y),(32,43+y),(26,36+y)],'x_hair')
        poly(d,[(29,22+y),(34,29+y),(37+sway,36+y),(42+sway,45+y),(40,45+y),(34,39+y)],'x_light',None)
        rect(d,(38+sway,43+y,40+sway,47+y),'x_sh')
        leg(d,25,54+y,'white',stride,True);leg(d,15,54+y,'white',-stride,False)
        poly(d,[(14,30+y),(28,29+y),(31,42+y),(32,48+y),(17,50+y),(10,47+y),(14,39+y)],'x_robe')
        poly(d,[(12,39+y),(30,40+y),(31,44+y),(12,44+y)],'x_hat',None)
        rect(d,(15,37+y,29,38+y),'#8C6B66')
        # hand & dark sleeve
        poly(d,[(15,30+y),(11,33+y),(11,40+y),(14,43+y),(18,41+y),(18,35+y)],'x_hat')
        rect(d,(11,39+y,14,42+y),'skin')
        face(d,12,17+y,True)
        rect(d,(12,22+y,14,30+y),'x_hair')
        # witch hat dramatically extending left
        poly(d,[(3,20+y),(10,17+y),(20,8+y),(28,5+y),(27,10+y),(35,14+y),(39,20+y),(32,21+y),(29,24+y),(16,23+y)],'x_hat')
        poly(d,[(6,20+y),(19,18+y),(24,17+y),(32,19+y),(29,21+y),(14,22+y)],'x_band',None)
        poly(d,[(21,12+y),(28,7+y),(29,14+y),(34,17+y),(23,16+y)],'#4B385C',None)
        rect(d,(9,19+y,11,20+y),'#EEEEEB')
        # tiny blue bodice/neck
        rect(d,(18,28+y,26,31+y),'x_hair')
        rect(d,(19,33+y,23,34+y),'x_light')
    elif name=='eris':
        # sword behind right, trailing to right hand, bright readable blade
        poly(d,[(29,39+y),(40,35+y),(43,36+y),(38,42+y),(33,45+y)],'metal')
        line(d,[(28,44+y),(35,43+y)],'ink',3);rect(d,(28,43+y,29,45+y),'#AD8C58')
        # huge red hair streaming backwards to right
        poly(d,[(17,12+y),(28,10+y),(33,14+y),(39,20+y),(38,26+y),(44+sway,31+y),(39+sway,32+y),(44+sway,39+y),(38+sway,38+y),(35,42+y),(28,39+y),(25,29+y)],'e_hair')
        poly(d,[(28,15+y),(36,22+y),(37,30+y),(42+sway,35+y),(35,34+y),(30,29+y)],'e_light',None)
        poly(d,[(28,30+y),(37,36+y),(34,39+y),(29,36+y)],'e_shadow',None)
        leg(d,25,54+y,'brown',stride,True);leg(d,14,54+y,'brown',-stride,False)
        poly(d,[(15,29+y),(27,28+y),(31,38+y),(30,48+y),(14,48+y),(12,37+y)],'e_armor')
        rect(d,(16,31+y,22,33+y),'e_armor_hi')
        rect(d,(18,34+y,21,44+y),'#31232F')
        poly(d,[(14,31+y),(11,35+y),(14,43+y),(18,43+y),(20,38+y),(18,33+y)],'e_armor')
        rect(d,(14,40+y,17,43+y),'skin')
        face(d,12,17+y,True)
        # front locks/head hair
        poly(d,[(8,23+y),(9,16+y),(13,14+y),(16,7+y),(19,10+y),(24,9+y),(30,13+y),(31,20+y),(27,25+y),(23,19+y),(19,24+y),(16,19+y),(12,27+y)],'e_hair')
        poly(d,[(12,16+y),(17,10+y),(18,15+y),(22,12+y),(27,16+y),(29,19+y),(24,18+y),(21,21+y),(17,17+y),(13,21+y)],'e_light',None)
        rect(d,(9,23+y,11,27+y),'e_shadow')
    # Pixel-level costume polish, consistent between idle and walk frames.
    # These accents are actual authored pixel clusters, not a post-scale filter.
    if name == 'rudeus':
        rect(d,(19,36+y,21,38+y),'#E3C99F')
        rect(d,(21,40+y,23,42+y),'#565064')
        rect(d,(16,46+y,19,46+y),'#EEE5D5')
        rect(d,(8,30+y,9,31+y),'#DCF9FC')
        rect(d,(8,34+y,10,34+y),'#2F9BF4')
    elif name == 'sylphie':
        rect(d,(18,31+y,20,33+y),'#D6E8C2')
        rect(d,(19,39+y,21,39+y),'#4A6B60')
        rect(d,(30,42+y,33,43+y),'#6B3948')
        rect(d,(13,13+y,14,14+y),'#FFFFFF')
    elif name == 'roxy':
        rect(d,(21,20+y,24,20+y),'#ACB4DF')
        rect(d,(25,17+y,27,18+y),'#F5E6C8')
        rect(d,(22,35+y,24,36+y),'#A8B8DC')
        rect(d,(36+sway,38+y,37+sway,40+y),'#85AEF9')
    elif name == 'eris':
        rect(d,(20,35+y,24,36+y),'#C39878')
        rect(d,(21,42+y,23,43+y),'#986E66')
        rect(d,(39,36+y,40,36+y),'#FFFFFF')
        rect(d,(20,12+y,22,13+y),'#FF8C63')
    return im

FRAME_W,FRAME_H=48,60
for person in ('rudeus','sylphie','roxy','eris'):
    sheet=Image.new('RGBA',(FRAME_W*10,FRAME_H),(0,0,0,0))
    for i in range(4):sheet.paste(generate_hero(person,'idle',i),(i*48,0))
    for i in range(6):sheet.paste(generate_hero(person,'walk',i),((i+4)*48,0))
    sheet.save(CHAR_DIR/f'{person}_sheet.png',optimize=True)

R=random.Random(91207)
W=960
# clouds layer repeat tile
im=Image.new('RGBA',(W,118));d=ImageDraw.Draw(im)
for x,y,w in [(24,47,71),(196,18,86),(360,72,51),(502,39,79),(704,9,73),(844,79,62)]:
    # irregular stair stepped, no gradient
    for k in range(w//7):
        t=k/(w//7); height=max(3,int((math.sin(math.pi*t)**2)*18+R.randint(-2,3)))
        xx=x+k*7
        rect(d,(xx,y-height,xx+8,y-2),'#F6FAF9')
        if k%3==0:rect(d,(xx+3,y-5,xx+9,y-1),'#C5E4F6')
    rect(d,(x,y-3,x+w,y-1),'#E7F5FE')
im.save(BG_DIR/'clouds.png',optimize=True)

im=Image.new('RGBA',(W,76));d=ImageDraw.Draw(im)
for layer,shade,step,jitter,offset in [(0,'#2781AC',47,12,13),(1,'#146C9A',36,9,31),(2,'#175878',29,10,19)]:
    r=random.Random(351+layer)
    pts=[(-10,76)]
    for x in range(-20,W+40,step):pts.append((x,31+layer*11+int(9*math.sin(x/63.0+layer))+r.randint(-jitter,jitter)))
    pts.extend([(W+20,76),(-10,76)])
    poly(d,pts,shade,None)
im.save(BG_DIR/'mountains.png',optimize=True)

im=Image.new('RGBA',(W,64));d=ImageDraw.Draw(im)
for x in range(-5,W,12):
    rr=random.Random(x*2+2024)
    height=rr.randint(17,44)
    shade=rr.choice(['#064D5F','#075A63','#0A6670','#15596A'])
    top=64-height
    poly(d,[(x+6,top),(x-1,top+14),(x+2,top+14),(x-5,top+29),(x+3,top+26),(x+1,64),(x+13,64),(x+10,top+26),(x+18,top+29),(x+12,top+14)],shade,None)
    if x%3==0:rect(d,(x+6,top+13,x+7,top+18),'#1B8279')
im.save(BG_DIR/'treeline.png',optimize=True)

im=Image.new('RGBA',(W,144),'#89C347');d=ImageDraw.Draw(im)
rr=random.Random(461)
rect(d,(0,0,W,15),'#8BCA47');rect(d,(0,16,W,32),'#80BD3F')
for _ in range(6100):
    x=rr.randrange(W);y=rr.randrange(144)
    col=rr.choices(['#A1D34E','#68AC41','#6FB641','#73BA3C','#C0D85B','#2B9B5F'],[2,3,3,2,1,0.8])[0]
    wid=rr.choice([1,2,3,5,7])
    rect(d,(x,y,x+wid,y+rr.choice([0,1,1,2])),col)
for _ in range(210):
    x=rr.randrange(W);y=rr.randrange(20,144)
    if rr.random()<0.7:
        col='#135D56';
        for dx,dy in [(-3,-3),(-2,-5),(0,-3),(2,-7),(3,-3),(5,-5)]:line(d,[(x,y),(x+dx,y+dy)],col,2)
    else:
        for dx,dy in [(0,-3),(-3,0),(3,0),(0,3)]:rect(d,(x+dx,y+dy,x+dx+2,y+dy+2),'#FDFCF0')
        rect(d,(x,y,x+2,y+2),'#E3B637')
im.save(BG_DIR/'meadow.png',optimize=True)

im=Image.new('RGBA',(W,80),(0,0,0,0));d=ImageDraw.Draw(im);r=random.Random(716)
for x in range(-10,W,78):
    x=x+r.randint(-8,11)
    y=r.randint(38,57)
    if r.random()<0.30:
        poly(d,[(x,y+13),(x+8,y+2),(x+24,y),(x+38,y+11),(x+40,y+17),(x+3,y+17)],'#514F73',None)
        poly(d,[(x+6,y+12),(x+10,y+3),(x+24,y+2),(x+28,y+7)],'#9595AC',None)
        rect(d,(x+25,y+7,x+35,y+12),'#797991')
    else:
        cx=x+20
        for k in range(15):
            ex=cx+r.randint(-25,26);ey=y-r.randint(9,30)
            line(d,[(cx+r.randint(-4,4),y+16),(ex,ey)],r.choice(['#064C53','#0C6860','#1C7760','#0D5F51']),r.randint(2,3))
        for k in range(3):
            bx=x+r.randint(0,34); by=y+r.randint(-14,0)
            rect(d,(bx,by,bx+r.randint(2,6),by+r.randint(1,3)),'#2E8C59')
im.save(BG_DIR/'foreground.png',optimize=True)

# Small visual inspection sheet, not part of runtime pipeline.
from PIL import ImageFont
scene=Image.new('RGB',(480,240),'#1F92FD')
scene.paste(Image.open(BG_DIR/'clouds.png').crop((0,0,480,118)),(0,4),Image.open(BG_DIR/'clouds.png').crop((0,0,480,118)))
for file,y in [('mountains',82),('treeline',102),('meadow',142)]:
    lay=Image.open(BG_DIR/(file+'.png')).crop((0,0,480,{'mountains':76,'treeline':64,'meadow':144}[file]))
    if file=='meadow':scene.paste(lay,(0,y))
    else:scene.paste(lay,(0,y),lay)
for i,person in enumerate(('rudeus','sylphie','roxy','eris')):
    px=64+99*i
    p=generate_hero(person,'walk',(i+1)%6)
    sc=1.35
    p=p.resize((round(48*sc),round(60*sc)),Image.Resampling.NEAREST)
    dr=ImageDraw.Draw(scene); dr.ellipse((px-17,158,px+15,160),fill='#4B9050')
    scene.paste(p,(px-p.width//2,160-round(54*sc)),p)
lay=Image.open(BG_DIR/'foreground.png').crop((0,0,480,80))
scene.paste(lay,(0,165),lay)
scene.resize((960,480),resample=Image.Resampling.NEAREST).save(ROOT/'PREVIEW_CP01A.png')
print('Generated 4 sprite sheets (idle 4 + walk 6) and 5 parallax layers; preview:',ROOT/'PREVIEW_CP01A.png')
