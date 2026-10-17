extends Node2D
## Renders above sprites/foreground so the HUD never gets covered by leaves,
## character hair or boss sprites. The game session remains the single source of truth.
var game
const NAMES := ["RUDEUS", "SYLPHIE", "ROXY", "ERIS"]
const ROLES := ["ARTILHARIA", "SUPORTE", "CONTROLE", "GUERREIRA"]

func _draw() -> void:
    if game == null:
        return
    var hud_visible: bool = game.hud_visible
    var window_mode = game.window_mode
    var visible_size: Vector2 = game.visible_size
    var session = game.session
    var _control_button: Rect2 = game._control_button
    var _pause_button: Rect2 = game._pause_button
    var _upgrade_button: Rect2 = game._upgrade_button
    var _farm_button: Rect2 = game._farm_button
    var _status_time: float = game._status_time
    var _status_text: String = game._status_text
    var _status_color: Color = game._status_color
    var _flashes: Array = game._flashes
    var baseline: float = game.baseline
    if not hud_visible:
        return
    var dark := Color("#162934")
    dark.a = 0.92
    var header_h := 14.0 if window_mode.compact else 25.0
    draw_rect(Rect2(0,0,visible_size.x,header_h),dark)
    draw_rect(Rect2(0,header_h-1,visible_size.x,1),Color("#61998A"))
    var title := "KMUSHOKOPIXEL  |  %02d/10" % session.stage_number
    if session.highest_cleared >= 10:
        title = "KMUSHOKOPIXEL | REGIAO CONCLUIDA"
    if window_mode.compact:
        title = "PLANICIES  %02d/10   $%d   LV%d" % [session.stage_number,session.gold,session.level]
    _text(Vector2(6,10 if window_mode.compact else 14),title,8 if window_mode.compact else 9,Color("#F8F5DE"))
    draw_rect(_pause_button,Color("#3F6266"))
    draw_rect(_control_button,Color("#3F6266"))
    _text(_pause_button.position+Vector2(7,10 if window_mode.compact else 13),">" if session.paused else "II",8,Color.WHITE)
    _text(_control_button.position+Vector2(5,10 if window_mode.compact else 13),"<>" if window_mode.compact else "[]",8,Color.WHITE)
    if not window_mode.compact:
        var left_hud := Rect2(5,27,158,17)
        draw_rect(left_hud,Color("#17333E"))
        _text(Vector2(10,39),"OURO %d  NIV %d  VIT %d" % [session.gold,session.level,session.wins],9,Color("#FFE6A1"))
    if not window_mode.compact and session.phase == "combat" and not session.enemies.is_empty():
        var alive := 0
        var total_hp := 0.0
        var total_max := 0.0
        for mob in session.enemies:
            if int(mob["hp"]) > 0: alive += 1
            total_hp += maxf(0,float(mob["hp"]))
            total_max += float(mob["max_hp"])
        _text(Vector2(8,57),"COMBATE | INIMIGOS %d" % alive,9,Color("#FFF3CF"))
        _bar(Vector2(8,61),minf(visible_size.x*0.40,157.0),4,total_hp/maxf(1,total_max),Color("#E27A68"))
        if session.boss_telegraph:
            var boss_attack := "INVESTIDA"
            for foe in session.enemies:
                if bool(foe.get("boss",false)) and float(foe.get("windup_left",0.0)) > 0:
                    boss_attack = "UIVO EM AREA" if String(foe.get("attack_id","")) == "howl" else "INVESTIDA"
                    break
            draw_rect(Rect2(visible_size.x*0.50,28,visible_size.x*0.45,20),Color("#773644"))
            _text(Vector2(visible_size.x*0.51,42),"PERIGO: " + boss_attack,9,Color("#FFF1D5"))
        elif session.boss_phase == 2 and session.phase == "combat":
            _text(Vector2(visible_size.x*0.62,40),"FASE 2: FURIA",9,Color("#F8A38A"))
    if _status_time > 0.0 and not window_mode.compact:
        var text_len: float = minf(visible_size.x-10.0,maxf(140.0,_status_text.length()*5.2))
        draw_rect(Rect2(floor((visible_size.x-text_len)/2),75,ceil(text_len),17),Color("#20313A"))
        _text(Vector2(floor((visible_size.x-text_len)/2)+6,87),_status_text,9,_status_color)
    if not window_mode.compact:
        _draw_party_status()
    if not window_mode.compact:
        draw_rect(Rect2(0,visible_size.y-22,visible_size.x,22),Color("#122B35"))
        draw_rect(_upgrade_button,Color("#376656"))
        draw_rect(_farm_button,Color("#415F6B"))
        _text(_upgrade_button.position+Vector2(6,13),"[U] UP %d" % session.upgrade_cost(),8,Color("#E8FFE1"))
        _text(_farm_button.position+Vector2(5,13),"[F] FARM %s" % ("ON" if session.farm_mode else "OFF"),8,Color.WHITE)
        _text(Vector2(visible_size.x-137,visible_size.y-9),"TAB JANELA | S SALVAR",8,Color("#C9DBE5"))
    else:
        draw_rect(Rect2(0,visible_size.y-18,visible_size.x,18),Color("#172F38"))
        draw_rect(_upgrade_button,Color("#376656"))
        draw_rect(_farm_button,Color("#415F6B"))
        _text(Vector2(10,visible_size.y-7),"UP %d" % session.upgrade_cost(),8,Color("#E8FFE1"))
        _text(Vector2(101,visible_size.y-7),"FARM %s" % ("ON" if session.farm_mode else "OFF"),8,Color.WHITE)
        _text(Vector2(visible_size.x-91,visible_size.y-7),"TAB EXPANDIR",8,Color("#D5E8EB"))
        if session.boss_telegraph:
            var compact_bar: Color = Color("#FF9975")
            draw_rect(Rect2(visible_size.x*0.62,15,visible_size.x*0.30,3),compact_bar)
            _text(Vector2(visible_size.x*0.62,27),"PERIGO: CHEFE",8,Color("#FFE6DC"))
        # Four unobtrusive HP pips rather than cards covering characters.
        var hp_x := 180
        for h in session.heroes:
            var value: float = float(h["hp"]) / maxf(1.0,float(session.get_max_hp(h)))
            _bar(Vector2(hp_x,visible_size.y-11),35,4,value,Color("#7CDB94"))
            hp_x += 40
    for flash in _flashes:
        if window_mode.compact:
            continue
        var x := visible_size.x*0.72 if flash["kind"] == "damage" else visible_size.x*0.36
        var y := baseline - 83.0 - (0.7-float(flash["life"]))*25.0
        if flash["kind"] in ["damage","enemy"]:
            _text(Vector2(x,y),"-%d" % int(flash["amount"]),12,flash["color"])
        elif flash["kind"] == "heal":
            _text(Vector2(x,y),"+%d" % int(flash["amount"]),11,flash["color"])

func _draw_party_status() -> void:
    var window_mode = game.window_mode
    var visible_size: Vector2 = game.visible_size
    var session = game.session
    var heroes: Array = game.heroes
    var y := visible_size.y-41.0 if window_mode.compact else visible_size.y-37.0
    var step := visible_size.x / 4.0
    for i in range(mini(heroes.size(),session.heroes.size())):
        var hero: Dictionary = session.heroes[i]
        var x := 7.0 + i * step
        draw_rect(Rect2(x-3,y-13,step-6,25),Color(0.08,0.20,0.25,0.86))
        _text(Vector2(x,y-3),NAMES[i],8,Color("#FFF3DD"))
        var ratio: float = float(hero["hp"])/float(session.get_max_hp(hero))
        _bar(Vector2(x,y+2),step-14.0,4,ratio,Color("#72D887"))
        var shield: int = int(hero["shield"])
        if shield > 0:
            _text(Vector2(x,y+13),"ESC %d" % shield,7,Color("#9DDCF8"))
        elif not window_mode.compact:
            _text(Vector2(x,y+13),ROLES[i],7,Color("#B8DFD3"))

func _bar(pos: Vector2, width: float, height: float, value: float, color: Color) -> void:
    draw_rect(Rect2(pos,Vector2(width,height)),Color("#1E3542"))
    draw_rect(Rect2(pos+Vector2.ONE,Vector2(maxf(0,(width-2)*clampf(value,0,1)),maxf(1,height-2))),color)

func _text(at: Vector2, value: String, size: int, color: Color) -> void:
    draw_string(ThemeDB.fallback_font,at,value,HORIZONTAL_ALIGNMENT_LEFT,-1.0,size,color)

