"""Check registry references / encounter design before the Godot data loader runs."""
import json
from pathlib import Path
from PIL import Image, ImageChops
ROOT=Path(__file__).resolve().parents[1]
def read(name):return json.loads((ROOT/'data'/name).read_text(encoding='utf-8'))

def validate():
    c=read('characters.json');s=read('stages.json');e=read('enemies.json');a=read('skills.json')
    assert len({i['schema_version'] for i in (c,s,e,a)})==1
    by_id={v['id']:v for v in e['enemies']};skills={v['id']:v for v in a['skills']}
    assert len(by_id)==6 and len(skills)==12
    assert [v['number'] for v in s['stages']]==list(range(1,11))
    assert s['stages'][4]['kind']=='elite' and s['stages'][9]['kind']=='boss'
    assert all(name in by_id for stage in s['stages'] for name in stage['enemies'])
    assert all(skill in skills for hero in c['characters'] for skill in hero['skills'])
    assert {v['class'] for v in c['characters']}=={'mage','warrior'}
    assert len({h['specialization'] for h in c['characters']})==4
    assert all(v['hp']>0 and v['attack']>0 and v['gold']>=0 for v in by_id.values())
    assert all(v['cooldown']>=0.1 and v['power']>0 for v in skills.values())
    sizes={'slime':(48,48),'boar':(64,56),'wolf':(64,56),'mushroom':(48,56),'elite_boar':(64,56),'alpha_wolf':(96,80)}
    for key,(w,h) in sizes.items():
        with Image.open(ROOT/'assets'/'enemies'/f'{key}_sheet.png') as sprite:
            assert sprite.mode=='RGBA' and sprite.size==(w*4,h),key
            a=sprite.crop((0,0,w,h));b=sprite.crop((w,0,w*2,h))
            assert a.getbbox() and b.getbbox() and ImageChops.difference(a,b).getbbox() is not None,key
    print('PASS CP02: 4 class roles, 12 abilities, 6 animated monsters, 10 stages')

if __name__=='__main__':validate()