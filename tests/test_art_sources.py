"""Dependency-light structural smoke tests for data before the native Godot CI."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]

def test_contract():
    stage=json.loads((ROOT/'data'/'characters.json').read_text()) if (ROOT/'data'/'characters.json').exists() else None
    assert stage is None or stage['party_walk_order']==['rudeus','sylphie','roxy','eris']
    for name in ['rudeus','sylphie','roxy','eris']:
        assert (ROOT/'assets'/'characters'/f'{name}_sheet.png').is_file()
    assert (ROOT/'project.godot').is_file()
if __name__=='__main__':
    test_contract();print('PASS art sources')