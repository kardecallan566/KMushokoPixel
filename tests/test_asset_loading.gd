extends SceneTree
## Regression: run FIRST on a fresh Git checkout, before `godot --editor` imports.
## A successful startup must load actual sprites/biomes, not fallback rectangles.
const TextureLoader = preload("res://scripts/utils/texture_loader.gd")

func _initialize() -> void:
    var required: Dictionary = {
        "assets/biomes/green_plains/clouds.png": Vector2i(960,118),
        "assets/biomes/green_plains/mountains.png": Vector2i(960,76),
        "assets/biomes/green_plains/treeline.png": Vector2i(960,64),
        "assets/biomes/green_plains/meadow.png": Vector2i(960,144),
        "assets/biomes/green_plains/foreground.png": Vector2i(960,80),
        "assets/biomes/green_plains/details.png": Vector2i(960,64),
        "assets/characters/rudeus_sheet.png": Vector2i(1440,100),
        "assets/characters/sylphie_sheet.png": Vector2i(1440,100),
        "assets/characters/roxy_sheet.png": Vector2i(1440,100),
        "assets/characters/eris_sheet.png": Vector2i(1440,100),
        "assets/enemies/slime_sheet.png": Vector2i(192,48),
        "assets/enemies/boar_sheet.png": Vector2i(256,56),
        "assets/enemies/wolf_sheet.png": Vector2i(256,56),
        "assets/enemies/mushroom_sheet.png": Vector2i(192,56),
        "assets/enemies/elite_boar_sheet.png": Vector2i(256,56),
        "assets/enemies/alpha_wolf_sheet.png": Vector2i(384,80),
        "assets/effects/rudeus_cast.png": Vector2i(192,32),
        "assets/effects/sylphie_cast.png": Vector2i(192,32),
        "assets/effects/roxy_cast.png": Vector2i(192,32),
        "assets/effects/eris_cast.png": Vector2i(192,32)
    }
    var failures: Array[String] = []
    for relative_path in required:
        var path: String = "res://" + relative_path
        var texture: Texture2D = TextureLoader.load_png(path)
        if texture == null:
            failures.append(relative_path + ": failed to load")
        elif Vector2i(texture.get_width(),texture.get_height()) != required[relative_path]:
            failures.append(relative_path + ": wrong texture dimensions")
    if failures.size() > 0:
        for failure in failures:
            push_error(failure)
        quit(1)
        return
    print("PASS: %d source PNGs load correctly without imported cache" % required.size())
    quit(0)
