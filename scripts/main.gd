extends Node2D
## CP02: Visual pilot evolves into a small data-driven idle RPG vertical slice.
## TAB desktop window · SPACE pause · U upgrade · F farm · H HUD · T pin · S save.

const World = preload("res://scripts/world.gd")
const Hero = preload("res://scripts/hero.gd")
const EnemySprite = preload("res://scripts/enemy.gd")
const WindowMode = preload("res://scripts/window_mode.gd")
const GameSession = preload("res://scripts/combat/game_session.gd")
const PARTY := ["rudeus", "sylphie", "roxy", "eris"]
const NAMES := ["RUDEUS", "SYLPHIE", "ROXY", "ERIS"]
const ROLES := ["ARTILHARIA", "SUPORTE", "CONTROLE", "GUERREIRA"]

var window_mode = WindowMode.new()
var session = GameSession.new()
var background: Node2D
var foreground: Node2D
var heroes: Array = []
var enemies: Array = []
var hud_visible := true
var scroll_time := 0.0
var logical_scale := 3.0
var visible_size := Vector2(384.0,216.0)
var baseline := 155.0
var _control_button := Rect2()
var _pause_button := Rect2()
var _upgrade_button := Rect2()
var _farm_button := Rect2()
var _status_text := "EXPLORANDO PLANICIES VERDES"
var _status_color := Color("#F5F5D6")
var _status_time := 0.0
var _flashes: Array = []

func _ready() -> void:
    background = World.new()
    background.z_index = -20
    add_child(background)
    foreground = World.new()
    foreground.foreground = true
    foreground.z_index = 8
    add_child(foreground)
    for id in PARTY:
        var actor = Hero.new()
        actor.configure(id)
        add_child(actor)
        heroes.append(actor)
    session.encounter_started.connect(_on_encounter_started)
    session.action_performed.connect(_on_action)
    session.phase_changed.connect(_on_phase_changed)
    session.progress_changed.connect(queue_redraw)
    get_window().title = "KMushokoPixel — CP02 | Planicies Verdes"
    get_window().size_changed.connect(_update_layout)
    _update_layout()

func _update_layout() -> void:
    logical_scale = 2.0 if window_mode.compact else 3.0
    visible_size = Vector2(get_window().size) / logical_scale
    baseline = floor(visible_size.y * (0.72 if window_mode.compact else 0.70))
    scale = Vector2.ONE * logical_scale
    for layer in [background,foreground]:
        layer.view_size = visible_size
        layer.ground_y = baseline - 10.0
        layer.queue_redraw()
    # Keep room for enemies during battle; regroup the party by phase.
    var traveling: bool = session.phase != "combat"
    var positions := [0.13,0.35,0.58,0.80] if traveling else [0.08,0.20,0.32,0.44]
    for i in range(heroes.size()):
        heroes[i].position = Vector2(round(visible_size.x * positions[i]),baseline)
        heroes[i].preview_scale = 1.0 if window_mode.compact else 1.30
        heroes[i].queue_redraw()
    for i in range(enemies.size()):
        enemies[i].position = Vector2(round(visible_size.x*(0.68 + 0.11*i)),baseline + 1)
        if i < session.enemies.size():
            var monster: Dictionary = session.enemies[i]
            enemies[i].sprite_scale = (0.70 if window_mode.compact else 1.30) if bool(monster.get("boss",false)) else (0.95 if window_mode.compact else 1.0) * float(monster.get("scale",1.0))
    _control_button = Rect2(visible_size.x-31,4,27,18)
    _pause_button = Rect2(visible_size.x-60,4,26,18)
    _upgrade_button = Rect2(5,visible_size.y-23,98,18)
    _farm_button = Rect2(109,visible_size.y-23,85,18)
    queue_redraw()

func _process(delta: float) -> void:
    session.tick(delta)
    if session.phase in ["travel","victory","defeat"] and not session.paused:
        scroll_time = fmod(scroll_time + delta*19.0,96000.0)
    background.camera_scroll = scroll_time
    foreground.camera_scroll = scroll_time
    background.queue_redraw()
    foreground.queue_redraw()
    for i in range(heroes.size()):
        heroes[i].walking = session.phase in ["travel","victory","defeat"] and not session.paused
    for i in range(enemies.size()):
        if i >= session.enemies.size():
            continue
        var mob: Dictionary = session.enemies[i]
        enemies[i].health_ratio = float(mob["hp"])/maxf(1.0,float(mob["max_hp"]))
        enemies[i].frozen = float(mob["frozen"]) > 0.0
        enemies[i].warned = float(mob["windup_left"]) > 0.0
        enemies[i].visible = session.phase == "combat" and int(mob["hp"]) > 0
    _status_time -= delta
    for j in range(_flashes.size()-1,-1,-1):
        _flashes[j]["life"] = float(_flashes[j]["life"]) - delta
        if float(_flashes[j]["life"]) <= 0.0:
            _flashes.remove_at(j)
    queue_redraw()

func _on_encounter_started(stage_no: int, models: Array) -> void:
    for old in enemies:
        old.queue_free()
    enemies.clear()
    for info in models:
        var visual = EnemySprite.new()
        visual.configure(info)
        add_child(visual)
        enemies.append(visual)
    _status_text = "ENCONTRO  %02d / 10" % stage_no
    _status_color = Color("#FFE9BF")
    _status_time = 4.0
    _update_layout()

func _on_phase_changed(new_phase: String) -> void:
    if new_phase == "victory":
        _status_color = Color("#B5FFC5")
        _status_time = 3.0
    elif new_phase == "defeat":
        _status_color = Color("#FFC3BE")
        _status_time = 5.0
    elif new_phase == "travel":
        _status_text = "EXPLORANDO  |  FASE %02d" % session.stage_number
        _status_time = 1.6
    _update_layout()

func _on_action(action: Dictionary) -> void:
    _status_text = String(action.get("text",""))
    _status_color = Color(String(action.get("color","#FFFFFF")))
    _status_time = 1.4 if action.get("kind") not in ["reward","defeat"] else 3.0
    if action.has("hero") and action.get("kind") != "enemy":
        var i := PARTY.find(String(action["hero"]))
        if i >= 0:
            heroes[i].play_attack()
    if action.get("kind") in ["damage","enemy","heal","shield"]:
        _flashes.append({"kind":action["kind"],"hero":String(action.get("hero","")),
            "amount":int(action.get("amount",0)),"color":_status_color,"life":0.7})
        if _flashes.size()>22:
            _flashes.pop_front()

func _toggle_window() -> void:
    window_mode.apply(get_window(),not window_mode.compact)
    _update_layout()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_TAB: _toggle_window()
            KEY_SPACE: session.paused = not session.paused
            KEY_H: hud_visible = not hud_visible
            KEY_T: window_mode.toggle_top(get_window())
            KEY_U: _try_upgrade()
            KEY_F: session.toggle_farm()
            KEY_S:
                session.save_progress()
                _status_text = "JOGO SALVO"
                _status_time = 1.5
            KEY_ESCAPE:
                if window_mode.compact: _toggle_window()
        get_viewport().set_input_as_handled()
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        var point := event.position/logical_scale
        if _control_button.has_point(point):
            _toggle_window()
        elif _pause_button.has_point(point):
            session.paused = not session.paused
        elif _upgrade_button.has_point(point):
            _try_upgrade()
        elif _farm_button.has_point(point):
            session.toggle_farm()
        elif window_mode.compact and point.y <= 14:
            DisplayServer.window_start_drag()

func _try_upgrade() -> void:
    if not session.upgrade():
        _status_text = "OURO INSUFICIENTE!"
        _status_color = Color("#FFC1A6")
        _status_time = 1.4

func _draw() -> void:
    if not hud_visible:
        return
    var dark := Color("#162934")
    dark.a = 0.92
    draw_rect(Rect2(0,0,visible_size.x,25),dark)
    draw_rect(Rect2(0,24,visible_size.x,1),Color("#61998A"))
    var title := "KMUSHOKOPIXEL  |  %02d/10" % session.stage_number
    if session.highest_cleared >= 10:
        title = "KMUSHOKOPIXEL | REGIAO CONCLUIDA"
    _text(Vector2(7,14),title,9,Color("#F8F5DE"))
    draw_rect(_pause_button,Color("#3F6266"))
    draw_rect(_control_button,Color("#3F6266"))
    _text(_pause_button.position+Vector2(7,13),">" if session.paused else "II",9,Color.WHITE)
    _text(_control_button.position+Vector2(5,13),"<>" if window_mode.compact else "[]",9,Color.WHITE)
    var info_y := 36.0
    var left_hud := Rect2(5,27,180,20)
    draw_rect(left_hud,Color("#17333E"))
    _text(Vector2(10,40),"OURO %d  NIV %d  VIT %d" % [session.gold,session.level,session.wins],9,Color("#FFE6A1"))
    if session.phase == "combat" and not session.enemies.is_empty():
        var alive := 0
        var total_hp := 0.0
        var total_max := 0.0
        for mob in session.enemies:
            if int(mob["hp"]) > 0: alive += 1
            total_hp += maxf(0,float(mob["hp"]))
            total_max += float(mob["max_hp"])
        _text(Vector2(8,57),"COMBATE | INIMIGOS %d" % alive,9,Color("#FFF3CF"))
        _bar(Vector2(8,61),minf(visible_size.x*0.40,157.0),4,total_hp/maxf(1,total_max),Color("#E27A68"))
        if session.boss_telegraph:
            draw_rect(Rect2(visible_size.x*0.46,28,visible_size.x*0.48,20),Color("#773644"))
            _text(Vector2(visible_size.x*0.47,42),"ATAQUE DO CHEFE!",9,Color("#FFF1D5"))
    if _status_time > 0.0:
        var text_len: float = minf(visible_size.x-10.0,maxf(140.0,_status_text.length()*5.2))
        draw_rect(Rect2((visible_size.x-text_len)/2,75,text_len,17),Color("#20313A"))
        _text(Vector2((visible_size.x-text_len)/2+6,87),_status_text,9,_status_color)
    if session.phase == "combat" or not window_mode.compact:
        _draw_party_status()
    if not window_mode.compact:
        draw_rect(Rect2(0,visible_size.y-26,visible_size.x,26),Color("#122B35"))
        draw_rect(_upgrade_button,Color("#376656"))
        draw_rect(_farm_button,Color("#415F6B"))
        _text(_upgrade_button.position+Vector2(6,13),"[U] UP %d" % session.upgrade_cost(),8,Color("#E8FFE1"))
        _text(_farm_button.position+Vector2(5,13),"[F] FARM %s" % ("ON" if session.farm_mode else "OFF"),8,Color.WHITE)
        _text(Vector2(visible_size.x-137,visible_size.y-9),"TAB JANELA | S SALVAR",8,Color("#C9DBE5"))
    else:
        draw_rect(Rect2(0,visible_size.y-23,visible_size.x,23),Color("#172F38"))
        draw_rect(_upgrade_button,Color("#376656"))
        draw_rect(_farm_button,Color("#415F6B"))
        _text(Vector2(10,visible_size.y-9),"UP %d" % session.upgrade_cost(),9,Color("#E8FFE1"))
        _text(Vector2(115,visible_size.y-9),"FARM %s" % ("ON" if session.farm_mode else "OFF"),9,Color.WHITE)
        _text(Vector2(visible_size.x-103,visible_size.y-9),"TAB EXPANDIR",8,Color("#D5E8EB"))
    for flash in _flashes:
        var x := visible_size.x*0.72 if flash["kind"] == "damage" else visible_size.x*0.36
        var y := baseline - 83.0 - (0.7-float(flash["life"]))*25.0
        if flash["kind"] in ["damage","enemy"]:
            _text(Vector2(x,y),"-%d" % int(flash["amount"]),12,flash["color"])
        elif flash["kind"] == "heal":
            _text(Vector2(x,y),"+%d" % int(flash["amount"]),11,flash["color"])

func _draw_party_status() -> void:
    var y := visible_size.y-41.0 if window_mode.compact else visible_size.y-51.0
    var step := visible_size.x / 4.0
    for i in range(mini(heroes.size(),session.heroes.size())):
        var hero: Dictionary = session.heroes[i]
        var x := 7.0 + i * step
        draw_rect(Rect2(x-3,y-13,step-6,25),Color(0.08,0.20,0.25,0.86))
        _text(Vector2(x,y-3),NAMES[i],8,Color("#FFF3DD"))
        var ratio: float = float(hero["hp"])/float(session.get_max_hp(hero))
        _bar(Vector2(x,y+2),step-14.0,4,ratio,Color("#72D887"))
        var shield: int = int(hero["shield"])
        if shield > 0:
            _text(Vector2(x,y+13),"ESC %d" % shield,7,Color("#9DDCF8"))
        elif not window_mode.compact:
            _text(Vector2(x,y+13),ROLES[i],7,Color("#B8DFD3"))

func _bar(pos: Vector2, width: float, height: float, value: float, color: Color) -> void:
    draw_rect(Rect2(pos,Vector2(width,height)),Color("#1E3542"))
    draw_rect(Rect2(pos+Vector2.ONE,Vector2(maxf(0,(width-2)*clampf(value,0,1)),maxf(1,height-2))),color)

func _text(at: Vector2, value: String, size: int, color: Color) -> void:
    draw_string(ThemeDB.fallback_font,at,value,HORIZONTAL_ALIGNMENT_LEFT,-1.0,size,color)

func _exit_tree() -> void:
    if session != null and session.auto_save:
        session.save_progress()