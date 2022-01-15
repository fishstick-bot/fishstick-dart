import "dart:io";
import "package:image_extensions/image_extensions.dart";

Map<String, Image?> cache = {};

class ImageUtils {
  /// fortnite font
  late BitmapFont burbank;

  /// fortnite cosmetic background
  late Image? cosmeticBackground;

  /// locker background
  late Image? lockerBackground;

  /// load fonts
  Future<BitmapFont> loadFont() async {
    burbank = readFontZip(
        await File("assets/fonts/BurbankBigRegular-Black.zip").readAsBytes());
    return burbank;
  }

  /// load cached images
  Future<void> loadCachedImages() async {
    cosmeticBackground = await loadImage("assets/locker/bg.png");
    lockerBackground = await loadImage("assets/locker/4k.png");
  }

  /// draw fortnite cosmetic
  Future<Image> drawFortniteCosmetic({
    required String icon,
    required String rarity,
  }) async {
    final Image canvas = drawCanvas(416, 520);

    drawImage(canvas, cosmeticBackground ?? Image(0, 0));

    drawImage(
      canvas,
      await loadNetworkImage(icon) ?? Image(0, 0),
      dstX: (-canvas.height * 0.1).toInt(),
      dstY: 0,
      dstW: canvas.height,
      dstH: canvas.height,
    );

    cache[rarity] ??= await loadImage("assets/locker/$rarity.png");
    drawImage(canvas, cache[rarity] ?? Image(0, 0));

    return canvas;
  }
}

class Colors {
  /// background color for fortnite images
  static int get background => getColor(19, 105, 199);
}
