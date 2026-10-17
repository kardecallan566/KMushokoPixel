extends Node2D
const TextureLoader = preload("res://scripts/utils/texture_loader.gd")
## Animated original retro monster sprite. Battle logic is owned by GameSession.

var enemy_id := "slime"
var sprite_scale := 1.0
var alpha_foot_y := 0
var health_ratio := 1.0
var frozen := false
var warned := false
var time_value := 0.0
var _sheet: Texture2D
var _frame_w := 48
var _frame_h := 48

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func configure(data: Dictionary) -> void:
    enemy_id = String(data.get("sprite",data.get("id","slime")))
    sprite_scale = float(data.get("scale",1.0))
    var texture_path := "res://assets/enemies/%s_sheet.png" % enemy_id
    _sheet = TextureLoader.load_png(texture_path)
    if _sheet != null:
        _frame_w = int(_sheet.get_width()/4)
        _frame_h = _sheet.get_height()
        alpha_foot_y = _frame_h - 4
    queue_redraw()

func _process(delta: float) -> void:
    time_value += delta
    queue_redraw()

func _draw() -> void:
    # Draw normal enemies at 1:1 and bosses at 1:1 (their art is larger).
    var size := Vector2(float(_frame_w), float(_frame_h))
    draw_rect(Rect2(-int(size.x/3), -2, int(size.x*2/3), 3), Color(0.04,0.23,0.20,0.32))
    if _sheet != null:
        var frame: int = int(floor(time_value * 5.0)) % 4
        var region := Rect2(float(frame*_frame_w),0,float(_frame_w),float(_frame_h))
        var bob := 1 if (int(floor(time_value * 5.0)) % 2) else 0
        var target := Rect2(-int(size.x / 2), -_frame_h + 4 - bob, _frame_w, _frame_h)
        draw_texture_rect_region(_sheet,target,region)
    else:
        draw_rect(Rect2(-12,-32,24,28),Color.DARK_RED)
    var bar_w: int = int(size.x * 0.68)
    var bar_x: int = -int(bar_w / 2)
    var bar_y: int = -_frame_h - 5
    draw_rect(Rect2(bar_x,bar_y,bar_w,4),Color("#142936"))
    draw_rect(Rect2(bar_x + 1,bar_y + 1,maxi(0, int((bar_w - 2) * clampf(health_ratio,0,1))),2),Color("#E4B27B") if warned else Color("#E96D77"))
    if frozen:
        draw_rect(Rect2(-2,bar_y-8,5,5),Color("#B7F7FF"))
    if warned:
        draw_rect(Rect2(bar_x,bar_y-8,bar_w,2),Color("#FF7C69"))
