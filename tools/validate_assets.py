"""Pixel-asset regression checks (Pillow required)."""
from pathlib import Path
from PIL import Image, ImageChops
ROOT = Path(__file__).resolve().parents[1]

def validate():
    for name in ['rudeus','sylphie','roxy','eris']:
        path=ROOT/'assets'/'characters'/f'{name}_sheet.png'
        with Image.open(path) as im:
            assert im.size == (480,60) and im.mode == 'RGBA', path
            frames = [im.crop((i*48,0,(i+1)*48,60)) for i in range(10)]
            assert all(f.getbbox() for f in frames), f'Empty frame: {name}'
            assert ImageChops.difference(frames[0],frames[2]).getbbox() is not None, f'Idle not animated: {name}'
            assert ImageChops.difference(frames[4],frames[6]).getbbox() is not None, f'Walk not animated: {name}'
    for n in ['clouds','mountains','treeline','meadow','foreground']:
        p = ROOT/'assets'/'biomes'/'green_plains'/f'{n}.png'
        with Image.open(p) as im:
            assert im.size[0] == 960, p
            assert im.size[1] > 0, p
    print('PASS: 4 heroes x 10 frames, animation differs; 5 background layers')

if __name__ == '__main__': validate()