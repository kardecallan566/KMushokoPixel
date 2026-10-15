extends SceneTree
## Headless Godot smoke and progression verification.
const GameSession = preload("res://scripts/combat/game_session.gd")

func _initialize() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("CP02 SESSION TEST FAILED: " + message)
    quit(1)

func _run() -> void:
    var game = GameSession.new(false)
    game.auto_save = false
    if game.heroes.size() != 4:
        _fail("Not all heroes loaded")
        return
    var used := {}
    var encountered: Array = []
    game.action_performed.connect(func(action: Dictionary):
        if action.has("hero") and action["kind"] != "enemy":
            used[String(action["hero"])] = true
    )
    game.encounter_started.connect(func(stage: int, _mobs: Array): encountered.append(stage))
    # Enough logical time for four heroes to complete the entire first biome.
    for i in range(12000):
        game.tick(0.1)
        if game.highest_cleared >= 10:
            break
    if game.highest_cleared != 10:
        _fail("Could not complete 10 stages; cleared %d; at %d phase %s" % [game.highest_cleared,game.stage_number,game.phase])
        return
    if not 5 in encountered or not 10 in encountered:
        _fail("Elite and boss encounters never started")
        return
    for hero_id in ["rudeus","sylphie","roxy","eris"]:
        if not used.has(hero_id):
            _fail("Hero was unused: " + hero_id)
            return
    if game.gold <= 0 or game.xp < 0 or game.level < 1 or not game.farm_mode:
        _fail("Rewards or end-of-region farm invalid")
        return
    var stage_before: int = game.stage_number
    game.paused = true
    for i in range(100):game.tick(0.1)
    if game.stage_number != stage_before:
        _fail("Pause changed stage")
        return
    # Save roundtrip: a fresh session must load the persisted victory.
    game.save_progress()
    var restored = GameSession.new(true)
    restored.auto_save = false
    if restored.highest_cleared != 10 or restored.gold != game.gold:
        _fail("Save/load roundtrip lost stage or gold")
        return
    var clone = GameSession.new(false)
    clone.auto_save = false
    if clone.highest_cleared != 0:
        _fail("No-save constructor loaded progress")
        return
    print("PASS CP02: 10 stages, elite 5, boss 10, all 4 heroes active, rewards, farm and pause")
    quit(0)