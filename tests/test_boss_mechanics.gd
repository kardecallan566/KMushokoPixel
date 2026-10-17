extends SceneTree
## Test telegraphs, second-phase reinforcements, AoE, interrupt, and FX bounds.
const GameSession = preload("res://scripts/combat/game_session.gd")
const CombatFx = preload("res://scripts/fx/combat_fx.gd")

func _initialize() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("CP03 TEST FAILED: " + message)
    quit(1)

func _run() -> void:
    var game = GameSession.new(false)
    game.auto_save = false
    game.stage_number = 10
    game._begin_fight()
    if game.enemies.size() != 1 or not bool(game.enemies[0]["boss"]):
        _fail("Boss is not loaded")
        return
    var attacks: Array = []
    var calls := {"summons":0,"interrupts":0,"howl_hits":0}
    game.enemy_summoned.connect(func(_enemy: Dictionary):calls["summons"] += 1)
    game.action_performed.connect(func(action: Dictionary):
        if action.get("kind") == "telegraph": attacks.append(String(action.get("attack_id","")))
        if action.get("kind") == "interrupt": calls["interrupts"] += 1
        if action.get("effect") == "howl" and action.get("kind") == "enemy": calls["howl_hits"] += 1
    )
    # Lock hero skills so the boss can finish two clearly telegraphed actions.
    for hero in game.heroes:
        hero["ready"] = 99.0
    game.enemies[0]["hp"] = int(game.enemies[0]["max_hp"] * 0.5)
    game.tick(0.1)
    if game.boss_phase != 2 or calls["summons"] != 2 or game.enemies.size() != 3:
        _fail("Phase two did not summon the pack exactly once")
        return
    for i in range(200):
        game.tick(0.1)
        if calls["howl_hits"] >= 1:
            break
    if not "charge" in attacks or not "howl" in attacks or calls["howl_hits"] < 1:
        _fail("Boss attacks missing or no AoE damage")
        return
    if game.boss_phase != 2 or calls["summons"] != 2:
        _fail("Boss phase triggered repeatedly")
        return
    # Independent encounter: freeze must cancel a telegraphed boss strike.
    var interrupt_game = GameSession.new(false)
    interrupt_game.auto_save = false
    interrupt_game.stage_number = 10
    interrupt_game._begin_fight()
    for hero in interrupt_game.heroes:
        hero["ready"] = 99.0
    interrupt_game.action_performed.connect(func(action: Dictionary):
        if action.get("kind") == "interrupt": calls["interrupts"] += 1
    )
    interrupt_game.enemies[0]["ready"] = 0.05
    interrupt_game.tick(0.1)
    if float(interrupt_game.enemies[0]["windup_left"]) <= 0.0:
        _fail("No warning window before boss damage")
        return
    interrupt_game.enemies[0]["frozen"] = 2.0
    interrupt_game.tick(0.1)
    if calls["interrupts"] != 1 or float(interrupt_game.enemies[0]["windup_left"]) > 0.0:
        _fail("Freeze did not cancel the attack")
        return
    var fx = CombatFx.new()
    get_root().add_child(fx)
    fx.resize_to(Vector2(480,120),95.0)
    fx.on_battle_action({"kind":"damage","hero":"roxy","effect":"freeze","color":"#ADEFFF"},Vector2(80,55),Vector2(310,55))
    fx.on_battle_action({"kind":"telegraph","duration":1.2,"attack_id":"charge"},Vector2.ZERO,Vector2.ZERO)
    if fx.events.size() != 1 or fx.warnings.size() != 1:
        _fail("Battle FX not responding to session actions")
        return
    fx.resize_to(Vector2(384,216),155.0)
    if not fx.events.is_empty() or not fx.warnings.is_empty():
        _fail("Resize leaves effects in incorrect world positions")
        return
    print("PASS CP03: summons, phase 2, charge, AoE howl, freeze interrupt, and pixel VFX")
    quit(0)
