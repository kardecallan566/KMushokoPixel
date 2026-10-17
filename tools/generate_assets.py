"""Deterministic hero animation build; biome assets have independent generators."""
from build_hero_reference_art import paint
if __name__ == "__main__":
    for hero in ("rudeus", "sylphie", "roxy", "eris"):
        paint(hero)
    print("PASS: rendered four reference-guided character sheets")
