extends Node2D
const TextureLoader = preload("res://scripts/utils/texture_loader.gd")
## Original hand-generated parallax for CP01A. Pure presentation layer.

var view_size := Vector2(480, 240)
var ground_y := 150.0
var camera_scroll := 0.0
var foreground := false
var _tex := {}

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    for key in ["clouds", "mountains", "treeline", "meadow", "foreground"]:
        var path := "res://assets/biomes/green_plains/%s.png" % key
        var texture: Texture2D = TextureLoader.load_png(path)
        if texture != null:
            _tex[key] = texture

func _tile(key: String, y: float, speed: float, x_shift: float = 0.0) -> void:
    if not _tex.has(key):
        return
    var texture: Texture2D = _tex[key]
    var w: int = texture.get_width()
    var x: int = -int(floor(fposmod(camera_scroll * speed, float(w)))) + int(x_shift)
    while x < int(ceil(view_size.x)):
        draw_texture(texture, Vector2(x, floor(y)))
        x += w

func _draw() -> void:
    if not foreground:
        draw_rect(Rect2(Vector2.ZERO, view_size), Color("#1F92FD"))
        # Sky and mountains are far apart in depth, matching the Reel's layers.
        _tile("clouds", maxf(2.0, ground_y - 150.0), 0.06)
        _tile("mountains", ground_y - 72.0, 0.14)
        _tile("treeline", ground_y - 42.0, 0.30)
        draw_rect(Rect2(0, ground_y - 8.0, view_size.x, view_size.y - ground_y + 8.0), Color("#89C347"))
        _tile("meadow", ground_y - 8.0, 0.92)
    else:
        _tile("foreground", ground_y + 12.0, 1.12)
