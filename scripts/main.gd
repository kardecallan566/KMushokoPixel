extends Node2D
## CP02: Visual pilot evolves into a small data-driven idle RPG vertical slice.
## TAB desktop window · SPACE pause · U upgrade · F farm · H HUD · T pin · S save.

const World = preload("res://scripts/world.gd")
const Hero = preload("res://scripts/hero.gd")
const EnemySprite = preload("res://scripts/enemy.gd")
const WindowMode = preload("res://scripts/window_mode.gd")
const GameSession = preload("res://scripts/combat/game_session.gd")
const Hud = preload("res://scripts/hud.gd")
const PARTY := ["rudeus", "sylphie", "roxy", "eris"]
const NAMES := ["RUDEUS", "SYLPHIE", "ROXY", "ERIS"]
const ROLES := ["ARTILHARIA", "SUPORTE", "CONTROLE", "GUERREIRA"]

var window_mode = WindowMode.new()
var session = GameSession.new()
var background: Node2D
var foreground: Node2D
var hud
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
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
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
        actor.z_index = 3
        add_child(actor)
        heroes.append(actor)
    hud = Hud.new()
    hud.game = self
    hud.z_index = 20
    add_child(hud)
    session.encounter_started.connect(_on_encounter_started)
    session.action_performed.connect(_on_action)
    session.phase_changed.connect(_on_phase_changed)
    session.progress_changed.connect(queue_redraw)
    get_window().title = "KMushokoPixel — CP02 | Planicies Verdes"
    get_window().size_changed.connect(_update_layout)
    _update_layout()

func _update_layout() -> void:
    # Pixel-perfect presentation: physical viewport divided by integer x2 or x3.
    # The size is stable across changes between desktop and expanded layouts.
    logical_scale = 2.0 if window_mode.compact else 3.0
    visible_size = Vector2(get_window().size) / logical_scale
    visible_size = Vector2(floor(visible_size.x),floor(visible_size.y))
    # Compact: 480x120 with dedicated 14px header/15px bottom strip.
    # Expanded: 384x216 with a 24px header and 26px bottom strip.
    baseline = visible_size.y - (26.0 if window_mode.compact else 65.0)
    scale = Vector2.ONE * logical_scale
    for layer in [background,foreground]:
        layer.view_size = visible_size
        layer.ground_y = baseline - 10.0
        layer.queue_redraw()
    var traveling: bool = session.phase != "combat"
    var positions := [0.12,0.28,0.44,0.60] if traveling else [0.10,0.25,0.40,0.55]
    for i in range(heroes.size()):
        heroes[i].position = Vector2(round(visible_size.x * positions[i]),int(baseline))
        heroes[i].preview_scale = 1.0
        heroes[i].queue_redraw()
    for i in range(enemies.size()):
        enemies[i].position = Vector2(round(visible_size.x * (0.75 + 0.10*i)),int(baseline))
        if i < session.enemies.size():
            enemies[i].sprite_scale = 1.0
            enemies[i].queue_redraw()
    var bar_height := 14.0 if window_mode.compact else 23.0
    _control_button = Rect2(visible_size.x - 29,2,26,bar_height-3)
    _pause_button = Rect2(visible_size.x - 58,2,26,bar_height-3)
    _upgrade_button = Rect2(4,visible_size.y-17,86,14)
    _farm_button = Rect2(94,visible_size.y-17,76,14)
    if hud != null:
        hud.queue_redraw()

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
    if hud != null:
        hud.queue_redraw()

func _on_encounter_started(stage_no: int, models: Array) -> void:
    for old in enemies:
        old.queue_free()
    enemies.clear()
    for info in models:
        var visual = EnemySprite.new()
        visual.configure(info)
        visual.z_index = 3
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

func _exit_tree() -> void:
    if session != null and session.auto_save:
        session.save_progress()
