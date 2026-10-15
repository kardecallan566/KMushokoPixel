extends Node2D
## Displays hand-authored 48x60 sprite-sheet frames.
## Cells 0-3: idle; cells 4-9: walk. Strict nearest-neighbor rendering.

const FRAME_SIZE := Vector2i(48, 60)
const FRAME_COUNTS := {"idle": 4, "walk": 6}

var hero_id := "rudeus"
var preview_scale := 1.35
var walking := true
var elapsed := 0.0
var anim_fps := 8.0
var _sheet: Texture2D
var attack_flash := 0.0

func play_attack() -> void:
    attack_flash = 0.30
    queue_redraw()

func configure(id: String) -> void:
    hero_id = id
    var path := "res://assets/characters/%s_sheet.png" % hero_id
    if ResourceLoader.exists(path):
        _sheet = load(path) as Texture2D
    else:
        push_warning("Missing sprite asset: %s. Run python tools/generate_assets.py." % path)
    queue_redraw()

func _process(delta: float) -> void:
    attack_flash = maxf(0.0,attack_flash - delta)
    if walking:
        elapsed = fmod(elapsed + delta, 600.0)
    else:
        elapsed = fmod(elapsed + delta * 0.4, 600.0)
    queue_redraw()

func _draw() -> void:
    var c := Color(0.17, 0.39, 0.33, 0.27)
    draw_rect(Rect2(-15.0, -1.0, 30.0, 3.0), c)
    if _sheet == null:
        draw_rect(Rect2(-8.0, -48.0, 16.0, 48.0), Color(0.25,0.18,0.35))
        return
    var count := FRAME_COUNTS["walk"] if walking else FRAME_COUNTS["idle"]
    var first := 4 if walking else 0
    var index: int = first + (int(floor(elapsed * anim_fps)) % count)
    var src := Rect2(float(index * FRAME_SIZE.x), 0.0, FRAME_SIZE.x, FRAME_SIZE.y)
    # Anchor source feet at y=54 and x=24; pixel-snap viewport transforms.
    var destination := Rect2(-24.0 * preview_scale, -54.0 * preview_scale,
        FRAME_SIZE.x * preview_scale, FRAME_SIZE.y * preview_scale)
    if attack_flash > 0:
        destination.position.x += sin(attack_flash * 30.0) * 3.0
        draw_circle(Vector2(8.0,-30.0),3.0,Color("#F7ECBD"))
    draw_texture_rect_region(_sheet, destination, src)