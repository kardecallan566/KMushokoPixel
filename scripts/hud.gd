extends Node2D
## Clear, low-occlusion HUD. Compact window has no character cards over the world.
## All coordinates in logical pixels; the parent applies integer 2x/3x scale.
var game
const NAMES := ["RUDEUS","SYLPHIE","ROXY","ERIS"]
const COLORS := [Color("#79C6EB"),Color("#81DEA0"),Color("#B3A5F5"),Color("#EAB5A6")]
const PANEL := Color("#102838")
const BORDER := Color("#3A6874")
const CREAM := Color("#F3ECD2")

func _draw() -> void:
    if game==null or not game.hud_visible:
        return
    var sz: Vector2 = game.visible_size
    var session = game.session
    var compact: bool = game.window_mode.compact
    var head_h: float = 12.0 if compact else 19.0
    _panel(Rect2(0,0,sz.x,head_h),Color("#102A3C"),Color("#598C8B"))
    _text(Vector2(6,9 if compact else 13),"PLANICIES VERDES",8 if compact else 10,CREAM)
    _text(Vector2(121 if compact else 156,9 if compact else 13),"FASE %02d/10" % session.stage_number,8 if compact else 9,Color("#B9E7D9"))
    var right: float = sz.x-91.0 if compact else sz.x-121.0
    _text(Vector2(right,9 if compact else 13),"%d G" % session.gold,8,Color("#F8D591"))
    if not compact:
        _text(Vector2(right+53,13),"NV %d" % session.level,8,Color("#C5DAE9"))
    _panel(game._pause_button,Color("#294C60"),BORDER)
    _panel(game._control_button,Color("#294C60"),BORDER)
    _text(game._pause_button.position+Vector2(3,9 if compact else 12),">" if session.paused else "II",8,CREAM)
    _text(game._control_button.position+Vector2(2,9 if compact else 12),"+" if compact else "-",9,CREAM)
    if session.phase=="combat":
        var alive: int=0
        var health: float=0.0
        var maximum: float=0.0
        for foe in session.enemies:
            if int(foe["hp"])>0: alive+=1
            health+=maxf(0,float(foe["hp"]))
            maximum+=float(foe["max_hp"])
        if not compact:
            _text(Vector2(8,31),"ENCONTRO  %d INIMIGOS" % alive,8,Color("#F5F1D9"))
            _bar(Vector2(8,35),87,3,health/maxf(maximum,1.0),Color("#E6817A"))
        if session.boss_telegraph:
            var warn: String="INVESTIDA"
            for foe in session.enemies:
                if bool(foe.get("boss",false)) and float(foe.get("windup_left",0))>0.0:
                    warn="UIVO EM AREA" if String(foe.get("attack_id",""))=="howl" else "INVESTIDA"
                    break
            var panel_y: float=15.0 if compact else 25.0
            _panel(Rect2(sz.x*0.40,panel_y,100,14),Color("#5D303F"),Color("#F6B185"))
            _text(Vector2(sz.x*0.40+5,panel_y+10),"! " + warn,8,Color("#FFF4E1"))
        elif session.boss_phase==2 and not compact:
            _text(Vector2(sz.x*0.42,32),"LOBO ALFA EM FURIA",8,Color("#F5A795"))
    if not compact:
        if game._status_time>0.0:
            _text(Vector2(113,32),_trim(game._status_text,29),8,game._status_color)
        _party_panel(sz,session)
        _panel(Rect2(0,sz.y-13,sz.x,13),PANEL,BORDER)
        _text(Vector2(5,sz.y-4),"[U] EVOLUIR %d" % session.upgrade_cost(),7,Color("#B8E2C6"))
        _text(Vector2(113,sz.y-4),"[F] FARM %s" % ("ON" if session.farm_mode else "OFF"),7,Color("#C9E0ED"))
        _text(Vector2(sz.x-116,sz.y-4),"TAB JANELA   S SALVAR",7,Color("#ADC7D5"))
    else:
        _panel(Rect2(0,sz.y-11,sz.x,11),PANEL,BORDER)
        _text(Vector2(6,sz.y-3),"UP %d" % session.upgrade_cost(),7,Color("#E0EBC4"))
        _text(Vector2(79,sz.y-3),"FARM %s" % ("ON" if session.farm_mode else "OFF"),7,Color("#E6EBC4"))
        for i in range(mini(4,session.heroes.size())):
            var h: Dictionary=session.heroes[i]
            var hp: float=float(h["hp"])/maxf(1.0,float(session.get_max_hp(h)))
            _bar(Vector2(172+i*34,sz.y-8),30,4,hp,COLORS[i])
        _text(Vector2(sz.x-90,sz.y-3),"TAB EXPANDIR",7,Color("#B4DFE2"))
    if not compact:
        var shown: int=0
        for flash in game._flashes:
            if shown>=4:break
            var fx: String=String(flash["kind"])
            if fx not in ["damage","enemy","heal"]:continue
            var amount: int=int(flash["amount"])
            var xx: float=sz.x*0.75 if fx=="damage" else sz.x*0.35
            var yy: float=game.baseline-77.0-(0.7-float(flash["life"]))*21.0
            _text(Vector2(xx+shown*8.0,yy),("+" if fx=="heal" else "-")+str(amount),10,Color(flash["color"]))
            shown+=1

func _party_panel(sz: Vector2, session) -> void:
    var y: float=sz.y-38.0
    var block_width: float=floor((sz.x-10.0)/4.0)
    for i in range(mini(4,session.heroes.size())):
        var hero: Dictionary=session.heroes[i]
        var x: float=4.0+i*block_width
        _panel(Rect2(x,y,block_width-3.0,25),Color("#122C3D"),COLORS[i])
        # Crop the face from a native 72x100 reference sprite at 1:1 resolution.
        if i < game.heroes.size():
            var img = game.heroes[i]._sheet
            if img!=null:
                draw_texture_rect_region(img,Rect2(x+2,y+2,17,18),Rect2(22,21,17,18))
        _text(Vector2(x+23,y+10),NAMES[i],8,CREAM)
        var ratio: float=float(hero["hp"])/maxf(float(session.get_max_hp(hero)),1.0)
        _bar(Vector2(x+23,y+13),block_width-29.0,4,ratio,Color("#72DFAC"))
        if int(hero.get("shield",0))>0:
            _text(Vector2(x+23,y+23),"ESC %d" % int(hero["shield"]),7,Color("#9FD8FA"))
        else:
            _text(Vector2(x+23,y+23),"NV %d" % session.level,7,Color("#95AEC6"))

func _trim(value: String, maximum: int) -> String:
    return value if value.length()<=maximum else value.substr(0,maximum-1)+"…"

func _panel(rect: Rect2, fill: Color, edge: Color) -> void:
    draw_rect(rect,fill)
    draw_rect(rect,edge,false,1.0)

func _bar(pos: Vector2, width: float, height: float, ratio: float, tint: Color) -> void:
    draw_rect(Rect2(pos,Vector2(width,height)),Color("#0B1929"))
    draw_rect(Rect2(pos+Vector2(1,1),Vector2(maxf(0,(width-2)*clampf(ratio,0,1)),maxf(1,height-2))),tint)

func _text(pos: Vector2, value: String, size: int, color: Color) -> void:
    draw_string(ThemeDB.fallback_font,pos,value,HORIZONTAL_ALIGNMENT_LEFT,-1.0,size,color)
