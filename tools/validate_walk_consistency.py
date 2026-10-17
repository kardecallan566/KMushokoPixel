"""Reject a mixed character model across walking frames."""
from pathlib import Path
from PIL import Image
ROOT = Path(__file__).resolve().parents[1]
for name in ("rudeus","sylphie","roxy","eris"):
    base=Image.open(ROOT/f"assets/characters/source/{name}.png").convert("RGBA")
    sheet=Image.open(ROOT/f"assets/characters/{name}_sheet.png").convert("RGBA")
    assert sheet.size==(1440,100),name
    ref=base.crop((0,0,72,59)).tobytes()
    leg_poses=set()
    for i in range(4,12):
        frame=sheet.crop((i*72,0,(i+1)*72,100))
        assert frame.crop((0,0,72,59)).tobytes()==ref,(name,i,"model swaps during walk")
        assert frame.getchannel("A").getbbox()[3]==94,(name,i,"foot anchor drift")
        leg_poses.add(frame.crop((0,59,72,100)).tobytes())
    assert len(leg_poses)>=3,(name,"walking pose is static")
print("PASS: 4 consistent silhouettes and grounded 8-frame walk loops")
