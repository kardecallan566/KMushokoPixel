"""Regression checks for deterministic, crisp game-scale visual assets."""
from pathlib import Path
from PIL import Image,ImageChops
ROOT=Path(__file__).resolve().parents[1]


def check():
    for name in ('rudeus','sylphie','roxy','eris'):
        with Image.open(ROOT/f'assets/characters/{name}_sheet.png') as sheet:
            assert sheet.size == (480,60)
            assert sheet.mode=='RGBA'
            for i in range(10):
                im=sheet.crop((i*48,0,(i+1)*48,60))
                bbox=im.getchannel('A').getbbox()
                assert bbox is not None and bbox[3] in (54,55), (name,i,bbox)
                assert bbox[0] >= 2 and bbox[2] <= 47, (name,i,bbox)
        with Image.open(ROOT/f'assets/effects/{name}_cast.png') as effect:
            assert effect.size == (192,32) and effect.mode=='RGBA'
            frames=[effect.crop((i*32,0,(i+1)*32,32)) for i in range(6)]
            assert all(f.getchannel('A').getbbox() for f in frames)
            assert ImageChops.difference(frames[0],frames[-1]).getbbox() is not None
    names=('slime','boar','wolf','mushroom','elite_boar','alpha_wolf')
    for name in names:
        with Image.open(ROOT/f'assets/enemies/{name}_sheet.png') as sheet:
            w=sheet.width//4
            assert (w,sheet.height)==({'slime':(48,48),'mushroom':(48,56),'alpha_wolf':(96,80)}.get(name,(64,56)))
            bounds=[sheet.crop((i*w,0,(i+1)*w,sheet.height)).getchannel('A').getbbox() for i in range(4)]
            assert all(bounds)
            assert bounds[0][3] == sheet.height - 3, (name,bounds)
            assert all(abs(b[3]-bounds[0][3])<=3 for b in bounds), (name,bounds)
    main=(ROOT/'scripts/main.gd').read_text()
    hero=(ROOT/'scripts/hero.gd').read_text()
    hud=(ROOT/'scripts/hud.gd').read_text()
    enemy=(ROOT/'scripts/enemy.gd').read_text()
    assert 'logical_scale = 2.0 if window_mode.compact else 3.0' in main
    assert 'hud.z_index = 20' in main
    assert 'texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST' in hero
    assert 'var preview_scale := 1.0' in hero
    assert 'Rect2(-24, -54, FRAME_SIZE.x, FRAME_SIZE.y)' in hero
    assert 'var size := Vector2(float(_frame_w), float(_frame_h))' in enemy
    assert 'var header_h := 14.0 if window_mode.compact else 25.0' in hud
    print('PASS CP02B: aligned sprite foot anchors, spell frames, pixel-perfect scale, HUD layer')

if __name__=='__main__':check()
