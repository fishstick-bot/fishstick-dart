import "dart:io";
import "dart:math";
import 'dart:typed_data';
import "package:image_extensions/image_extensions.dart";
import "package:fortnite/fortnite.dart";
import "../extensions/fortnite_extensions.dart";

Map<String, Image?> cache = {};

class ImageUtils {
  /// fortnite font
  late BitmapFont burbank;

  /// bot logo
  late Image botLogo;

  /// locker icon
  late Image lockerIcon;

  /// discord logo
  late Image discordLogo;

  /// load fonts
  Future<BitmapFont> loadFont() async {
    burbank = readFontZip(await File("assets/fonts/BurbankBigRegular-Black.zip").readAsBytes());
    burbank.scaleW = 2;
    burbank.scaleH = 2;
    return burbank;
  }

  /// load images
  Future<void> loadImages() async {
    botLogo = (await loadImage("assets/logo.png"))!;
    lockerIcon = (await loadImage("assets/locker_icon.png"))!;
    discordLogo = (await loadImage("assets/discord.png"))!;
  }

  /// draw fortnite cosmetic
  Future<Image> drawFortniteCosmetic({
    required String icon,
    required String rarity,
    bool isExclusive = false,
  }) async {
    int x = 416 ~/ 2;
    int y = 520 ~/ 2;
    final Image canvas = drawCanvas(x, y);

    drawRadialGradient(
      canvas,
      0,
      0,
      x,
      y,
      x ~/ 2,
      y ~/ 2,
      isExclusive ? Colors.exclusive1 : Colors.gradient1,
      isExclusive ? Colors.exclusive2 : Colors.gradient2,
    );

    drawImage(
      canvas,
      await loadImage(icon) ?? Image(0, 0),
      dstX: (-canvas.height * 0.1).toInt(),
      dstY: 0,
      dstW: canvas.height,
      dstH: canvas.height,
    );

    List<int> rgba = Colors.overlayColors[rarity] ?? Colors.overlayColors["common"]!;
    if (isExclusive) {
      rgba = rgba;
    }

    fillShape(
      canvas,
      [
        [0, y],
        [x, y],
        [x, (y * 0.9).toInt()],
        [0, (y * 0.95).toInt()],
      ],
      getColor(rgba[0], rgba[1], rgba[2], (255 * 0.8).toInt()),
    );
    fillShape(
      canvas,
      [
        [0, (y * 0.97).toInt()],
        [x, (y * 0.93).toInt()],
        [x, (y * 0.9).toInt()],
        [0, (y * 0.95).toInt()],
      ],
      getColor(rgba[0], rgba[1], rgba[2], (255 * 0.9).toInt()),
    );

    return removeAlphaChannel(canvas);
  }

  /// draw locker
  Future<Image> drawLocker({
    required List<AthenaCosmetic> cosmetics,
  }) async {
    int padding = 50;
    int itemWidth = 416 ~/ 2;
    int itemHeight = 520 ~/ 2;

    int itemsInARow = sqrt(cosmetics.length).ceil();
    int itemsInAColumn = (cosmetics.length / itemsInARow).ceil();

    int width = itemWidth * itemsInARow + padding + itemsInARow * padding;
    int height = itemHeight * itemsInAColumn + itemsInAColumn * padding + itemHeight;

    int maxDistance = ((width / 2) * (width / 2) + (height / 2) * (height / 2)).ceil();

    int distanceSquared(int x1, int y1, int x2, int y2) =>
        (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2);

    Uint32List data = Uint32List(width * height);

    List<Image?> cosmeticImages = await Future.wait(cosmetics.map((e) => loadImage(e.imagePath)));

    int tileWidth = (itemWidth + padding);
    int tileHeight = (itemHeight + padding);

    double whiteStart = padding - padding / 4;

    for (int x = 0; x < width; x++) {
      int tileX = (x - padding / 2).floor() % tileWidth;
      int tileXPos = (x / tileWidth).floor();

      for (int y = 0; y < height; y++) {
        int tileY = (y - padding / 2).floor() % tileHeight;
        int tileYPos = (y / tileHeight).floor();

        int imageIndex = tileYPos * itemsInAColumn + tileXPos;

        int pixel;

        if (tileX > whiteStart &&
            tileY > whiteStart &&
            tileX < tileWidth - whiteStart &&
            tileY < tileHeight - whiteStart &&
            imageIndex < cosmeticImages.length) {
          if (tileX > padding &&
              tileY > padding &&
              tileX < tileWidth - padding &&
              tileY < tileHeight - padding) {
            // Render image
            Image current = cosmeticImages[imageIndex] ?? Image(0, 0);

            int imageX = (((tileX - padding / 2) / itemWidth) * current.width).floor();
            int imageY = (((tileY - padding / 2) / itemHeight) * current.height).floor();

            pixel = current.getPixel(imageX, imageY);
          } else {
            pixel = 0xffffffff; // White
          }
        } else {
          int distance = distanceSquared(x, y, width ~/ 2, height ~/ 2);

          num interpolation = distance / maxDistance;

          int fraction = (interpolation * 255).floor();

          pixel = alphaBlendColors(Colors.bg1, Colors.bg2, fraction);
        }

        data[y * width + x] = pixel;
      }
    }

    Image rendered = Image.fromBytes(width, height, data);

    drawImage(
      rendered,
      botLogo,
      dstX: rendered.width - itemHeight,
      dstY: rendered.height - itemHeight,
      dstW: (itemHeight * 0.9).toInt(),
      dstH: (itemHeight * 0.9).toInt(),
    );

    int fontSize = 20;

    drawString(
      rendered,
      burbank
        ..size = fontSize
        ..italic = true,
      rendered.width - itemHeight - "discord.gg/fishstick".length * fontSize,
      rendered.height - (itemHeight ~/ 2) - fontSize,
      "discord.gg/fishstick",
      color: Colors.white,
    );

    drawImage(
      rendered,
      lockerIcon,
      dstX: (itemHeight * 0.1).toInt(),
      dstY: rendered.height - itemHeight,
      dstW: (itemHeight * 0.9).toInt(),
      dstH: (itemHeight * 0.9).toInt(),
    );

    // add number of cosmetics string after locker icon..

    return rendered;
  }
}

class Colors {
  static int get white => getColor(255, 255, 255, 255);

  /// background color for fortnite images
  static int get background => getColor(19, 105, 199);

  /// gradient color 1 for fortnite images
  static int get bg1 => getColor(22, 134, 224);

  /// gradient color 2 for fortnite images
  static int get bg2 => getColor(14, 80, 153);

  /// gradient color 1 background for fortnite card
  static int get gradient1 => getColor(45, 150, 235);

  /// gradient color 2 background for fortnite card
  static int get gradient2 => getColor(14, 100, 194);

  /// exclusive color 1 background for fortnite card
  static int get exclusive1 => getColor(208, 142, 39);

  /// exclusive color 2 background for fortnite card
  static int get exclusive2 => getColor(252, 220, 84);

  /// colors for fortnite rarities
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
