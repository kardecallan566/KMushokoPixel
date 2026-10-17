extends RefCounted
## CP02 simulation. No scene or window dependency: same battle at every window size.
## Fixed 100ms updates keep the outcome independent from rendering frame rate.

signal encounter_started(stage_number: int, enemies: Array)
signal action_performed(payload: Dictionary)
signal phase_changed(phase_name: String)
signal progress_changed()
signal enemy_summoned(enemy: Dictionary)

const DT := 0.1
const SAVE_VERSION := 1
const SAVE_FILE := "user://kmushoko_progress_v1.json"
const PATHS := {
    "characters": "res://data/characters.json",
    "stages": "res://data/stages.json",
    "enemies": "res://data/enemies.json",
    "skills": "res://data/skills.json"
}

var phase := "travel"
var stage_number := 1
var highest_cleared := 0
var gold := 0
var level := 1
var xp := 0
var wins := 0
var farm_mode := false
var paused := false
var time_elapsed := 0.0
var travel_left := 2.2
var boss_telegraph := false
var boss_phase := 1
var heroes: Array = []
var enemies: Array = []
var _accum := 0.0
var _battle_clock := 0.0
var _enemy_counter := 0
var _skill_db := {}
var _enemy_db := {}
var _stages := []
var _rng := RandomNumberGenerator.new()
var _seed := 220526
var auto_save := true

func _init(read_save: bool = true) -> void:
    _rng.seed = _seed
    _read_definitions()
    _reset_heroes()
    if read_save:
        load_progress()

func _read_json(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        push_error("Missing game data: " + path)
        return {}
    var parse = JSON.parse_string(FileAccess.get_file_as_string(path))
    if typeof(parse) != TYPE_DICTIONARY:
        push_error("Invalid JSON: " + path)
        return {}
    return parse

func _read_definitions() -> void:
    var characters: Dictionary = _read_json(PATHS["characters"])
    var skills: Dictionary = _read_json(PATHS["skills"])
    var foes: Dictionary = _read_json(PATHS["enemies"])
    var stages: Dictionary = _read_json(PATHS["stages"])
    for raw_skill in skills.get("skills", []):
        _skill_db[String(raw_skill.get("id", ""))] = raw_skill
    for raw_enemy in foes.get("enemies", []):
        _enemy_db[String(raw_enemy.get("id", ""))] = raw_enemy
    _stages = stages.get("stages", [])
    var by_id := {}
    for character in characters.get("characters", []):
        by_id[String(character.get("id", ""))] = character
    for id in characters.get("party_walk_order", []):
        if by_id.has(String(id)):
            var hero: Dictionary = by_id[String(id)].duplicate(true)
            hero["max_hp"] = 100 if id != "eris" else 150
            hero["hp"] = hero["max_hp"]
            hero["shield"] = 0
            hero["ready"] = 0.0
            hero["skill_ready"] = {}
            heroes.append(hero)

func _reset_heroes() -> void:
    for hero in heroes:
        hero["hp"] = int(hero["max_hp"]) + (level - 1) * 12
        hero["shield"] = 0
        hero["ready"] = 0.0
        hero["skill_ready"] = {}

func get_max_hp(hero: Dictionary) -> int:
    return int(hero["max_hp"]) + (level - 1) * 12

func tick(delta: float) -> void:
    if paused or phase == "error":
        return
    _accum += minf(delta, 0.25)
    while _accum >= DT:
        _accum -= DT
        _step()

func _step() -> void:
    time_elapsed += DT
    if phase == "travel":
        travel_left -= DT
        if travel_left <= 0:
            _begin_fight()
    elif phase == "combat":
        _battle_step()
    elif phase in ["victory","defeat"]:
        travel_left -= DT
        if travel_left <= 0:
            phase = "travel"
            travel_left = 1.8
            phase_changed.emit(phase)

func _begin_fight() -> void:
    if _stages.is_empty():
        phase = "error"
        push_error("No stages loaded")
        return
    phase = "combat"
    boss_telegraph = false
    boss_phase = 1
    _battle_clock = 0.0
    enemies.clear()
    var stage: Dictionary = _stages[clampi(stage_number - 1, 0, _stages.size() - 1)]
    for id in stage.get("enemies", []):
        var foe := _make_enemy(String(id))
        if not foe.is_empty():
            enemies.append(foe)
    if enemies.is_empty():
        phase = "error"
        push_error("No enemies for stage " + str(stage_number))
        return
    encounter_started.emit(stage_number, enemies)
    phase_changed.emit(phase)

func _make_enemy(enemy_id: String) -> Dictionary:
    if not _enemy_db.has(enemy_id):
        return {}
    var raw: Dictionary = _enemy_db[enemy_id]
    var boss: bool = bool(raw.get("boss", false))
    var hp_value: int = int(raw.get("hp", 40)) + maxi(0, stage_number - 1) * (13 if boss else 6)
    return {"id":enemy_id,"name":raw["name"],"sprite":raw["sprite"],"hp":hp_value,
        "max_hp":hp_value,"attack":raw["attack"],"attack_interval":raw["attack_interval"],
        "defense":raw.get("defense",0),"gold":raw.get("gold",0),"scale":raw.get("scale",1.0),
        "boss":boss,"elite":raw.get("elite",false),"boss_phase":1,"attack_count":0,
        "attack_id":"charge","windup":raw.get("windup",0.0),"windup_left":0.0,
        "ready":float(raw["attack_interval"]),"wet":0.0,"frozen":0.0,"armor_broken":0.0}

func _check_boss_transition() -> void:
    if boss_phase == 2:
        return
    for enemy in enemies:
        if not bool(enemy.get("boss", false)) or int(enemy["hp"]) <= 0:
            continue
        if float(enemy["hp"]) / maxf(1.0,float(enemy["max_hp"])) > 0.55:
            continue
        boss_phase = 2
        enemy["boss_phase"] = 2
        enemy["ready"] = maxf(0.9,float(enemy["ready"]))
        action_performed.emit({"kind":"boss_phase","text":"LOBO ALFA: FURIA DA MATILHA!",
            "hero":"","target":enemy["id"],"color":"#FF9D72","phase":2})
        # Once per battle. Enemies are standard data-driven records and earn normal rewards.
        for i in range(2):
            var minion := _make_enemy("wolf")
            if not minion.is_empty():
                # Reinforcements must survive long enough to be noticeable.
                minion["ready"] = 1.0 + float(i)*0.5
                enemies.append(minion)
                enemy_summoned.emit(minion)
        action_performed.emit({"kind":"summon","text":"REFORCOS DA MATILHA!",
            "hero":"","target":enemy["id"],"color":"#FFCA89"})
        break

func _battle_step() -> void:
    _battle_clock += DT
    boss_telegraph = false
    for enemy in enemies:
        if int(enemy["hp"]) <= 0:
            continue
        for key in ["wet","frozen","armor_broken"]:
            enemy[key] = maxf(0.0, float(enemy[key]) - DT)
        enemy["ready"] = float(enemy["ready"]) - DT
        if float(enemy["windup_left"]) > 0.0:
            if float(enemy["frozen"]) > 0.0:
                enemy["windup_left"] = 0.0
                enemy["ready"] = 1.1
                action_performed.emit({"kind":"interrupt","text":"MAGIA INTERROMPIDA!",
                    "target":enemy["id"],"color":"#B6F4FF"})
            else:
                enemy["windup_left"] = maxf(0.0, float(enemy["windup_left"]) - DT)
                boss_telegraph = true
                if float(enemy["windup_left"]) <= 0.0:
                    _enemy_attack(enemy, true)
                    enemy["ready"] = float(enemy["attack_interval"]) * (0.85 if boss_phase == 2 else 1.0)
        elif float(enemy["ready"]) <= 0.0:
            if float(enemy["frozen"]) > 0.0:
                enemy["ready"] = 0.35
            elif bool(enemy["boss"]):
                enemy["attack_id"] = "howl" if boss_phase == 2 and int(enemy["attack_count"]) % 2 == 1 else "charge"
                enemy["attack_count"] = int(enemy["attack_count"]) + 1
                enemy["windup_left"] = float(enemy["windup"]) + (0.45 if enemy["attack_id"] == "howl" else 0.0)
                boss_telegraph = true
                action_performed.emit({"kind":"telegraph","attack_id":enemy["attack_id"],
                    "target":enemy["id"],"duration":enemy["windup_left"],
                    "text":"LOBO ALFA: UIVO SOMBRIO!" if enemy["attack_id"] == "howl" else "LOBO ALFA: INVESTIDA!",
                    "color":"#FF9975"})
            else:
                _enemy_attack(enemy, false)
                enemy["ready"] = float(enemy["attack_interval"])
    for hero in heroes:
        if int(hero["hp"]) <= 0:
            continue
        hero["ready"] = float(hero["ready"]) - DT
        if float(hero["ready"]) <= 0.0:
            _hero_action(hero)
    _check_boss_transition()
    if _living_enemies().is_empty():
        _victory()
    elif _living_heroes().is_empty():
        _defeat()

func _living_enemies() -> Array:
    var alive: Array = []
    for enemy in enemies:
        if int(enemy["hp"]) > 0:
            alive.append(enemy)
    return alive

func _living_heroes() -> Array:
    var alive: Array = []
    for hero in heroes:
        if int(hero["hp"]) > 0:
            alive.append(hero)
    return alive

func _weakest_ally() -> Dictionary:
    var target: Dictionary = {}
    var ratio := 2.0
    for hero in _living_heroes():
        var value := float(hero["hp"]) / float(get_max_hp(hero))
        if value < ratio:
            ratio = value
            target = hero
    return target

func _choose_enemy() -> Dictionary:
    var alive := _living_enemies()
    if alive.is_empty():
        return {}
    var result: Dictionary = alive[0]
    for candidate in alive:
        if bool(candidate["boss"]) or bool(candidate["elite"]):
            return candidate
        if int(candidate["hp"]) < int(result["hp"]):
            result = candidate
    return result

func _trigger_ok(trigger: String, target: Dictionary) -> bool:
    var ally := _weakest_ally()
    match trigger:
        "always": return true
        "ally_below_70": return not ally.is_empty() and float(ally["hp"]) < get_max_hp(ally) * 0.70
        "ally_below_80": return not ally.is_empty() and float(ally["hp"]) < get_max_hp(ally) * 0.80
        "boss_telegraph": return boss_telegraph
        "elite_or_boss": return bool(target.get("elite",false)) or bool(target.get("boss",false))
        "wet_target":
            for enemy in _living_enemies():
                if float(enemy["wet"]) > 0.0 and float(enemy["frozen"]) <= 0.0:
                    return true
            return false
        "multiple_enemies": return _living_enemies().size() >= 2
        "enemy_below_60": return float(target["hp"]) / float(target["max_hp"]) < 0.60
        "armor_broken": return float(target["armor_broken"]) > 0.0
    return false

func _hero_action(hero: Dictionary) -> void:
    var enemy := _choose_enemy()
    if enemy.is_empty():
        return
    var abilities: Array = hero.get("skills", [])
    var chosen: Dictionary = {}
    # Later skills are tactical; default basic skill comes first in data.
    for i in range(abilities.size() - 1, -1, -1):
        var skill_id: String = String(abilities[i])
        if not _skill_db.has(skill_id):
            continue
        var skill: Dictionary = _skill_db[skill_id]
        var until: float = float(hero["skill_ready"].get(skill_id,0.0))
        if time_elapsed < until or not _trigger_ok(String(skill["trigger"]), enemy):
            continue
        chosen = skill
        break
    if chosen.is_empty():
        hero["ready"] = 0.2
        return
    var skill_key: String = String(chosen["id"])
    hero["skill_ready"][skill_key] = time_elapsed + float(chosen["cooldown"])
    hero["ready"] = 1.15 if chosen["trigger"] != "always" else 0.35
    var effect: String = String(chosen["effect"])
    var power: int = int(chosen["power"]) + (level-1) * 3
    var target: Dictionary = enemy
    if effect == "freeze":
        for foe in _living_enemies():
            if float(foe["wet"]) > 0.0:
                target = foe
                break
    if effect in ["heal","shield"]:
        var ally := _weakest_ally()
        if not ally.is_empty():
            if effect == "heal":
                var gained: int = mini(power, get_max_hp(ally) - int(ally["hp"]))
                ally["hp"] = int(ally["hp"]) + gained
                action_performed.emit({"kind":"heal","hero":hero["id"],"target":ally["id"],"amount":gained,"skill_id":skill_key,"effect":effect,"text":chosen["name"],"color":chosen["color"]})
            else:
                ally["shield"] = mini(70, int(ally["shield"]) + power)
                action_performed.emit({"kind":"shield","hero":hero["id"],"target":ally["id"],"amount":power,"skill_id":skill_key,"effect":effect,"text":chosen["name"],"color":chosen["color"]})
        return
    if effect == "aoe":
        for foe in _living_enemies():
            _hit(hero,foe,power,effect,chosen)
    else:
        _hit(hero,target,power,effect,chosen)

func _hit(hero: Dictionary, enemy: Dictionary, power: int, effect: String, skill: Dictionary) -> void:
    var armor: int = 0 if float(enemy["armor_broken"]) > 0.0 else int(enemy["defense"])
    var damage: int = maxi(1,power - armor)
    if effect == "strike" and float(enemy["armor_broken"]) > 0:
        damage = int(round(damage * 1.5))
    enemy["hp"] = maxi(0,int(enemy["hp"]) - damage)
    match effect:
        "break_armor": enemy["armor_broken"] = 6.0
        "wet": enemy["wet"] = 7.0
        "freeze":
            enemy["frozen"] = 2.6
            enemy["wet"] = 0.0
    action_performed.emit({"kind":"damage","hero":hero["id"],"target":enemy["id"],
        "amount":damage,"skill_id":skill["id"],"effect":effect,
        "text":skill["name"],"color":skill["color"]})

func _apply_enemy_damage(enemy: Dictionary, target: Dictionary, amount: int, attack_name: String) -> void:
    var absorbed: int = mini(amount, int(target["shield"]))
    target["shield"] = int(target["shield"]) - absorbed
    var damage: int = amount - absorbed
    target["hp"] = maxi(0, int(target["hp"]) - damage)
    action_performed.emit({"kind":"enemy","hero":target["id"],"target":enemy["id"],
        "amount":damage,"absorbed":absorbed,"effect":attack_name,
        "text": "Uivo Sombrio" if attack_name == "howl" else "INVESTIDA!" if attack_name == "charge" else String(enemy["name"]),
        "color":"#FF988B"})

func _enemy_attack(enemy: Dictionary, empowered: bool) -> void:
    var alive := _living_heroes()
    if alive.is_empty():
        return
    var damage: int = int(enemy["attack"]) + maxi(0,stage_number - 1)
    if empowered and String(enemy.get("attack_id","charge")) == "howl":
        for target in alive:
            _apply_enemy_damage(enemy, target, maxi(1,int(round(damage * 0.65))), "howl")
        return
    var target: Dictionary = alive[0]
    for hero in alive:
        if String(hero["combat_position"]) == "front":
            target = hero
            break
    if _rng.randf() > 0.74:
        target = alive[_rng.randi_range(0,alive.size()-1)]
    if empowered:
        damage = int(round(damage * (1.9 if boss_phase == 2 else 1.6)))
    _apply_enemy_damage(enemy, target, damage, "charge" if empowered else "claw")

func _victory() -> void:
    phase = "victory"
    var bonus := 0
    for enemy in enemies:
        bonus += int(enemy["gold"])
    var stage_reward: int = 5 + 4 * stage_number + bonus
    gold += stage_reward
    xp += 8 + stage_number * 5
    wins += 1
    while xp >= 30 + level * 20:
        xp -= 30 + level * 20
        level += 1
    for hero in heroes:
        var cap := get_max_hp(hero)
        hero["hp"] = mini(cap, int(hero["hp"]) + int(round(cap * 0.40)))
        hero["shield"] = 0
    highest_cleared = maxi(highest_cleared,stage_number)
    action_performed.emit({"kind":"reward","text":"VITORIA! +%d ouro" % stage_reward,
        "amount":stage_reward,"color":"#FFE28A"})
    if stage_number >= _stages.size():
        farm_mode = true
        stage_number = maxi(1, _stages.size() - 1)
    elif farm_mode:
        stage_number = maxi(1,mini(highest_cleared, _stages.size() - 1))
    else:
        stage_number += 1
    travel_left = 2.5
    phase_changed.emit(phase)
    progress_changed.emit()
    if auto_save:
        save_progress()

func _defeat() -> void:
    phase = "defeat"
    action_performed.emit({"kind":"defeat","text":"Equipe derrotada! Retornando ao acampamento.","color":"#FF908D"})
    stage_number = maxi(1,mini(_stages.size()-1,highest_cleared))
    farm_mode = true
    _reset_heroes()
    travel_left = 5.0
    phase_changed.emit(phase)
    progress_changed.emit()
    if auto_save:
        save_progress()

func upgrade() -> bool:
    var cost: int = 55 + (level - 1) * 25
    if gold < cost:
        return false
    gold -= cost
    level += 1
    for hero in heroes:
        hero["hp"] = mini(get_max_hp(hero),int(hero["hp"]) + 12)
    action_performed.emit({"kind":"upgrade","text":"Equipe melhorada! NIV %d" % level,"color":"#A7F5B4"})
    progress_changed.emit()
    if auto_save:
        save_progress()
    return true

func upgrade_cost() -> int:
    return 55 + (level - 1) * 25

func toggle_farm() -> void:
    farm_mode = not farm_mode
    # Do not reset an active encounter or grant free reward via a mode toggle.
    if phase != "combat":
        if farm_mode:
            stage_number = maxi(1,mini(highest_cleared,_stages.size()-1))
        else:
            stage_number = mini(_stages.size(),highest_cleared + 1)
        phase = "travel"
        travel_left = 1.0
    progress_changed.emit()

func save_progress() -> void:
    var snapshot := {"version":SAVE_VERSION,"stage":stage_number,"highest_cleared":highest_cleared,
        "gold":gold,"xp":xp,"level":level,"wins":wins,"farm_mode":farm_mode}
    var temp := SAVE_FILE + ".tmp"
    var file := FileAccess.open(temp,FileAccess.WRITE)
    if file == null:
        push_warning("Could not save progress: " + str(FileAccess.get_open_error()))
        return
    file.store_string(JSON.stringify(snapshot))
    file.flush()
    file.close()
    var absolute_tmp := ProjectSettings.globalize_path(temp)
    var absolute_save := ProjectSettings.globalize_path(SAVE_FILE)
    var err := DirAccess.rename_absolute(absolute_tmp,absolute_save)
    if err != OK:
        push_warning("Could not replace save: %d" % err)

func load_progress() -> bool:
    if not FileAccess.file_exists(SAVE_FILE):
        return false
    var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE_FILE))
    if typeof(data) != TYPE_DICTIONARY or int(data.get("version",-1)) != SAVE_VERSION:
        push_warning("Save format invalid or unsupported")
        return false
    highest_cleared = clampi(int(data.get("highest_cleared",0)),0,_stages.size())
    stage_number = clampi(int(data.get("stage",1)),1,_stages.size())
    gold = clampi(int(data.get("gold",0)),0,100000000)
    xp = clampi(int(data.get("xp",0)),0,100000000)
    level = clampi(int(data.get("level",1)),1,500)
    wins = maxi(0,int(data.get("wins",0)))
    farm_mode = bool(data.get("farm_mode",false))
    if highest_cleared == _stages.size():
        farm_mode = true
        stage_number = maxi(1,_stages.size()-1)
    _reset_heroes()
    return true
