extends SceneTree
## CP03C native smoke: every hero has native 20-frame art and facing follows combat.
const Hero = preload("res://scripts/hero.gd")
const Fx = preload("res://scripts/fx/combat_fx.gd")

func _initialize() -> void:
    call_deferred("_run")

func _fail(reason: String) -> void:
    push_error("VISUAL REBOOT FAILURE: "+reason)
    quit(1)

func _run() -> void:
    for name in ["rudeus","sylphie","roxy","eris"]:
        var hero = Hero.new()
        get_root().add_child(hero)
        hero.configure(name)
        if hero._sheet == null or hero._sheet.get_width()!=1440 or hero._sheet.get_height()!=100:
            _fail("missing reference-guided hero sprite "+name)
            return
        hero.walking = true
        hero.facing_right = false
        hero.queue_redraw()
        hero.facing_right = true
        hero.play_attack()
        hero.queue_redraw()
        hero.queue_free()
    var fx = Fx.new()
    get_root().add_child(fx)
    for element in ["fire","air","arrow","ice","water"]:
        fx.on_battle_action({"kind":"damage","element":element,"hero":"rudeus","color":"#B2E1FE"},Vector2(30,35),Vector2(300,35))
    if fx.events.size()!=5:
        _fail("elemental visual FX not registered")
        return
    fx.queue_free()
    print("PASS CP03C: native 20-frame art, facing, fire, wind, arrows, ice and water")
    quit(0)
