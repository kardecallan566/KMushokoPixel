extends Node2D
## CP03C: reel-guided character presentation. Frames keep feet anchored at (36,94).
## Video-side silhouettes face LEFT: travel scrolls RIGHT. Combat flips to face foes.
const TextureLoader = preload("res://scripts/utils/texture_loader.gd")
const FRAME_SIZE := Vector2i(72,100)
const WALK_FIRST := 4
const WALK_FRAMES := 8
const CAST_FIRST := 12
const CAST_FRAMES := 6
const HIT_FIRST := 18
const HIT_FRAMES := 2

var hero_id: String = "rudeus"
var preview_scale: float = 1.0
var walking: bool = true
var facing_right: bool = false
var elapsed: float = 0.0
var anim_fps: float = 8.0
var attack_flash: float = 0.0
var hit_flash: float = 0.0
var _sheet: Texture2D
var _effect_texture: Texture2D

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func configure(id: String) -> void:
    hero_id = id
    _sheet = TextureLoader.load_png("res://assets/characters/%s_sheet.png" % id)
    _effect_texture = TextureLoader.load_png("res://assets/effects/%s_cast.png" % id)
    queue_redraw()

func play_attack() -> void:
    attack_flash = 0.42
    queue_redraw()

func play_hit() -> void:
    hit_flash = 0.22
    queue_redraw()

func _process(delta: float) -> void:
    if attack_flash > 0.0:
        attack_flash = maxf(0.0,attack_flash-delta)
    if hit_flash > 0.0:
        hit_flash = maxf(0.0,hit_flash-delta)
    elapsed = fmod(elapsed+delta,1000.0)
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(-18,-1,35,2),Color(0.07,0.25,0.21,0.27))
    if _sheet == null:
        return # Never replace missing hero art with placeholder rectangles.
    var frame: int = 0
    if hit_flash>0.0:
        frame = HIT_FIRST + (int(floor((0.22-hit_flash)*10.0)) % HIT_FRAMES)
    elif attack_flash>0.0:
        frame = CAST_FIRST + mini(CAST_FRAMES-1,int(floor((0.42-attack_flash)/0.42*CAST_FRAMES)))
    elif walking:
        frame = WALK_FIRST + (int(floor(elapsed*anim_fps))%WALK_FRAMES)
    else:
        frame = int(floor(elapsed*3.0))%4
    var src := Rect2(float(frame*FRAME_SIZE.x),0.0,float(FRAME_SIZE.x),float(FRAME_SIZE.y))
    if facing_right:
        draw_set_transform(Vector2.ZERO,0.0,Vector2(-1.0,1.0))
    draw_texture_rect_region(_sheet,Rect2(-36,-94,72,100),src)
    if attack_flash>0.0 and _effect_texture!=null:
        var effect_frame: int = mini(5,int(floor((0.42-attack_flash)/0.42*6.0)))
        var effect_region := Rect2(effect_frame*32,0,32,32)
        var off := Vector2(-39,-60) if hero_id != "eris" else Vector2(-42,-63)
        draw_texture_rect_region(_effect_texture,Rect2(off,Vector2(32,32)),effect_region)
    if facing_right:
        draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
