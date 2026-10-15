extends Node2D
## CP01A: visual/desktop prototype, NOT yet a battle or RPG simulation.
## F5 run · Tab mode · Space walk/pause · 1 Rudeus zoom · 2 full party · H HUD · T pin.

const World = preload("res://scripts/world.gd")
const Hero = preload("res://scripts/hero.gd")
const WindowMode = preload("res://scripts/window_mode.gd")
const PARTY := ["rudeus", "sylphie", "roxy", "eris"]
const HERO_NAMES := ["RUDEUS", "SYLPHIE", "ROXY", "ERIS"]
const HERO_ROLES := ["MAGO / ARTILHARIA", "MAGA / SUPORTE", "MAGA / CONTROLE", "GUERREIRA / DUELO"]

var window_mode = WindowMode.new()
var background
var foreground
var heroes: Array = []
var walking := true
var hud_visible := true
var solo_mode := false
var scroll_time := 0.0
var logical_scale := 2.0
var visible_size := Vector2(480.0, 240.0)
var baseline := 154.0
var _control_button := Rect2()
var _pause_button := Rect2()

func _ready() -> void:
    background = World.new()
    add_child(background)
    background.z_index = -20
    foreground = World.new()
    foreground.foreground = true
    add_child(foreground)
    foreground.z_index = 8
    for id in PARTY:
        var character = Hero.new()
        add_child(character)
        character.configure(id)
        heroes.append(character)
    _update_layout()
    get_window().size_changed.connect(_update_layout)
    get_window().title = "KMushokoPixel — Checkpoint 01A"
    set_process(true)

func _update_layout() -> void:
    # Pixel-perfect integer scaling: compact=2px per source pixel; expanded=3px.
    logical_scale = 2.0 if window_mode.compact else 3.0
    visible_size = Vector2(get_window().size) / logical_scale
    baseline = floor(visible_size.y * (0.73 if window_mode.compact else 0.67))
    scale = Vector2(logical_scale, logical_scale)
    for layer in [background,foreground]:
        layer.view_size = visible_size
        layer.ground_y = baseline - 10.0
        layer.queue_redraw()
    var positions := [0.13,0.36,0.59,0.82]
    for i in range(heroes.size()):
        heroes[i].position = Vector2(round(visible_size.x * positions[i]), baseline)
        heroes[i].preview_scale = 1.50 if window_mode.compact else 2.00
        heroes[i].queue_redraw()
    _control_button = Rect2(visible_size.x-35.0, 4.0, 30.0, 20.0)
    _pause_button = Rect2(visible_size.x-66.0, 4.0, 29.0, 20.0)
    queue_redraw()

func _process(delta: float) -> void:
    if walking:
        scroll_time = fmod(scroll_time + delta * 19.0, 96000.0)
    background.camera_scroll = scroll_time
    foreground.camera_scroll = scroll_time
    background.queue_redraw()
    foreground.queue_redraw()
    for h in heroes:
        h.walking = walking
    queue_redraw()

func _toggle_window() -> void:
    window_mode.apply(get_window(), not window_mode.compact)
    _update_layout()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_TAB: _toggle_window()
            KEY_SPACE: walking = not walking
            KEY_1: solo_mode = true
            KEY_2: solo_mode = false
            KEY_H: hud_visible = not hud_visible
            KEY_T: window_mode.toggle_top(get_window())
            KEY_ESCAPE:
                if solo_mode: solo_mode = false
                elif window_mode.compact: _toggle_window()
        get_viewport().set_input_as_handled()
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        var at := event.position / logical_scale
        if _control_button.has_point(at):
            _toggle_window()
        elif _pause_button.has_point(at):
            walking = not walking
        elif window_mode.compact and at.y <= 16.0:
            # Borderless windows need a real draggable area.
            DisplayServer.window_start_drag()

func _draw() -> void:
    if solo_mode:
        draw_rect(Rect2(Vector2.ZERO, visible_size), Color(0.03,0.06,0.11,0.42))
        # HUD only; the quarter's original formation remains visible, highlighting Rudeus.
        draw_rect(Rect2(6, visible_size.y-26, 175, 21),Color(0.08,0.10,0.15,0.91))
        _text(Vector2(12,visible_size.y-11),"PILOTO: RUDEUS | WALK / IDLE",8,Color.WHITE)
    if not hud_visible:
        return
    var bar_col := Color("#152A35")
    bar_col.a = 0.87
    draw_rect(Rect2(0,0,visible_size.x,24),bar_col)
    draw_rect(Rect2(0,24,visible_size.x,1),Color("#5D9785"))
    _text(Vector2(8,15),"KMUSHOKOPIXEL   •   PLANICIES VERDES",9,Color("#F9F8DD"))
    draw_rect(_pause_button,Color("#34505A"))
    draw_rect(_control_button,Color("#34505A"))
    _text(Vector2(_pause_button.position.x+7,17),"II" if walking else ">",10,Color.WHITE)
    _text(Vector2(_control_button.position.x+6,17),"<>" if window_mode.compact else "[]",10,Color.WHITE)
    if not window_mode.compact:
        var bottom := visible_size.y - 29.0
        draw_rect(Rect2(0,bottom,visible_size.x,29),Color(0.05,0.13,0.17,0.83))
        for i in range(4):
            var x := 9.0 + i * (visible_size.x / 4.0)
            _text(Vector2(x,bottom+11),HERO_NAMES[i],9,Color("#FCF8E6"))
            _text(Vector2(x,bottom+22),HERO_ROLES[i],7,Color("#C7E2D6"))
        _text(Vector2(8,35),"CP01A  •  ARTE PILOTO — SEM COMBATE",8,Color("#E8F7E8"))
    else:
        _text(Vector2(8,visible_size.y-5),"TAB expandir   ESPACO pausar   T fixar",8,Color("#133B43"))

func _text(point: Vector2, value: String, font_size: int, color: Color) -> void:
    draw_string(ThemeDB.fallback_font, point, value,
        HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, color)