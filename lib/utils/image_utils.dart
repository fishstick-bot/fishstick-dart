import "dart:io";
import "package:image_extensions/image_extensions.dart";

Map<String, Image?> cache = {};

class ImageUtils {
  /// fortnite font
  late BitmapFont burbank;

  /// load fonts
  Future<BitmapFont> loadFont() async {
    burbank = readFontZip(
        await File("assets/fonts/BurbankBigRegular-Black.zip").readAsBytes());
    return burbank;
  }

  /// draw fortnite cosmetic
  Future<Image> drawFortniteCosmetic({
    required String icon,
    required String rarity,
  }) async {
    int x = 416;
    int y = 520;
    final Image canvas = drawCanvas(x, y);

    drawRadialGradient(
      canvas,
      0,
      0,
      x,
      y,
      x ~/ 2,
      y ~/ 2,
      Colors.gradient1,
      Colors.gradient2,
    );

    drawImage(
      canvas,
      await loadImage(icon) ?? Image(0, 0),
      dstX: (-canvas.height * 0.1).toInt(),
      dstY: 0,
      dstW: canvas.height,
      dstH: canvas.height,
    );

    // List<int> rgba =
    //     Colors.overlayColors[rarity] ?? Colors.overlayColors["common"]!;
    // int color = getColor(rgba[0], rgba[1], rgba[2], 255);

    cache[rarity] ??= await loadImage("assets/locker/$rarity.png");
    drawImage(canvas, cache[rarity] ?? Image(0, 0));

    return removeAlphaChannel(canvas);
  }
}

class Colors {
  /// background color for fortnite images
  static int get background => getColor(19, 105, 199);

  /// gradient color 1 background for fortnite card
  static int get gradient1 => getColor(45, 150, 235);

  /// gradient color 2 background for fortnite card
  static int get gradient2 => getColor(14, 100, 194);

  static Map<String, List<int>> get overlayColors => {
        "common": [96, 170, 58],
        "uncommon": [96, 170, 58],
        "rare": [73, 172, 242],
        "epic": [177, 91, 226],
        "legendary": [211, 120, 65],
        "marvel": [168, 53, 56],
        "dark": [179, 62, 187],
        "dc": [80, 97, 122],
        "icon": [43, 134, 135],
        "lava": [185, 102, 100],
        "frozen": [148, 215, 244],
        "shadow": [66, 64, 63],
        "starwars": [231, 196, 19],
        "slurp": [0, 233, 176],
        "platform": [117, 108, 235],
        "gaminglegends": [117, 108, 235],
      };
}
