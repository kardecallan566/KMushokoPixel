extends SceneTree
const Main = preload("res://scripts/main.gd")
func _initialize() -> void:
    call_deferred("_run")
func _fail(reason: String) -> void:
    push_error("PARTY DIRECTION: "+reason)
    quit(1)
func _run() -> void:
    var scene = Main.new()
    scene.session.auto_save = false
    get_root().add_child(scene)
    scene.session.phase = "travel"
    scene._update_layout()
    for actor in scene.heroes:
        if actor.facing_right:
            _fail("exploration must face left")
            return
    var scroll_before: float = scene.scroll_time
    scene._process(0.025)
    if scene.scroll_time >= scroll_before:
        _fail("parallax must move right as party travels left")
        return
    scene.session.phase = "combat"
    scene.session.enemies = [{"id":"wolf","sprite":"wolf","hp":40,"max_hp":40,"frozen":0.0,"windup_left":0.0}]
    scene._on_encounter_started(1, scene.session.enemies)
    if scene.enemies.size() != 1:
        _fail("enemy sprite missing")
        return
    if not scene.enemies[0].facing_right:
        _fail("left-side monster must face heroes")
        return
    if scene.enemies[0].position.x >= scene.heroes[3].position.x:
        _fail("enemy must spawn in front, on the LEFT")
        return
    if not (scene.heroes[3].position.x < scene.heroes[2].position.x and scene.heroes[2].position.x < scene.heroes[1].position.x and scene.heroes[1].position.x < scene.heroes[0].position.x):
        _fail("Eris must be at the front with other heroes behind")
        return
    for hero in scene.heroes:
        if hero.facing_right:
            _fail("hero faces away from approaching monster")
            return
    scene.queue_free()
    print("PASS: leftward walk, enemy ahead, correct battle formation and facing")
    quit(0)
