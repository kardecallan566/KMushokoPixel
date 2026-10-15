extends Node2D
## Animated original retro monster sprite. Battle logic is owned by GameSession.

var enemy_id := "slime"
var sprite_scale := 1.0
var health_ratio := 1.0
var frozen := false
var warned := false
var time_value := 0.0
var _sheet: Texture2D
var _frame_w := 48
var _frame_h := 48

func configure(data: Dictionary) -> void:
    enemy_id = String(data.get("sprite",data.get("id","slime")))
    sprite_scale = float(data.get("scale",1.0))
    var texture_path := "res://assets/enemies/%s_sheet.png" % enemy_id
    if ResourceLoader.exists(texture_path):
        _sheet = load(texture_path) as Texture2D
        _frame_w = int(_sheet.get_width()/4)
        _frame_h = _sheet.get_height()
    else:
        push_warning("Missing enemy sheet " + texture_path)
    queue_redraw()

func _process(delta: float) -> void:
    time_value += delta
    queue_redraw()

func _draw() -> void:
    var size := Vector2(float(_frame_w),float(_frame_h))*sprite_scale
    draw_rect(Rect2(-size.x*0.28,-2,size.x*0.56,3),Color(0.04,0.23,0.20,0.25))
    if _sheet != null:
        var frame: int = int(floor(time_value * 5.0)) % 4
        var region := Rect2(float(frame*_frame_w),0,float(_frame_w),float(_frame_h))
        var target := Rect2(-size.x*0.5, -size.y + 3.0 + sin(time_value*8.0)*1.0, size.x, size.y)
        draw_texture_rect_region(_sheet,target,region)
    else:
        draw_rect(Rect2(-12,-32,24,28),Color.DARK_RED)
    var bar_y := -size.y-5.0
    draw_rect(Rect2(-size.x*0.38,bar_y,size.x*0.76,4.0),Color("#142936"))
    draw_rect(Rect2(-size.x*0.38+1,bar_y+1,maxf(0.0,size.x*0.76-2)*health_ratio,2),Color("#E4B27B") if warned else Color("#E96D77"))
    if frozen:
        draw_circle(Vector2(0.0,-size.y-9.0),2.5,Color("#B7F7FF"))
    if warned:
        draw_rect(Rect2(-size.x*0.40,bar_y-8,size.x*0.8,2),Color("#FF7C69"))