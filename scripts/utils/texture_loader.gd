extends RefCounted
## Load images even on a fresh git checkout without Godot's .godot/imported cache.
## Imported builds use ResourceLoader; source checkouts fall back to the original PNG.
static func load_png(path: String) -> Texture2D:
    if ResourceLoader.exists(path, "Texture2D"):
        var imported: Resource = ResourceLoader.load(path, "Texture2D")
        if imported is Texture2D:
            return imported as Texture2D

    if not FileAccess.file_exists(path):
        push_error("KMushokoPixel: missing required PNG file: " + path)
        return null

    var image: Image = Image.new()
    var status: Error = image.load(path)
    if status != OK or image.is_empty():
        push_error("KMushokoPixel: cannot decode PNG %s (error %d)" % [path, status])
        return null
    return ImageTexture.create_from_image(image)
