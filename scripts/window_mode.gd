extends RefCounted
## Stateful desktop-window adapter; never recreates world/session nodes.

const COMPACT := Vector2i(960, 240)
const EXPANDED := Vector2i(1152, 648)

var compact := false
var always_on_top := true
var expanded_pos := Vector2i(-1, -1)
var compact_pos := Vector2i(-1, -1)

func _clamp_screen(window: Window, pos: Vector2i, size: Vector2i) -> Vector2i:
    var screen_id := window.current_screen
    var origin := DisplayServer.screen_get_position(screen_id)
    var bounds := DisplayServer.screen_get_usable_rect(screen_id)
    var rect_origin := bounds.position if bounds.size.x > 0 else origin
    var rect_size := bounds.size if bounds.size.x > 0 else DisplayServer.screen_get_size(screen_id)
    return Vector2i(
        clampi(pos.x, rect_origin.x, rect_origin.x + maxi(0, rect_size.x - size.x)),
        clampi(pos.y, rect_origin.y, rect_origin.y + maxi(0, rect_size.y - size.y))
    )

func apply(window: Window, new_compact: bool) -> void:
    if compact == new_compact:
        return
    var old_position := window.position
    if compact:
        compact_pos = old_position
    else:
        expanded_pos = old_position
    compact = new_compact
    window.mode = Window.MODE_WINDOWED
    window.borderless = compact
    window.always_on_top = compact and always_on_top
    window.unresizable = compact
    var target_size := COMPACT if compact else EXPANDED
    window.size = target_size
    var desired := compact_pos if compact else expanded_pos
    if desired.x < 0:
        var rect := DisplayServer.screen_get_usable_rect(window.current_screen)
        desired = Vector2i(rect.position.x + (rect.size.x - target_size.x) / 2,
            rect.position.y + rect.size.y - target_size.y - 18) if compact else Vector2i(
                rect.position.x + (rect.size.x - target_size.x) / 2,
                rect.position.y + (rect.size.y - target_size.y) / 2)
    window.position = _clamp_screen(window, desired, target_size)

func toggle_top(window: Window) -> void:
    always_on_top = not always_on_top
    if compact:
        window.always_on_top = always_on_top