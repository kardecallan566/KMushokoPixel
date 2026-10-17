"""Pixel art regression: animation readability, foot alignment, and sources."""
from pathlib import Path
from PIL import Image, ImageChops
ROOT=Path(__file__).resolve().parents[1]
def validate():
    for name in ('rudeus','sylphie','roxy','eris'):
        with Image.open(ROOT/f'assets/characters/{name}_sheet.png') as sheet:
            assert sheet.size == (1440,100) and sheet.mode=='RGBA', name
            frames=[sheet.crop((i*72,0,(i+1)*72,100)) for i in range(20)]
            assert all(frame.getchannel('A').getbbox() for frame in frames), name
            assert len({frame.tobytes() for frame in frames[4:12]}) >= 3, 'static walk: '+name
            assert all(frame.getchannel('A').getbbox()[3] <= 96 for frame in frames),name
        with Image.open(ROOT/f'assets/characters/source/{name}.png') as original:
            assert original.size == (72,100),name
        for i in range(4):
            assert (ROOT/f'assets/characters/source/walk{i}/{name}.png').exists()
    for n in ('clouds','mountains','treeline','meadow','foreground','details'):
        with Image.open(ROOT/f'assets/biomes/green_plains/{n}.png') as img:
            assert img.width==960 and img.height>0,n
    print('PASS: 4 reference-guided heroes, 20 frames each, 6 biome layers')
if __name__ == '__main__':validate()
