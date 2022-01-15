import "dart:io";
import "package:http/http.dart";
import "package:image/image.dart";

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

  /// draw canvas
  Image drawCanvas(int x, int y) => Image(x, y);

  /// load an image from a local file
  Future<Image?> loadImage(String path) async {
    try {
      return decodeImage(await File(path).readAsBytes());
    } on Exception {
      return null;
    }
  }

  /// load an image from network
  Future<Image?> loadNetworkImage(String url) async {
    try {
      var res = await get(Uri.parse(url));
      return decodeImage(res.bodyBytes);
    } on HttpException {
      return null;
    }
  }

  /// draw fortnite cosmetic
  Future<Image> drawFortniteCosmetic({
    required String icon,
    required String rarity,
  }) async {
    final Image canvas = drawCanvas(416, 520);

    final Image? bg = cosmeticBackground;
    if (bg != null) {
      drawImage(
        canvas,
        bg,
        dstX: 0,
        dstY: 0,
        dstW: canvas.height,
        dstH: canvas.height,
      );
    }

    final Image? iconImage = await loadNetworkImage(icon);
    if (iconImage != null) {
      drawImage(
        canvas,
        iconImage,
        dstX: (-canvas.height * 0.1).toInt(),
        dstY: 0,
        dstW: canvas.height,
        dstH: canvas.height,
      );
    }

    final Image? rarityImage = await loadImage("assets/locker/$rarity.png");
    if (rarityImage != null) {
      drawImage(
        canvas,
        rarityImage,
        dstX: 0,
        dstY: 0,
        dstW: canvas.height,
        dstH: canvas.height,
      );
    }

    return canvas;
  }
}

class Colors {
  /// background color for fortnite images
  static int get background => getColor(19, 105, 199);
}
