extends Node2D
## Pixel-accurate, event-driven battle feedback. Graphics are intentionally drawn
## at integer logical coordinates: the root viewport applies an integer 2x/3x zoom.
## Does not deal damage or change the deterministic GameSession.

const MAX_EFFECTS := 34
var events: Array = []
var logical_size := Vector2(384,216)
var ground := 155.0
var warnings: Array = []
var running := true

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func resize_to(area: Vector2, ground_line: float) -> void:
    logical_size = area
    ground = ground_line
    # Pixel visual state can be discarded when resizing; combat simulation persists.
    events.clear()
    warnings.clear()
    queue_redraw()

func on_battle_action(action: Dictionary, start: Vector2, destination: Vector2) -> void:
    var kind: String = String(action.get("kind", ""))
    var owner: String = String(action.get("hero", ""))
    var color := Color(String(action.get("color", "#FCE6AD")))
    var fx_kind := "orb"
    var duration := 0.40
    if kind == "telegraph":
        var length: float = maxf(0.2,float(action.get("duration",1.0)))
        warnings.append({"life":length,"total":length,"attack":String(action.get("attack_id","charge"))})
        queue_redraw()
        return
    if kind in ["boss_phase","summon","interrupt"]:
        fx_kind = "ring"
        duration = 0.75
    elif kind == "enemy":
        fx_kind = "wave" if String(action.get("effect","")) == "howl" else "claw"
        duration = 0.38
    elif kind == "shield":
        fx_kind = "shield"
        duration = 0.70
    elif kind == "heal":
        fx_kind = "cross"
        duration = 0.75
    elif kind == "damage":
        var element: String = String(action.get("element",action.get("effect","")))
        if element in ["fire","flame","burn"]:
            fx_kind = "fire"
        elif element in ["arrow","bolt","projectile_arrow"]:
            fx_kind = "arrow"
        elif element in ["air","wind","gust"]:
            fx_kind = "wind"
        else:
            match owner:
                "rudeus": fx_kind = "stone"
                "roxy": fx_kind = "ice" if String(action.get("effect","")) in ["freeze","aoe"] else "water"
                "eris": fx_kind = "slash"
                "sylphie": fx_kind = "wind"
        duration = 0.42
    else:
        return
    if events.size() >= MAX_EFFECTS:
        events.pop_front()
    events.append({"kind":fx_kind,"life":duration,"total":duration,"color":color,
        "start":start.round(),"end":destination.round(),"owner":owner})
    queue_redraw()

func _process(delta: float) -> void:
    if not running:
        return
    for i in range(events.size()-1,-1,-1):
        events[i]["life"] = float(events[i]["life"]) - delta
        if float(events[i]["life"]) <= 0.0:
            events.remove_at(i)
    for i in range(warnings.size()-1,-1,-1):
        warnings[i]["life"] = float(warnings[i]["life"]) - delta
        if float(warnings[i]["life"]) <= 0.0:
            warnings.remove_at(i)
    if not events.is_empty() or not warnings.is_empty():
        queue_redraw()

func _square(pos: Vector2, dimensions: Vector2, pigment: Color) -> void:
    draw_rect(Rect2(pos.round(),dimensions),pigment)

func _draw() -> void:
    for warning in warnings:
        var remain: float = clampf(float(warning["life"]) / float(warning["total"]),0.0,1.0)
        var flash: bool = int(remain * 16.0) % 2 == 0
        # Charge hits the front line; howl threatens the party on the right.
        var center_x: float = logical_size.x * (0.64 if warning["attack"] == "charge" else 0.72)
        var width: float = logical_size.x * (0.37 if warning["attack"] == "charge" else 0.53)
        var left: float = floor(center_x - width*0.5)
        var pigment := Color("#F27B68")
        pigment.a = 0.52 if flash else 0.27
        _square(Vector2(left,ground - 2.0),Vector2(ceil(width),3),pigment)
        for step in range(5):
            _square(Vector2(left + step*maxf(1.0,floor(width/5.0)),ground-5),Vector2(4,2),pigment)
    for entry in events:
        var life: float = float(entry["life"])
        var ratio: float = clampf(1.0-life/float(entry["total"]),0.0,1.0)
        var source: Vector2 = entry["start"]
        var destination: Vector2 = entry["end"]
        var kind: String = entry["kind"]
        var pigment: Color = entry["color"]
        var position_now: Vector2 = source.lerp(destination,minf(1.0,ratio*1.45)).round()
        match kind:
            "stone":
                _square(position_now+Vector2(-4,-3),Vector2(9,7),Color("#594736"))
                _square(position_now+Vector2(-2,-4),Vector2(6,5),pigment)
                _square(position_now+Vector2(-9,2),Vector2(4,2),Color("#F5D79A"))
            "water", "ice":
                _square(position_now+Vector2(-5,-3),Vector2(8,6),Color("#187CB8"))
                _square(position_now+Vector2(-1,-5),Vector2(5,10),pigment)
                _square(position_now+Vector2(-10,-1),Vector2(3,2),Color("#B9FBFF"))
                if kind == "ice":
                    _square(position_now+Vector2(4,-8),Vector2(2,5),Color("#F2FFFF"))
            "fire":
                var flame_lift: float = 4.0 + floor(ratio*7.0)
                _square(position_now+Vector2(-4,-int(flame_lift)),Vector2(8,11),Color("#A6373E"))
                _square(position_now+Vector2(-2,-int(flame_lift)+2),Vector2(5,8),Color("#FF924A"))
                _square(position_now+Vector2(0,-int(flame_lift)+4),Vector2(3,4),Color("#FFE3A1"))
            "arrow":
                var heading: float = 1.0 if destination.x>=source.x else -1.0
                _square(position_now+Vector2(-10*heading,-1),Vector2(11,2),Color("#D6C19A"))
                _square(position_now+Vector2(0, -3),Vector2(5,6),Color("#D3E4E3"))
                _square(position_now+Vector2(-12*heading,-3),Vector2(3,5),Color("#82ADB7"))
            "wind":
                _square(position_now+Vector2(-7,-4),Vector2(12,2),Color("#95FCD9"))
                _square(position_now+Vector2(-10,0),Vector2(10,2),pigment)
                _square(position_now+Vector2(-5,5),Vector2(8,2),Color("#D5FFF2"))
            "slash":
                var slash_end: Vector2 = destination + Vector2(0,-7)
                _square(slash_end+Vector2(-3-int(ratio*9),-12+int(ratio*7)),Vector2(4,13),Color("#D94C42"))
                _square(slash_end+Vector2(-1-int(ratio*7),-12+int(ratio*6)),Vector2(2,12),pigment)
            "claw":
                _square(position_now+Vector2(-7,-9),Vector2(3,15),pigment)
                _square(position_now+Vector2(-2,-7),Vector2(3,15),pigment)
                _square(position_now+Vector2(3,-5),Vector2(3,15),pigment)
            "wave":
                var spread: float = floor(ratio*13.0)
                _square(destination+Vector2(-spread-2,-20),Vector2(3,23),pigment)
                _square(destination+Vector2(spread-1,-20),Vector2(3,23),pigment)
            "shield", "ring":
                var radius: float = 5.0 + floor(ratio * 17.0)
                var circle_color := pigment
                circle_color.a = 1.0-ratio*0.6
                var midpoint := (destination+Vector2(0,-18)).round()
                _square(midpoint+Vector2(-radius,-radius),Vector2(radius*2+1,2),circle_color)
                _square(midpoint+Vector2(-radius,radius),Vector2(radius*2+1,2),circle_color)
                _square(midpoint+Vector2(-radius,-radius),Vector2(2,radius*2+1),circle_color)
                _square(midpoint+Vector2(radius,-radius),Vector2(2,radius*2+1),circle_color)
            "cross":
                var lift: float = floor(ratio*10.0)
                _square(position_now+Vector2(-2,-22-lift),Vector2(5,15),pigment)
                _square(position_now+Vector2(-7,-17-lift),Vector2(15,5),pigment)
