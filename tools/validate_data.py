"""Validate initial game design data. Run: python tools/validate_data.py."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load(relative_path):
    with (ROOT / relative_path).open(encoding="utf-8") as stream:
        return json.load(stream)


def validate():
    roster = load("data/characters.json")
    stage_data = load("data/stages.json")
    assert roster["schema_version"] == stage_data["schema_version"] == 1

    heroes = roster["characters"]
    hero_ids = [hero["id"] for hero in heroes]
    assert len(hero_ids) == len(set(hero_ids)) == 4
    assert set(hero_ids) == set(roster["party_walk_order"])
    assert {hero["id"]: hero["class"] for hero in heroes} == {
        "rudeus": "mage", "sylphie": "mage", "roxy": "mage", "eris": "warrior"
    }
    assert len({hero["specialization"] for hero in heroes}) == 4
    for hero in heroes:
        assert len(hero["skills"]) >= 3
        assert len(hero["ai_priority"]) > 0
        assert hero["art_status"] == "reference_only"

    stages = stage_data["stages"]
    assert [stage["number"] for stage in stages] == list(range(1, 11))
    assert [stage["number"] for stage in stages if stage["kind"] == "elite"] == [5]
    assert [stage["number"] for stage in stages if stage["kind"] == "boss"] == [10]
    assert all(stage["enemies"] and stage["kind"] in ("normal", "elite", "boss") for stage in stages)
    print("OK: four classes/specializations, art references, ten stages, boss stage 10")


if __name__ == "__main__":
    validate()
