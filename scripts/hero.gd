extends Node2D
## Displays hand-authored 48x60 sprite-sheet frames.
## Cells 0-3: idle; cells 4-9: walk. Strict nearest-neighbor rendering.

const FRAME_SIZE := Vector2i(48, 60)
const FRAME_COUNTS := {"idle": 4, "walk": 6}

var hero_id := "rudeus"
var preview_scale := 1.0
var walking := true
var elapsed := 0.0
var anim_fps := 8.0
var _sheet: Texture2D
var attack_flash := 0.0
var _effect_texture: Texture2D
var _effect_frame_count := 6

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func play_attack() -> void:
    attack_flash = 0.30
    queue_redraw()

func configure(id: String) -> void:
    hero_id = id
    var path := "res://assets/characters/%s_sheet.png" % hero_id
    if ResourceLoader.exists(path):
        _sheet = load(path) as Texture2D
    var effect_path := "res://assets/effects/%s_cast.png" % hero_id
    if ResourceLoader.exists(effect_path):
        _effect_texture = load(effect_path) as Texture2D
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
    # Draw every sprite on the same 1:1 pixel grid. The parent scales by x2 or x3.
    # Sprite-sheet's shared foot anchor is at (24,54); no fractional zoom or jitter.
    var destination := Rect2(-24, -54, FRAME_SIZE.x, FRAME_SIZE.y)
    draw_texture_rect_region(_sheet, destination, src)
    if attack_flash > 0.0 and _effect_texture != null:
        var progress: float = clampf((0.30 - attack_flash) / 0.30, 0.0, 0.999)
        var frame: int = mini(5, int(floor(progress * float(_effect_frame_count))))
        var fx_region := Rect2(frame * 32, 0, 32, 32)
        # The hand anchor is stable; magic and sword effects have dedicated colors.
        var fx_pos := Vector2(6,-46) if hero_id != "eris" else Vector2(9,-46)
        draw_texture_rect_region(_effect_texture,Rect2(fx_pos,Vector2(32,32)),fx_region)
