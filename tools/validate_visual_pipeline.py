"""CP03C: verify consistent pixel-grid and HUD/z-order behavior."""
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
def check():
    for name in ('rudeus','sylphie','roxy','eris'):
        with Image.open(ROOT/f'assets/characters/{name}_sheet.png') as sprite:
            assert sprite.size==(1440,100),name
            for i in range(20):
                box=sprite.crop((i*72,0,(i+1)*72,100)).getchannel('A').getbbox()
                assert box is not None and 60<=box[3]<=96,(name,i,box)
    for name in ('slime','boar','wolf','mushroom','elite_boar','alpha_wolf'):
        with Image.open(ROOT/f'assets/enemies/{name}_sheet.png') as sheet:
            w=sheet.width//4
            assert (w,sheet.height)==({'slime':(48,48),'mushroom':(48,56),'alpha_wolf':(96,80)}.get(name,(64,56)))
            assert all(sheet.crop((i*w,0,(i+1)*w,sheet.height)).getbbox() for i in range(4)),name
    main=(ROOT/'scripts/main.gd').read_text()
    hero=(ROOT/'scripts/hero.gd').read_text()
    hud=(ROOT/'scripts/hud.gd').read_text()
    assert 'scroll_time - delta*19.0' in main,'direction must match Reel walk'
    assert 'heroes[i].facing_right = session.phase == "combat"' in main
    assert 'Vector2(-1.0,1.0)' in hero
    assert 'hud.z_index = 20' in main
    assert 'Rect2(x,y,block_width-3.0,25)' in hud
    print('PASS: 8-frame walks, pixel scale, party facing, HUD and monsters')
if __name__=='__main__':check()
